import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Socket } from 'socket.io';
import { User } from 'src/auth/entities/user.entity';
import { Repository, In } from 'typeorm';
import { Session } from '../auth/entities/session.entity';
import { Order } from 'src/client/market/entities/order.entity';
import { StatusOrder } from 'src/common/glob/status';

@Injectable()
export class LocationWsService {
  constructor(
    @InjectRepository(User) private readonly users: Repository<User>,
    @InjectRepository(Session) private readonly sessions: Repository<Session>,
    @InjectRepository(Order) private readonly orders: Repository<Order>,
  ) {}
  async registerUser(socket: Socket, id: number, idDevice: string) {
    const user = await this.users.findOneBy({ id });
    const session = await this.sessions.findOneBy({ user: { id }, idDevice });
    if (!user?.isActive || !session) throw new Error('Session unavailable');
    socket.data.actor = { id, idDevice, roles: user.roles };
    socket['isAuth'] = true;
  }
  async watcherIds(riderId: number) {
    const orders = await this.orders.find({
      where: {
        deliveryman: { id: riderId },
        status: In([StatusOrder.ASSIGNED, StatusOrder.TAKEN]),
      },
      relations: { user: true },
      select: { id: true, user: { id: true } },
    });
    return [...new Set([riderId, ...orders.map((order) => order.user.id)])];
  }
  async canWatch(viewerId: number, riderId: number) {
    return (await this.watcherIds(riderId)).includes(viewerId);
  }
  async updateLocation(id: number, idDevice: string, position: number[]) {
    const result = await this.sessions.update(
      { user: { id }, idDevice },
      { location: position.join(',') },
    );
    return result.affected === 1;
  }
}
