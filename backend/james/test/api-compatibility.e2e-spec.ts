import { INestApplication } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtModule, JwtService } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { Test } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import request from 'supertest';
import { CompanyController } from '../src/admin/company/company.controller';
import { CompanyService } from '../src/admin/company/company.service';
import { AuthController } from '../src/auth/auth.controller';
import { AuthService } from '../src/auth/auth.service';
import { Session } from '../src/auth/entities/session.entity';
import { User } from '../src/auth/entities/user.entity';
import { JwtStrategy } from '../src/auth/strategies/jwt.strategy';
import { MarketController } from '../src/client/market/market.controller';
import { MarketService } from '../src/client/market/market.service';
import { configureApp } from '../src/configure-app';

describe('API compatibility across NestJS versions (isolated infrastructure)', () => {
  let app: INestApplication;
  let jwt: JwtService;
  const secret = 'isolated-test-secret-does-not-use-project-env';
  const idDevice = '0a824db1-708e-4bf1-a50d-76c441073069';
  const client = {
    id: 1,
    email: 'client@example.test',
    fullName: 'Client',
    roles: ['client'],
    isActive: true,
  };
  const admin = {
    ...client,
    id: 2,
    email: 'admin@example.test',
    roles: ['admin'],
  };
  const users = { findOneBy: jest.fn() };
  const sessions = { findOneBy: jest.fn() };
  const auth = { login: jest.fn() };
  const market = { findCompanies: jest.fn(), findOrders: jest.fn() };
  const companies = { findAll: jest.fn(), update: jest.fn() };

  beforeAll(async () => {
    const module = await Test.createTestingModule({
      imports: [
        PassportModule.register({ defaultStrategy: 'jwt' }),
        JwtModule.register({ secret }),
      ],
      controllers: [AuthController, MarketController, CompanyController],
      providers: [
        JwtStrategy,
        {
          provide: ConfigService,
          useValue: new ConfigService({ JWT_SECRET: secret }),
        },
        { provide: getRepositoryToken(User), useValue: users },
        { provide: getRepositoryToken(Session), useValue: sessions },
        { provide: AuthService, useValue: auth },
        { provide: MarketService, useValue: market },
        { provide: CompanyService, useValue: companies },
      ],
    }).compile();
    app = module.createNestApplication();
    configureApp(app);
    await app.init();
    jwt = module.get(JwtService);
  });

  beforeEach(() => {
    jest.resetAllMocks();
    users.findOneBy.mockImplementation(async ({ id }) =>
      id === 2 ? admin : client,
    );
    sessions.findOneBy.mockResolvedValue({ id: 1, idDevice });
    market.findCompanies.mockResolvedValue({ companies: [] });
    market.findOrders.mockResolvedValue([]);
    companies.findAll.mockResolvedValue([]);
    companies.update.mockImplementation(async (id, dto) => ({ id, ...dto }));
  });

  afterAll(async () => {
    if (app) await app.close();
  });

  const token = (id = 1) => jwt.sign({ id, email: client.email, idDevice });

  it('preserves the login route and response contract', async () => {
    auth.login.mockResolvedValue({ id: 1, token: 'test-token' });
    await request(app.getHttpServer())
      .post('/api/auth/login')
      .send({ email: client.email, password: 'example-password', idDevice })
      .expect(201, { id: 1, token: 'test-token' });
  });

  it('rejects malformed login data before invoking the service', async () => {
    await request(app.getHttpServer())
      .post('/api/auth/login')
      .send({ email: 'invalid', password: '123', idDevice: 'invalid' })
      .expect(400);
    expect(auth.login).not.toHaveBeenCalled();
  });

  it('rejects fields outside the public DTO', async () => {
    await request(app.getHttpServer())
      .post('/api/auth/login')
      .send({
        email: client.email,
        password: 'example-password',
        idDevice,
        roles: ['admin'],
      })
      .expect(400);
    expect(auth.login).not.toHaveBeenCalled();
  });

  it('keeps numeric query conversion for market searches', async () => {
    await request(app.getHttpServer())
      .get('/api/client/market/companies')
      .query({ latitude: '-0.2', longitude: '-78.5', limit: '10', offset: '0' })
      .expect(200, { companies: [] });
    expect(market.findCompanies).toHaveBeenCalledWith(
      expect.objectContaining({
        latitude: -0.2,
        longitude: -78.5,
        limit: 10,
        offset: 0,
      }),
    );
  });

  it('rejects invalid geographic coordinates', async () => {
    await request(app.getHttpServer())
      .get('/api/client/market/companies')
      .query({ latitude: '91', longitude: '-78.5' })
      .expect(400);
    expect(market.findCompanies).not.toHaveBeenCalled();
  });

  it('requires authentication for customer orders', async () => {
    await request(app.getHttpServer())
      .get('/api/client/market/orders')
      .expect(401);
    expect(market.findOrders).not.toHaveBeenCalled();
  });

  it('accepts a signed JWT with an active session', async () => {
    await request(app.getHttpServer())
      .get('/api/client/market/orders')
      .auth(token(), { type: 'bearer' })
      .expect(200, []);
  });

  it('rejects expired JWTs', async () => {
    const expired = jwt.sign(
      { id: 1, email: client.email, idDevice },
      { expiresIn: -1 },
    );
    await request(app.getHttpServer())
      .get('/api/client/market/orders')
      .auth(expired, { type: 'bearer' })
      .expect(401);
  });

  it('rejects revoked sessions', async () => {
    sessions.findOneBy.mockResolvedValue(null);
    await request(app.getHttpServer())
      .get('/api/client/market/orders')
      .auth(token(), { type: 'bearer' })
      .expect(401);
  });

  it('rejects inactive users', async () => {
    users.findOneBy.mockResolvedValue({ ...client, isActive: false });
    await request(app.getHttpServer())
      .get('/api/client/market/orders')
      .auth(token(), { type: 'bearer' })
      .expect(401);
  });

  it('forbids customers from accessing admin endpoints', async () => {
    await request(app.getHttpServer())
      .get('/api/admin/company')
      .auth(token(), { type: 'bearer' })
      .expect(403);
    expect(companies.findAll).not.toHaveBeenCalled();
  });

  it('preserves optional fields in mapped update DTOs', async () => {
    await request(app.getHttpServer())
      .patch('/api/admin/company/7')
      .auth(token(2), { type: 'bearer' })
      .send({ name: 'Updated store' })
      .expect(200, { id: 7, name: 'Updated store' });
  });

  it('validates mapped update DTO fields', async () => {
    await request(app.getHttpServer())
      .patch('/api/admin/company/7')
      .auth(token(2), { type: 'bearer' })
      .send({ email: 'invalid' })
      .expect(400);
    expect(companies.update).not.toHaveBeenCalled();
  });

  it('preserves integer route validation', async () => {
    await request(app.getHttpServer())
      .patch('/api/admin/company/invalid')
      .auth(token(2), { type: 'bearer' })
      .send({ name: 'Updated store' })
      .expect(400);
  });

  it('does not expose routes outside the api prefix', async () => {
    await request(app.getHttpServer())
      .get('/client/market/companies')
      .expect(404);
  });
});
