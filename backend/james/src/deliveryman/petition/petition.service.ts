import {
  BadRequestException,
  ConflictException,
  Injectable,
  Logger,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, EntityManager, Repository } from 'typeorm';
import { User } from 'src/auth/entities/user.entity';
import { Session } from 'src/auth/entities/session.entity';
import { Order } from 'src/client/market/entities/order.entity';
import { Balance } from 'src/client/balance/entities/balance.entity';
import { StatusOrder } from 'src/common/glob/status';
import { PreparationStatus } from 'src/common/glob/preparation-status';
import { FilterKM } from 'src/common/glob/filter';
import { ErrorCode } from 'src/common/glob/error';
import { TypesNotification, TypesPayment } from 'src/common/glob/types';
import { NotificationService } from 'src/notification/notification.service';
import { FindPetitionsDto } from './dto/find-petitions.dto';
import { ActivatePetitionDto } from './dto/activate-petition.dto';
import { CollectPetitonDto } from './dto/collect-petition.dto';

const active = [StatusOrder.ASSIGNED, StatusOrder.TAKEN];
const availableKitchen = [PreparationStatus.PREPARING, PreparationStatus.READY];
const money = (value: number) =>
  Math.round((value + Number.EPSILON) * 100) / 100;
// Existing points store latitude in x and longitude in y.
const tripDistance =
  'ST_DistanceSphere(ST_SetSRID(ST_MakePoint((store.location)[1],(store.location)[0]),4326),ST_SetSRID(ST_MakePoint((p.location)[1],(p.location)[0]),4326))';
const pickupDistance =
  'ST_DistanceSphere(ST_SetSRID(ST_MakePoint(:longitude,:latitude),4326),ST_SetSRID(ST_MakePoint((store.location)[1],(store.location)[0]),4326))';

@Injectable()
export class PetitionService {
  private readonly logger = new Logger(PetitionService.name);
  constructor(
    @InjectRepository(Order) private readonly orders: Repository<Order>,
    @InjectRepository(Session) private readonly sessions: Repository<Session>,
    @InjectRepository(Balance) private readonly balances: Repository<Balance>,
    private readonly notifications: NotificationService,
    private readonly database: DataSource,
  ) {}

  private device(user: User) {
    if (!user.authenticatedDeviceId)
      throw new UnauthorizedException('Authenticated device missing');
    return user.authenticatedDeviceId;
  }
  private async session(user: User) {
    const session = await this.sessions.findOneBy({
      user: { id: user.id },
      idDevice: this.device(user),
    });
    if (!session) throw new UnauthorizedException('Session not found');
    return session;
  }
  private position(session: Session) {
    const value = session.location;
    if (!value || typeof value !== 'object') return null;
    const x = Number(value.x),
      y = Number(value.y);
    return Number.isFinite(x) &&
      Number.isFinite(y) &&
      Math.abs(x) <= 90 &&
      Math.abs(y) <= 180
      ? { latitude: x, longitude: y }
      : null;
  }
  private query() {
    return this.orders
      .createQueryBuilder('p')
      .select([
        'p',
        'user.id',
        'user.fullName',
        'user.phone',
        'user.image',
        'store.id',
        'store.name',
        'store.address',
        'store.contact',
        'store.location',
        'company.image',
        'rider.id',
      ])
      .innerJoin('p.user', 'user')
      .innerJoin('p.store', 'store')
      .innerJoin('store.company', 'company')
      .leftJoin('p.deliveryman', 'rider');
  }
  private enrich(
    query: ReturnType<PetitionService['query']>,
    session: Session,
  ) {
    const position = this.position(session);
    query.addSelect(tripDistance, 'tripDistanceMeters');
    if (position)
      query
        .addSelect(pickupDistance, 'pickupDistanceMeters')
        .setParameters(position);
    return query;
  }
  private async present(
    query: ReturnType<PetitionService['query']>,
    user: User,
    session: Session,
  ) {
    const balance = await this.balances.findOneBy({ userId: user.id });
    const { entities, raw } = await this.enrich(
      query,
      session,
    ).getRawAndEntities();
    return entities.map((order, index) => {
      const mine = order.deliveryman?.id === user.id;
      const estimate =
        balance &&
        Number.isFinite(balance.profit) &&
        balance.profit >= 0 &&
        balance.profit <= 1
          ? money(order.deliveryFee * balance.profit)
          : null;
      if (!mine) order.user = { ...order.user, phone: '' };
      return {
        ...order,
        isAssignedToMe: mine,
        estimatedProfit: estimate,
        pickupDistanceMeters:
          raw[index].pickupDistanceMeters == null
            ? null
            : Number(raw[index].pickupDistanceMeters),
        tripDistanceMeters:
          raw[index].tripDistanceMeters == null
            ? null
            : Number(raw[index].tripDistanceMeters),
      };
    });
  }
  private offerCondition(session: Session) {
    return session.isOnline && this.position(session)
      ? '(p.status = :started AND p.deliverymanId IS NULL AND (p.preparationStatus IS NULL OR p.preparationStatus IN (:...kitchen)) AND ' +
          pickupDistance +
          ' <= :radius)'
      : 'FALSE';
  }
  private parameters(user: User) {
    return {
      me: user.id,
      started: StatusOrder.STARTED,
      active,
      kitchen: availableKitchen,
      radius: FilterKM.DELIVERYMAN,
    };
  }

