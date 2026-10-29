import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { databaseOptions } from './config/database.config';
import { validateEnvironment } from './config/environment';

import { TypeOrmModule } from '@nestjs/typeorm';

import { CommonModule } from './common/common.module';
import { AuthModule } from './auth/auth.module';

import { CompanyModule } from './admin/company/company.module';
import { StoreModule } from './admin/store/store.module';
import { ProductModule } from './admin/product/product.module';
import { CategoryModule } from './admin/category/category.module';

import { MarketModule } from './client/market/market.module';
import { CompanyCategoryModule } from './admin/company-category/company-category.module';
import { HoursOperationModule } from './admin/hours-peration/hours-peration.module';
import { PetitionModule } from './deliveryman/petition/petition.module';
import { ChatModule } from './chat/chat.module';
import { LocationWsModule } from './location-ws/location-ws.module';
import { AddressModule } from './client/address/address.module';
import { NotificationModule } from './notification/notification.module';
import { BalanceModule } from './client/balance/balance.module';
import { EmailModule } from './email/email.module';
import { EnrollmentModule } from './manager/enrollment/enrollment.module';
import { StoreManagerModule } from './manager/store-manager/store.manager.module';
import { PaymentsModule } from './client/payments/payments.module';
import { CreditModule } from './admin/credit/credit.module';
import { RequestModule } from './manager/request/request.module';


@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      ignoreEnvFile: process.env.NODE_ENV === 'test',
      validate: validateEnvironment,
    }),
    TypeOrmModule.forRootAsync({
      inject: [ConfigService],
      useFactory: databaseOptions,
    }),
    CompanyModule,
    CommonModule,
    ProductModule,
    AuthModule,
    StoreModule,
    MarketModule,
    CategoryModule,
    CompanyCategoryModule,
    HoursOperationModule,
    PetitionModule,
    ChatModule,
    LocationWsModule,
    AddressModule,
    NotificationModule,
    BalanceModule,
    EmailModule,
    EnrollmentModule,
    StoreManagerModule,
    PaymentsModule,
    CreditModule,
    RequestModule,
  ],
  controllers: [],
  providers: [],
})
export class AppModule { }
