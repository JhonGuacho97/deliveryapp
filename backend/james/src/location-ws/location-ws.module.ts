import { Module } from '@nestjs/common';
import { LocationWsService } from './location-ws.service';
import { LocationWsGateway } from './location-ws.gateway';
import { AuthModule } from '../auth/auth.module';
import { Session } from 'src/auth/entities/session.entity';
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from 'src/auth/entities/user.entity';
import { Order } from 'src/client/market/entities/order.entity';

@Module({
  providers: [LocationWsGateway, LocationWsService],
  imports: [TypeOrmModule.forFeature([User, Session, Order]), AuthModule],
})
export class LocationWsModule {}