  async findNearPetitions(user: User, dto: FindPetitionsDto) {
    if (dto.idDevice !== this.device(user))
      throw new BadRequestException(
        'Device does not match authenticated session',
      );
    const session = await this.session(user);
    const query = this.query()
      .where(
        '(p.deliverymanId = :me AND p.status IN (:...active)) OR ' +
          this.offerCondition(session),
        this.parameters(user),
      )
      .orderBy('p.id', 'ASC');
    return {
      petitions: await this.present(query, user, session),
      isOnline: session.isOnline,
    };
  }
  async findPetition(user: User, id: number) {
    const session = await this.session(user);
    const query = this.query().where(
      'p.id = :id AND (p.deliverymanId = :me OR ' +
        this.offerCondition(session) +
        ')',
      { ...this.parameters(user), id },
    );
    const petitions = await this.present(query, user, session);
    if (!petitions[0]) throw new NotFoundException('Delivery not found');
    return { petition: petitions[0] };
  }
  async history(user: User, orderedAt: string) {
    const session = await this.session(user);
    const query = this.query()
      .where('p.deliverymanId = :me AND p.orderedAt = :orderedAt', {
        me: user.id,
        orderedAt,
      })
      .orderBy('p.id', 'DESC');
    return { petitions: await this.present(query, user, session) };
  }
  async earnings(user: User, day: string) {
    const predicate =
      'p.deliverymanId = :me AND p.status IN (:...finished) AND p.cancelledAt IS NULL AND (p.deliveredAt AT TIME ZONE :zone)::date = :day';
    const parameters = {
      me: user.id,
      finished: [StatusOrder.DELIVERED, StatusOrder.QUALIFIED],
      zone: 'America/Guayaquil',
      day,
    };
    const summary = await this.orders
      .createQueryBuilder('p')
      .select('COUNT(*)::int', 'completedCount')
      .addSelect(
        'COALESCE(SUM(ROUND(p."deliverymanProfit"::numeric,2)),0)',
        'earnings',
      )
      .addSelect(
        'COUNT(*) FILTER (WHERE p.deliverymanProfit IS NULL)::int',
        'unpricedCount',
      )
      .where(predicate, parameters)
      .getRawOne();
    const balance = await this.balances.findOneBy({ userId: user.id });
    const deliveries = await this.present(
      this.query()
        .where(predicate, parameters)
        .orderBy('p.deliveredAt', 'DESC'),
      user,
      await this.session(user),
    );
    return {
      day,
      timeZone: 'America/Guayaquil',
      completedCount: Number(summary.completedCount),
      earnings: Number(summary.earnings),
      unpricedCount: Number(summary.unpricedCount),
      operatingBalance: balance?.balance ?? null,
      settlementAmount: balance?.amount ?? null,
      deliveries,
    };
  }

