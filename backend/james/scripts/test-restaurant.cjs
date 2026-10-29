const assert = require('node:assert/strict');
const { randomBytes, randomUUID } = require('node:crypto');
const { Client } = require('pg');
const { DataSource } = require('typeorm');
const source = require('../dist/database/data-source').default;

async function main() {
  if (
    process.env.NODE_ENV === 'production' ||
    !['localhost', '127.0.0.1', '::1'].includes(source.options.host)
  )
    throw Error('Restaurant checks require local PostgreSQL');
  const name = `delivery_restaurant_test_${process.pid}_${randomBytes(4).toString('hex')}`;
  const options = source.options;
  const admin = new Client({
    host: options.host,
    port: options.port,
    user: options.username,
    password: options.password,
    database: 'postgres',
  });
  const database = new DataSource({
    ...options,
    database: name,
    logging: false,
  });
  let app,
    created = false,
    checks = 0;
  await admin.connect();
  try {
    await admin.query(
      `CREATE DATABASE "${name}" ENCODING 'UTF8' TEMPLATE template0`,
    );
    created = true;
    await database.initialize();
    await database.runMigrations();
    Object.assign(process.env, {
      NODE_ENV: 'test',
      DB_NAME: name,
      DB_SYNCHRONIZE: 'false',
      EXTERNAL_SERVICES_ENABLED: 'false',
    });
    const { NestFactory } = require('@nestjs/core');
    const { AppModule } = require('../dist/app.module');
    const { configureApp } = require('../dist/configure-app');
    app = await NestFactory.create(AppModule, { logger: ['error'] });
    configureApp(app);
    await app.listen(0, '127.0.0.1');
    const base = await app.getUrl();
    const entity = (path) => require('../dist/' + path);
    const { User } = entity('auth/entities/user.entity');
    const { Company } = entity('admin/company/entities/company.entity');
    const { Store } = entity('admin/store/entities/store.entity');
    const { Product } = entity('admin/product/entities/product.entity');
    const { HoursOperation } = entity(
      'admin/hours-peration/entities/hours-peration.entity',
    );
    const { Order } = entity('client/market/entities/order.entity');
    const { Balance } = entity('client/balance/entities/balance.entity');
    const save = (type, data) =>
      database.manager.save(type, database.manager.create(type, data));
    const password = randomBytes(16).toString('hex');
    const hash = await require('bcrypt').hash(password, 4);
    async function user(role, suffix) {
      const record = await save(User, {
        fullName: role,
        email: suffix + '@example.test',
        password: hash,
        roles: [role],
      });
      const idDevice = randomUUID();
      const login = await request('POST', '/auth/login', 201, null, {
        email: record.email,
        password,
        idDevice,
      });
      return { ...record, token: login.token, idDevice };
    }
    async function request(method, route, status, token, body) {
      const response = await fetch(base + '/api' + route, {
        method,
        signal: AbortSignal.timeout(10000),
        headers: {
          'Content-Type': 'application/json',
          ...(token ? { Authorization: 'Bearer ' + token } : {}),
        },
        body: body === undefined ? undefined : JSON.stringify(body),
      });
      const data = await response.json();
      assert.equal(
        response.status,
        status,
        method + ' ' + route + ' ' + JSON.stringify(data),
      );
      checks++;
      return data;
    }
    const manager = await user('manager', 'manager');
    const other = await user('manager', 'other');
    const client = await user('client', 'client');
    const rider = await user('deliveryman', 'rider');
    const location = { x: -0.2, y: -78.5 };
    const company = await save(Company, {
      name: 'Fixture restaurant',
      address: 'Calle 1',
      contact: '0900000000',
      email: 'fixture@example.test',
      location: { ...location },
      user: manager,
    });
    const store = await save(Store, {
      name: 'Fixture kitchen',
      address: 'Calle 1',
      contact: '0900000000',
      email: 'fixture@example.test',
      location: { ...location },
      company,
      user: manager,
    });
    const product = await save(Product, {
      name: 'Fixture bowl',
      description: 'Fixture description',
      image: '',
      price: 6.5,
      company,
    });
    const hour = await save(HoursOperation, {
      store,
      day: 1,
      open: '08:00:00',
      close: '22:00:00',
    });
    await save(Balance, { userId: rider.id, user: rider, balance: 100 });
    await request('PATCH', '/deliveryman/petition/activate', 200, rider.token, {
      idDevice: rider.idDevice,
      isOnline: true,
      latitude: location.x,
      longitude: location.y,
    });
    const order = () =>
      save(Order, {
        note: 'Casa',
        address: 'Calle 2',
        products: [
          {
            id: product.id,
            name: product.name,
            description: product.description,
            image: '',
            price: 6.5,
            number: 1,
            total: 6.5,
            note: 'Sin cebolla',
          },
        ],
        deliveryFee: 1.5,
        total: 8,
        payment: 5001,
        location: { ...location },
        orderedAt: new Date(),
        store,
        user: client,
      });
    const first = await order();
    const second = await order();
    await request('PATCH', `/manager/request/${first.id}/accept`, 401, null, {
      preparationMinutes: 25,
    });
    await request(
      'PATCH',
      `/manager/request/${first.id}/accept`,
      403,
      client.token,
      { preparationMinutes: 25 },
    );
    await request('GET', `/manager/request/id/${first.id}`, 404, other.token);
    await request(
      'PATCH',
      `/manager/request/${first.id}/accept`,
      404,
      other.token,
      { preparationMinutes: 25 },
    );
    await request(
      'GET',
      `/manager/store/products/${company.id}`,
      404,
      other.token,
    );
    await request(
      'PATCH',
      `/manager/store/product/${product.id}`,
      404,
      other.token,
      { price: 9 },
    );
    await request('POST', '/manager/store/product', 404, other.token, {
      name: 'Foreign item',
      description: 'Foreign description',
      image: '',
      type: 1,
      price: 2,
      company: { id: company.id },
    });
    await request('GET', `/manager/store/hours/${store.id}`, 404, other.token);
    await request(
      'PATCH',
      `/manager/store/hours/${hour.id}`,
      404,
      other.token,
      { open: '09:00:00', close: '21:00:00' },
    );
    await request(
      'GET',
      '/manager/request/ordered-at/not-a-date',
      400,
      manager.token,
    );
    await request(
      'PATCH',
      `/manager/store/hours/${hour.id}`,
      400,
      manager.token,
      { open: '99:00:00', close: '21:00:00' },
    );
    for (const minutes of [0, 121, 2.5, '25', undefined])
      await request(
        'PATCH',
        `/manager/request/${first.id}/accept`,
        400,
        manager.token,
        { preparationMinutes: minutes },
      );
    await request(
      'PATCH',
      `/manager/request/${first.id}/ready`,
      409,
      manager.token,
    );
    await request(
      'PATCH',
      `/deliveryman/petition/apply/${first.id}`,
      409,
      rider.token,
    );
    const accepted = await request(
      'PATCH',
      `/manager/request/${first.id}/accept`,
      200,
      manager.token,
      { preparationMinutes: 25 },
    );
    assert.equal(accepted.request.status, 1);
    assert.equal(accepted.request.preparationStatus, 'preparing');
    assert.equal(accepted.request.preparationMinutes, 25);
    assert(accepted.request.acceptedAt);
    const retry = await request(
      'PATCH',
      `/manager/request/${first.id}/accept`,
      200,
      manager.token,
      { preparationMinutes: 25 },
    );
    assert.equal(retry.request.acceptedAt, accepted.request.acceptedAt);
    await request(
      'PATCH',
      `/manager/request/${first.id}/accept`,
      409,
      manager.token,
      { preparationMinutes: 35 },
    );
    await request(
      'PATCH',
      `/deliveryman/petition/apply/${first.id}`,
      200,
      rider.token,
    );
    await request(
      'PATCH',
      `/deliveryman/petition/collect/${first.id}`,
      409,
      rider.token,
    );
    const ready = await request(
      'PATCH',
      `/manager/request/${first.id}/ready`,
      200,
      manager.token,
    );
    assert.equal(ready.request.status, 100);
    assert.equal(ready.request.preparationStatus, 'ready');
    assert(ready.request.readyAt);
    const readyRetry = await request(
      'PATCH',
      `/manager/request/${first.id}/ready`,
      200,
      manager.token,
    );
    assert.equal(ready.request.readyAt, readyRetry.request.readyAt);
    const collected = await request(
      'PATCH',
      `/deliveryman/petition/collect/${first.id}`,
      200,
      rider.token,
    );
    assert.equal(collected.petition.status, 101);
    await request(
      'PATCH',
      `/manager/request/${first.id}/ready`,
      409,
      manager.token,
    );
    const clientView = await request(
      'GET',
      `/client/market/order/${first.id}`,
      200,
      client.token,
    );
    assert.equal(clientView.order.preparationStatus, 'ready');
    const races = await Promise.all(
      [15, 35].map((preparationMinutes) =>
        fetch(base + `/api/manager/request/${second.id}/accept`, {
          method: 'PATCH',
          headers: {
            Authorization: 'Bearer ' + manager.token,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ preparationMinutes }),
        }),
      ),
    );
    assert.deepEqual(races.map((r) => r.status).sort(), [200, 409]);
    checks++;
    await request(
      'GET',
      `/manager/store/products/${company.id}`,
      200,
      manager.token,
    );
    await request('POST', '/manager/store/product', 400, manager.token, {
      name: product.name,
      description: product.description,
      image: '',
      type: 1,
      price: 6.5,
      company: { id: company.id },
    });
    await request(
      'PATCH',
      `/manager/store/product/${product.id}`,
      400,
      manager.token,
      { company: { id: company.id } },
    );
    await request(
      'PATCH',
      `/manager/store/product/${product.id}`,
      200,
      manager.token,
      { price: 7.5 },
    );
    await request(
      'PATCH',
      `/manager/store/hours/${hour.id}`,
      200,
      manager.token,
      { open: '09:00:00', close: '21:00:00' },
    );
    const legacy = await order();
    await database
      .getRepository(Order)
      .update(legacy.id, { preparationStatus: null });
    await request(
      'PATCH',
      `/deliveryman/petition/apply/${legacy.id}`,
      200,
      rider.token,
    );
    await request(
      'PATCH',
      `/deliveryman/petition/collect/${legacy.id}`,
      200,
      rider.token,
    );
    console.log(
      JSON.stringify({
        status: 'passed',
        checks,
        database: 'disposable',
        coverage: [
          'ownership',
          'DTO validation',
          'accept/ready',
          'idempotency',
          'concurrency',
          'pickup gate',
          'legacy orders',
          'client status',
          'menu and hours',
        ],
      }),
    );
  } finally {
    if (app) await app.close();
    if (database.isInitialized) await database.destroy();
    if (created) await admin.query(`DROP DATABASE "${name}" WITH (FORCE)`);
    await admin.end();
  }
}
main().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
