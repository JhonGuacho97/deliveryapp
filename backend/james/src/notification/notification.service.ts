import { Injectable, Logger } from '@nestjs/common';
import { cert, getApps, initializeApp } from 'firebase-admin/app';
import { getMessaging, Messaging } from 'firebase-admin/messaging';
import { Session } from '../auth/entities/session.entity';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { FilterKM } from '../common/glob/filter';
import { Order } from '../client/market/entities/order.entity';
import { StatusOrder } from 'src/common/glob/status';
import { externalServicesEnabled } from '../config/external-services';

@Injectable()
export class NotificationService {
  private readonly logger = new Logger(NotificationService.name);
  private readonly messaging: Messaging;

  constructor(
    @InjectRepository(Session)
    private readonly sessionRepository: Repository<Session>,

    @InjectRepository(Order)
    private readonly orderRepository: Repository<Order>,
  ) {
    if (!externalServicesEnabled()) {
      this.logger.log('External notifications disabled for local development');
      return;
    }
    const app =
      getApps()[0] ??
      initializeApp({
        credential: cert(JSON.parse(process.env.FIREBASE_CREDENTIAL_JSON)),
      });
    this.messaging = getMessaging(app);
  }

  async notify(userId: number, data: { [key: string]: string }) {
    if (!this.messaging) return;
    const sessions = await this.sessionRepository
      .createQueryBuilder('s')
      .select(['s.tokenPush'])
      .where('s.userId = :userId', { userId: userId })
      .getMany();

    const tokens = sessions
      .map((session) => session.tokenPush)
      .filter((token) => typeof token === 'string' && token.length > 0);
    if (tokens.length > 0)
      await this.messaging.sendEachForMulticast({
        tokens,
        data,
        android: { ttl: 0 },
      });
  }

  async notifyOrder(
    orderId: number,
    latitude: number,
    longitude: number,
    data: { [key: string]: string },
    includeDeliverymen = true,
  ) {
    if (!this.messaging) return;
    if (includeDeliverymen)
      await this.notifyDeliverymen(orderId, latitude, longitude, data);
    const order = await this.orderRepository
      .createQueryBuilder('p')
      .select(['p.id', 'store.id', 'user.id'])
      .innerJoin('p.store', 'store')
      .innerJoin('store.user', 'user')
      .where('p.id = :orderId', { orderId })
      .getOne();
    if (order) await this.notify(order.store.user.id, data);
  }

  async notifyDeliverymen(
    orderId: number,
    latitude: number,
    longitude: number,
    data: { [key: string]: string },
  ) {
    if (!this.messaging) return;
    const sessionsDeliveryman = await this.sessionRepository
      .createQueryBuilder('s')
      .select(['s.tokenPush'])
      .where(this.sqlFilterDeliveryMan(latitude, longitude), {
        km: FilterKM.DELIVERYMAN,
      })
      .getMany();

    const tokensDeliveryman = sessionsDeliveryman
      .map((session) => session.tokenPush)
      .filter((token) => typeof token === 'string' && token.length > 0);
    if (tokensDeliveryman.length > 0) {
      void this.sendOrder(orderId, tokensDeliveryman, data, 0).catch((error) =>
        this.logger.error('Delivery notification failed', error),
      );
    }
  }

  async sendOrder(
    orderId: number,
    tokens: string[],
    data: { [key: string]: string },
    count: number,
  ): Promise<void> {
    if (!this.messaging) return;
    await this.messaging.sendEachForMulticast({
      tokens,
      data,
      android: { ttl: 0 },
    });
    count++;
    if (count > 4) return;
    await new Promise((resolve) => setTimeout(resolve, 8000));
    const order = await this.orderRepository
      .createQueryBuilder('p')
      .select(['p.id'])
      .where('p.id = :orderId AND p.status = :status', {
        orderId,
        status: StatusOrder.STARTED,
      })
      .getOne();
    if (order) await this.sendOrder(orderId, tokens, data, count);
  }

  private sqlFilterDeliveryMan = (
    latitude: number,
    longitude: number,
  ): string =>
    `
    s.isOnline = true AND s.location IS NOT NULL AND
    ST_DistanceSphere( 
    ST_GeomFromText('POINT(${latitude} ${longitude})'), 
      s.location::geometry) 
    <= :km
    `;
}