  private async row(manager: EntityManager, id: number) {
    const result = await manager
      .getRepository(Order)
      .createQueryBuilder('o')
      .select('o')
      .addSelect('o.deliverymanId', 'riderId')
      .addSelect('o.userId', 'clientId')
      .addSelect('o.storeId', 'pickupId')
      .where('o.id = :id', { id })
      .setLock('pessimistic_write')
      .getRawAndEntities();
    if (!result.entities[0]) throw new NotFoundException('Delivery not found');
    return {
      order: result.entities[0],
      riderId: result.raw[0].riderId as number | null,
      clientId: Number(result.raw[0].clientId),
      storeId: Number(result.raw[0].pickupId),
    };
  }
  private async balance(manager: EntityManager, id: number) {
    const balance = await manager
      .getRepository(Balance)
      .createQueryBuilder('b')
      .where('b.userId = :id', { id })
      .setLock('pessimistic_write')
      .getOne();
    if (!balance)
      throw new BadRequestException({
        codeError: ErrorCode.NOTBALANCE,
        message: 'Account has no balance record',
      });
    return balance;
  }
  private async notify(id: number) {
    const order = await this.orders.findOne({
      where: { id },
      relations: { user: true, deliveryman: true, store: { user: true } },
    });
    if (!order) return;
    const data = {
      type: TypesNotification.CHANGE_ORDER_STATUS,
      status: String(order.status),
      orderId: String(id),
    };
    const recipients = new Set(
      [order.user.id, order.store.user?.id, order.deliveryman?.id].filter(
        (value): value is number => value != null,
      ),
    );
    const results = await Promise.allSettled(
      [...recipients].map((recipient) =>
        this.notifications.notify(recipient, data),
      ),
    );
    // A failed push must not turn a committed transition into an apparent failure.
    if (results.some((result) => result.status === 'rejected'))
      this.logger.warn('Delivery saved; notification unavailable');
  }

  async apply(id: number, user: User) {
    let changed = false;
    await this.database.transaction(async (manager) => {
      const row = await this.row(manager, id);
      const order = row.order;
      if (
        row.riderId === user.id &&
        [...active, StatusOrder.DELIVERED, StatusOrder.QUALIFIED].includes(
          order.status,
        )
      )
        return;
      if (order.status !== StatusOrder.STARTED || row.riderId != null)
        throw new ConflictException({
          codeError: ErrorCode.ORDERFULFILLED,
          message: 'Delivery no longer available',
        });
      if (
        order.preparationStatus != null &&
        !availableKitchen.includes(order.preparationStatus)
      )
        throw new ConflictException('Restaurant has not accepted this order');
      const session = await manager
        .getRepository(Session)
        .createQueryBuilder('s')
        .where('s.userId=:id AND s.idDevice=:device', {
          id: user.id,
          device: this.device(user),
        })
        .setLock('pessimistic_read')
        .getOne();
      const position = session && this.position(session);
      if (!session?.isOnline || !position)
        throw new ConflictException(
          'Connect with a valid location before accepting deliveries',
        );
      const [distance] = await manager.query(
        'SELECT ST_DistanceSphere(ST_SetSRID(ST_MakePoint($1,$2),4326),ST_SetSRID(ST_MakePoint((location)[1],(location)[0]),4326)) AS distance FROM public.store WHERE id=$3',
        [position.longitude, position.latitude, row.storeId],
      );
      if (!distance || Number(distance.distance) > FilterKM.DELIVERYMAN)
        throw new ConflictException('Delivery is outside the service area');
      const balance = await this.balance(manager, user.id);
      if (
        !Number.isFinite(balance.profit) ||
        balance.profit < 0 ||
        balance.profit > 1 ||
        !Number.isFinite(order.deliveryFee) ||
        order.deliveryFee < 0
      )
        throw new ConflictException('Delivery pricing is unavailable');
      const deliverymanProfit = money(order.deliveryFee * balance.profit);
      const deliveryAppProfit = money(order.deliveryFee - deliverymanProfit);
      if (order.payment === TypesPayment.cash) {
        if (balance.balance < deliveryAppProfit)
          throw new BadRequestException({
            codeError: ErrorCode.INSUFFICIENTBALANCE,
            message: 'Insufficient operating balance',
          });
        balance.balance = money(balance.balance - deliveryAppProfit);
      } else if (order.payment === TypesPayment.money) {
        balance.amount = money(balance.amount + deliverymanProfit);
      } else throw new BadRequestException('Unsupported payment type');
      await manager.getRepository(Balance).save(balance);
      await manager
        .getRepository(Order)
        .update(id, {
          deliveryman: user,
          status: StatusOrder.ASSIGNED,
          deliverymanProfit,
          deliveryAppProfit,
          assignedAt: new Date(),
        });
      changed = true;
    });
    if (changed) await this.notify(id);
    return this.findPetition(user, id);
  }

