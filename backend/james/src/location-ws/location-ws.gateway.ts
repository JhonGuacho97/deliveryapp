import { JwtService } from '@nestjs/jwt';
import {
  ConnectedSocket,
  MessageBody,
  OnGatewayConnection,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { Socket, Server } from 'socket.io';
import { JwtPayload } from 'src/auth/interfaces';
import { LocationWsService } from './location-ws.service';

@WebSocketGateway({ cors: { origin: '*' }, transports: ['websocket'] })
export class LocationWsGateway implements OnGatewayConnection {
  @WebSocketServer() server: Server;
  constructor(
    private readonly locations: LocationWsService,
    private readonly jwt: JwtService,
  ) {}
  async handleConnection(socket: Socket) {
    try {
      const payload = this.jwt.verify<JwtPayload>(
        socket.handshake.headers.auth as string,
      );
      await this.locations.registerUser(socket, payload.id, payload.idDevice);
      const rider = Number(socket.handshake.headers.iduserdeliverymen);
      if (Number.isSafeInteger(rider) && rider > 0) {
        if (!(await this.locations.canWatch(payload.id, rider)))
          throw new Error('Delivery unavailable');
        await socket.join('courier:' + rider + ':viewer:' + payload.id);
      }
    } catch (_) {
      socket.disconnect();
    }
  }
  @SubscribeMessage('l')
  async handleEvent(
    @ConnectedSocket() socket: Socket,
    @MessageBody() data: { id: number; p: number[] },
  ) {
    const actor = socket.data.actor;
    if (
      !socket['isAuth'] ||
      !actor?.roles.includes('deliveryman') ||
      data?.id !== actor.id
    )
      return;
    if (
      !Array.isArray(data.p) ||
      data.p.length !== 2 ||
      !data.p.every(Number.isFinite) ||
      Math.abs(data.p[0]) > 90 ||
      Math.abs(data.p[1]) > 180
    )
      return;
    if (
      !(await this.locations.updateLocation(actor.id, actor.idDevice, data.p))
    )
      return;
    // Re-evaluate the current assignment on every update; finished orders lose access.
    for (const viewer of await this.locations.watcherIds(actor.id))
      this.server
        .to('courier:' + actor.id + ':viewer:' + viewer)
        .emit('l', data.p);
  }
}
