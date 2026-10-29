import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { DataSource } from 'typeorm';
import request from 'supertest';
import { configureApp } from '../src/configure-app';
import { EmailService } from '../src/email/email.service';
import { NotificationService } from '../src/notification/notification.service';

describe('Full application composition with isolated infrastructure', () => {
  let app: INestApplication;
  const environment = {
    NODE_ENV: 'test',
    DB_HOST: '127.0.0.1',
    DB_PORT: '5432',
    DB_USERNAME: 'isolated',
    DB_PASSWORD: 'isolated',
    DB_NAME: 'isolated',
    DB_SYNCHRONIZE: 'false',
    JWT_SECRET: 'isolated-full-application-test-key',
    PORT: '3000',
  };
  const previous = Object.fromEntries(
    Object.keys(environment).map((key) => [key, process.env[key]]),
  );
  const database = {
    options: { type: 'postgres' },
    entityMetadatas: [],
    getRepository: jest.fn(() => ({})),
    manager: {},
    isInitialized: false,
  };

  beforeAll(async () => {
    Object.assign(process.env, environment);
    // Import only after the isolated environment is set; ConfigModule never reads .env.
    const { AppModule } = require('../src/app.module');
    const module = await Test.createTestingModule({ imports: [AppModule] })
      .overrideProvider(DataSource)
      .useValue(database)
      .overrideProvider(EmailService)
      .useValue({ sendPassword: jest.fn() })
      .overrideProvider(NotificationService)
      .useValue({ notify: jest.fn(), notifyOrder: jest.fn() })
      .compile();
    app = module.createNestApplication();
    configureApp(app);
    await app.init();
  });

  afterAll(async () => {
    if (app) await app.close();
    for (const [key, value] of Object.entries(previous)) {
      if (value === undefined) delete process.env[key];
      else process.env[key] = value;
    }
  });

  it('resolves all modules, repositories and gateways without external connections', () => {
    expect(database.getRepository).toHaveBeenCalled();
    expect(app.get(DataSource)).toBe(database);
  });

  it('registers real protected routes with the production bootstrap configuration', async () => {
    await request(app.getHttpServer())
      .get('/api/client/market/orders')
      .expect(401);
    await request(app.getHttpServer()).get('/api/admin/company').expect(401);
  });
});
