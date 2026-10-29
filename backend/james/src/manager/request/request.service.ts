import {
  ConflictException,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { StatusOrder } from 'src/common/glob/status';
import { PreparationStatus } from 'src/common/glob/preparation-status';
import { TypesNotification } from 'src/common/glob/types';
import { User } from 'src/auth/entities/user.entity';
import { Order } from 'src/client/market/entities/order.entity';
import { NotificationService } from 'src/notification/notification.service';
import { Repository } from 'typeorm';

@Injectable()
export class RequestService {
  private readonly logger = new Logger(RequestService.name);
  constructor(
    @InjectRepository(Order) private readonly orders: Repository<Order>,
    private readonly notifications: NotificationService,
  ) {}

  async findNearRequests(user: User) {
    const requests = await this.query()
      .where('store.userId = :userId AND p.status < :delivered', {
        userId: user.id,
        delivered: StatusOrder.DELIVERED,
      })
      .orderBy('p.id', 'ASC')
      .getMany();
    return { requests };
  }

  async findRequest(user: User, orderId: number) {
    const request = await this.query()
      .where('p.id = :id AND store.userId = :userId', {
        id: orderId,
        userId: user.id,
      })
      .getOne();
    if (!request) throw new NotFoundException('Order not found');
    return { request };
  }

  async history(user: User, orderedAt: string) {
    const requests = await this.query()
      .where('store.userId = :userId AND p.orderedAt = :orderedAt', {
        userId: user.id,
        orderedAt,
      })
      .orderBy('p.id', 'DESC')
      .getMany();
    return { requests };
  }

  async accept(user: User, id: number, minutes: number) {
    const { request } = await this.findRequest(user, id);
    this.assertActive(request);
    if (
      request.preparationStatus === PreparationStatus.PREPARING &&
      request.preparationMinutes === minutes
    )
      return { request };
    if (
      request.preparationStatus != null &&
      request.preparationStatus !== PreparationStatus.PENDING
    )
      throw new ConflictException('Order is no longer awaiting acceptance');
    const response = await this.orders
      .createQueryBuilder()
      .update(Order)
      .set({
        preparationStatus: PreparationStatus.PREPARING,
        preparationMinutes: minutes,
        acceptedAt: () => 'CURRENT_TIMESTAMP',
      })
      .where(
        'id = :id AND status IN (:...active) AND ("preparationStatus" IS NULL OR "preparationStatus" = :pending) AND "storeId" IN (SELECT owned.id FROM public.store owned WHERE owned."userId" = :userId)',
        {
          id,
          active: [StatusOrder.STARTED, StatusOrder.ASSIGNED],
          pending: PreparationStatus.PENDING,
          userId: user.id,
        },
      )
      .execute();
    if (response.affected !== 1) {
      const current = await this.findRequest(user, id);
      if (
        current.request.preparationStatus === PreparationStatus.PREPARING &&
        current.request.preparationMinutes === minutes
      )
        return current;
      throw new ConflictException('Order changed; refresh before accepting');
    }
    const updated = await this.findRequest(user, id);
    await this.notify(updated.request, true);
    return updated;
  }

  async ready(user: User, id: number) {
    const { request } = await this.findRequest(user, id);
    this.assertActive(request);
    if (request.preparationStatus === PreparationStatus.READY)
      return { request };
    if (request.preparationStatus !== PreparationStatus.PREPARING)
      throw new ConflictException('Accept the order before marking it ready');
    const response = await this.orders
      .createQueryBuilder()
      .update(Order)
      .set({
        preparationStatus: PreparationStatus.READY,
        readyAt: () => 'CURRENT_TIMESTAMP',
      })
      .where(
        'id = :id AND status IN (:...active) AND "preparationStatus" = :preparing AND "storeId" IN (SELECT owned.id FROM public.store owned WHERE owned."userId" = :userId)',
        {
          id,
          active: [StatusOrder.STARTED, StatusOrder.ASSIGNED],
          preparing: PreparationStatus.PREPARING,
          userId: user.id,
        },
      )
      .execute();
    if (response.affected !== 1) {
      const current = await this.findRequest(user, id);
      if (current.request.preparationStatus === PreparationStatus.READY)
        return current;
      throw new ConflictException(
        'Order changed; refresh before marking it ready',
      );
    }
    const updated = await this.findRequest(user, id);
    await this.notify(updated.request, false);
    return updated;
  }

  private assertActive(order: Order) {
    if (![StatusOrder.STARTED, StatusOrder.ASSIGNED].includes(order.status))
      throw new ConflictException(
        'This order has already left the kitchen or is closed',
      );
  }

  private async notify(order: Order, accepted: boolean) {
    const data = {
      type: TypesNotification.CHANGE_ORDER_STATUS,
      status: String(order.status),
      preparationStatus: order.preparationStatus,
      orderId: String(order.id),
    };
    const jobs = [this.notifications.notify(order.user.id, data)];
    if (order.deliveryman)
      jobs.push(this.notifications.notify(order.deliveryman.id, data));
    if (accepted && !order.deliveryman)
      jobs.push(
        this.notifications.notifyDeliverymen(
          order.id,
          order.location['x'],
          order.location['y'],
          {
            type: TypesNotification.NEW_ORDER,
            title: 'Pedido disponible',
            body: order.store.name,
            orderId: String(order.id),
          },
        ),
      );
    const results = await Promise.allSettled(jobs);
    if (results.some((result) => result.status === 'rejected'))
      this.logger.warn(
        'Kitchen state saved; some notifications could not be sent',
      );
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
        'deliveryman.id',
      ])
      .innerJoin('p.user', 'user')
      .innerJoin('p.store', 'store')
      .innerJoin('store.company', 'company')
      .leftJoin('p.deliveryman', 'deliveryman');
  }
}