  async collect(id: number, user: User) {
    let changed = false;
    await this.database.transaction(async (manager) => {
      const { order, riderId } = await this.row(manager, id);
      if (riderId !== user.id)
        throw new NotFoundException('Delivery not found');
      if (
        order.status === StatusOrder.TAKEN ||
        ([StatusOrder.DELIVERED, StatusOrder.QUALIFIED].includes(
          order.status,
        ) &&
          !order.cancelledAt)
      )
        return;
      if (order.status !== StatusOrder.ASSIGNED)
        throw new ConflictException('Delivery cannot be collected');
      if (
        order.preparationStatus != null &&
        order.preparationStatus !== PreparationStatus.READY
      )
        throw new ConflictException(
          'Restaurant has not marked this order ready',
        );
      await manager
        .getRepository(Order)
        .update(id, { status: StatusOrder.TAKEN, collectedAt: new Date() });
      changed = true;
    });
    if (changed) await this.notify(id);
    return this.findPetition(user, id);
  }

  async deliver(id: number, user: User, dto: CollectPetitonDto) {
    let changed = false;
    await this.database.transaction(async (manager) => {
      const { order, riderId } = await this.row(manager, id);
      if (riderId !== user.id)
        throw new NotFoundException('Delivery not found');
      if (
        [StatusOrder.DELIVERED, StatusOrder.QUALIFIED].includes(order.status) &&
        !order.cancelledAt
      )
        return;
      if (order.status !== StatusOrder.TAKEN)
        throw new ConflictException(
          'Collect the order before confirming delivery',
        );
      await manager
        .getRepository(Order)
        .update(id, {
          status: StatusOrder.DELIVERED,
          deliveredAt: new Date(),
          ...(dto.scoreDeliveryman == null
            ? {}
            : { scoreDeliveryman: dto.scoreDeliveryman }),
        });
      changed = true;
    });
    if (changed) await this.notify(id);
    return this.findPetition(user, id);
  }

  async cancel(id: number, user: User) {
    let changed = false;
    await this.database.transaction(async (manager) => {
      const { order, riderId, clientId } = await this.row(manager, id);
      if (riderId !== user.id)
        throw new NotFoundException('Delivery not found');
      if (order.status === StatusOrder.CANCELLED || order.cancelledAt) return;
      if (order.status !== StatusOrder.ASSIGNED)
        throw new ConflictException('Only an assigned order can be cancelled');
      if (order.deliverymanProfit == null || order.deliveryAppProfit == null)
        throw new ConflictException('This order has no recorded commission');
      const ids = [
        ...new Set(
          order.payment === TypesPayment.money
            ? [user.id, clientId]
            : [user.id],
        ),
      ].sort((a, b) => a - b);
      const locked = await manager
        .getRepository(Balance)
        .createQueryBuilder('b')
        .where('b.userId IN (:...ids)', { ids })
        .orderBy('b.userId', 'ASC')
        .setLock('pessimistic_write')
        .getMany();
      if (locked.length !== ids.length)
        throw new BadRequestException({
          codeError: ErrorCode.NOTBALANCE,
          message: 'Account has no balance record',
        });
      const rider = locked.find((balance) => balance.userId === user.id)!;
      if (order.payment === TypesPayment.money) {
        const client = locked.find((balance) => balance.userId === clientId)!;
        client.money = money(client.money + order.total);
        rider.amount = money(rider.amount - order.deliverymanProfit);
        if (client !== rider) await manager.getRepository(Balance).save(client);
      } else if (order.payment === TypesPayment.cash) {
        rider.balance = money(rider.balance + order.deliveryAppProfit);
      } else throw new BadRequestException('Unsupported payment type');
      await manager.getRepository(Balance).save(rider);
      await manager
        .getRepository(Order)
        .update(id, { status: StatusOrder.CANCELLED, cancelledAt: new Date() });
      changed = true;
    });
    if (changed) await this.notify(id);
    return this.findPetition(user, id);
  }

  async activate(dto: ActivatePetitionDto, user: User) {
    if (dto.idDevice !== this.device(user))
      throw new BadRequestException(
        'Device does not match authenticated session',
      );
    const result = await this.sessions
      .createQueryBuilder()
      .update()
      .set({
        isOnline: dto.isOnline,
        ...(dto.isOnline
          ? { location: `${dto.latitude},${dto.longitude}` }
          : {}),
      })
      .where('userId=:id AND idDevice=:device', {
        id: user.id,
        device: this.device(user),
      })
      .execute();
    if (result.affected !== 1)
      throw new UnauthorizedException('Session not found');
    return true;
  }
}
