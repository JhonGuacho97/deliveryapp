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
    throw Error('Courier checks require local PostgreSQL');
  const name = `delivery_courier_test_${process.pid}_${randomBytes(4).toString('hex')}`;
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
    app = await NestFactory.create(AppModule, { logger: false });
    configureApp(app);
    await app.listen(0, '127.0.0.1');
    const base = (await app.getUrl()) + '/api';
    const { User } = require('../dist/auth/entities/user.entity');
    const {
      Company,
    } = require('../dist/admin/company/entities/company.entity');
    const { Store } = require('../dist/admin/store/entities/store.entity');
    const { Order } = require('../dist/client/market/entities/order.entity');
    const {
      Balance,
    } = require('../dist/client/balance/entities/balance.entity');
    const save = (type, data) =>
      database.manager.save(type, database.manager.create(type, data));
    const password = randomBytes(16).toString('hex');
    const hash = await require('bcrypt').hash(password, 4);
    async function call(method, path, actor, body) {
      return fetch(base + path, {
        method,
        signal: AbortSignal.timeout(10000),
        headers: {
          'Content-Type': 'application/json',
          ...(actor ? { Authorization: 'Bearer ' + actor.token } : {}),
        },
        body: body === undefined ? undefined : JSON.stringify(body),
      });
    }
    async function request(method, path, status, actor, body) {
      const response = await call(method, path, actor, body);
      const data = await response.json();
      assert.equal(
        response.status,
        status,
        method + ' ' + path + ' ' + JSON.stringify(data),
      );
      checks++;
      return data;
    }
    async function actor(role, suffix, balance = 100) {
      const user = await save(User, {
        fullName: suffix,
        email: suffix + '@example.test',
        password: hash,
        roles: [role],
        phone: suffix === 'client' ? '0990000002' : null,
      });
      await save(Balance, { userId: user.id, user, balance });
      const idDevice = randomUUID();
      const login = await request('POST', '/auth/login', 201, null, {
        email: user.email,
        password,
        idDevice,
      });
      return { ...user, token: login.token, idDevice };
    }
    const manager = await actor('manager', 'manager');
    const client = await actor('client', 'client');
    const a = await actor('deliveryman', 'rider-a');
    const b = await actor('deliveryman', 'rider-b');
    const point = { x: -4.0236715, y: -79.1978733 };
    const destination = { x: -4.0242, y: -79.199 };
    const company = await save(Company, {
      name: 'Courier fixture',
      address: 'Calle 1',
      contact: '0990000001',
      email: manager.email,
      location: { ...point },
      user: manager,
    });
    const store = await save(Store, {
      name: 'Courier fixture',
      address: 'Calle 1',
      contact: '0990000001',
      email: manager.email,
      location: { ...point },
      company,
      user: manager,
    });
    const order = (extra = {}) =>
      save(Order, {
        note: 'Fixture',
        address: 'Calle 2',
        products: [],
        deliveryFee: 1.5,
        total: 8,
        payment: 5001,
        location: { ...destination },
        orderedAt: new Date(),
        store,
        user: client,
        preparationStatus: 'ready',
        ...extra,
      });
    const first = await order();
    await request(
      'GET',
      `/deliveryman/petition/near?idDevice=${a.idDevice}`,
      401,
      null,
    );
    await request(
      'GET',
      `/deliveryman/petition/near?idDevice=${a.idDevice}`,
      403,
      client,
    );
    const offline = await request(
      'GET',
      `/deliveryman/petition/near?idDevice=${a.idDevice}`,
      200,
      a,
    );
    assert.equal(offline.isOnline, false);
    assert.equal(offline.petitions.length, 0);
    await request('PATCH', `/deliveryman/petition/apply/${first.id}`, 409, a);
    await request('GET', `/deliveryman/petition/id/${first.id}`, 404, a);
    await request(
      'GET',
      `/deliveryman/petition/near?idDevice=${b.idDevice}`,
      400,
      a,
    );
    await request('PATCH', '/deliveryman/petition/activate', 400, a, {
      idDevice: b.idDevice,
      isOnline: true,
      latitude: point.x,
      longitude: point.y,
    });
    await request('PATCH', '/deliveryman/petition/activate', 400, a, {
      idDevice: a.idDevice,
      isOnline: true,
      latitude: 999,
      longitude: point.y,
    });
    const connect = (actor) =>
      request('PATCH', '/deliveryman/petition/activate', 200, actor, {
        idDevice: actor.idDevice,
        isOnline: true,
        latitude: point.x,
        longitude: point.y,
      });
    await connect(a);
    await connect(b);
    const feed = await request(
      'GET',
      `/deliveryman/petition/near?idDevice=${a.idDevice}`,
      200,
      a,
    );
    assert.equal(feed.petitions[0].estimatedProfit, 1.28);
    assert.equal(feed.petitions[0].pickupDistanceMeters, 0);
    assert(
      feed.petitions[0].tripDistanceMeters > 0 &&
        feed.petitions[0].tripDistanceMeters < 1000,
    );
    assert.equal(feed.petitions[0].user.phone, '');
    const claimed = await request(
      'PATCH',
      `/deliveryman/petition/apply/${first.id}`,
      200,
      a,
    );
    assert.equal(claimed.petition.status, 100);
    assert.equal(claimed.petition.deliverymanProfit, 1.28);
    assert.equal(claimed.petition.deliveryAppProfit, 0.22);
    assert(claimed.petition.assignedAt);
    assert.equal(claimed.petition.user.phone, '0990000002');
    await request('PATCH', `/deliveryman/petition/apply/${first.id}`, 200, a);
    assert.equal(
      (await database.getRepository(Balance).findOneBy({ userId: a.id }))
        .balance,
      99.78,
    );
    for (const operation of ['collect', 'deliver', 'cancel'])
      await request(
        'PATCH',
        `/deliveryman/petition/${operation}/${first.id}`,
        404,
        b,
        operation === 'deliver' ? {} : undefined,
      );
    await request('GET', `/deliveryman/petition/id/${first.id}`, 404, b);
    await request('PATCH', `/deliveryman/petition/apply/${first.id}`, 409, b);
    await request(
      'PATCH',
      `/deliveryman/petition/deliver/${first.id}`,
      409,
      a,
      {},
    );
    const picked = await request(
      'PATCH',
      `/deliveryman/petition/collect/${first.id}`,
      200,
      a,
    );
    assert(picked.petition.collectedAt);
    await request('PATCH', `/deliveryman/petition/collect/${first.id}`, 200, a);
    await request('PATCH', `/deliveryman/petition/cancel/${first.id}`, 409, a);
    const delivered = await request(
      'PATCH',
      `/deliveryman/petition/deliver/${first.id}`,
      200,
      a,
      {},
    );
    assert.equal(delivered.petition.status, 200);
    assert(delivered.petition.deliveredAt);
    assert.equal(delivered.petition.scoreDeliveryman, null);
    const retry = await request(
      'PATCH',
      `/deliveryman/petition/deliver/${first.id}`,
      200,
      a,
      {},
    );
    assert.equal(retry.petition.deliveredAt, delivered.petition.deliveredAt);
    const day = new Intl.DateTimeFormat('en-CA', {
      timeZone: 'America/Guayaquil',
    }).format(new Date());
    const earnings = await request(
      'GET',
      `/deliveryman/petition/earnings/${day}`,
      200,
      a,
    );
    assert.equal(earnings.completedCount, 1);
    assert.equal(earnings.earnings, 1.28);
    assert.equal(earnings.operatingBalance, 99.78);
    await request('GET', '/deliveryman/petition/earnings/2026-99-99', 400, a);
    const waiting = await order({ preparationStatus: 'preparing' });
    await request('PATCH', `/deliveryman/petition/apply/${waiting.id}`, 200, a);
    await request(
      'PATCH',
      `/deliveryman/petition/collect/${waiting.id}`,
      409,
      a,
    );
    await request(
      'PATCH',
      `/manager/request/${waiting.id}/ready`,
      200,
      manager,
    );
    await request(
      'PATCH',
      `/deliveryman/petition/collect/${waiting.id}`,
      200,
      a,
    );
    const race = await order();
    const claims = await Promise.all(
      [a, b].map((actor) =>
        call('PATCH', `/deliveryman/petition/apply/${race.id}`, actor),
      ),
    );
    assert.deepEqual(claims.map((r) => r.status).sort(), [200, 409]);
    checks++;
    const owner = (
      await database
        .getRepository(Order)
        .findOne({ where: { id: race.id }, relations: { deliveryman: true } })
    ).deliveryman.id;
    assert([a.id, b.id].includes(owner));
    const concurrent = [await order(), await order()];
    await Promise.all(
      concurrent.map((o) =>
        request('PATCH', `/deliveryman/petition/apply/${o.id}`, 200, b),
      ),
    );
    const cancelled = await order();
    const beforeCancel = (
      await database.getRepository(Balance).findOneBy({ userId: a.id })
    ).balance;
    await request(
      'PATCH',
      `/deliveryman/petition/apply/${cancelled.id}`,
      200,
      a,
    );
    await request(
      'PATCH',
      `/deliveryman/petition/cancel/${cancelled.id}`,
      200,
      a,
    );
    await request(
      'PATCH',
      `/deliveryman/petition/cancel/${cancelled.id}`,
      200,
      a,
    );
    assert.equal(
      (await database.getRepository(Balance).findOneBy({ userId: a.id }))
        .balance,
      beforeCancel,
    );
    const paid = await order({ payment: 6002 });
    const beforePaid = await database
      .getRepository(Balance)
      .findOneBy({ userId: a.id });
    const customerBefore = (
      await database.getRepository(Balance).findOneBy({ userId: client.id })
    ).money;
    await request('PATCH', `/deliveryman/petition/apply/${paid.id}`, 200, a);
    assert.equal(
      (await database.getRepository(Balance).findOneBy({ userId: a.id }))
        .amount,
      beforePaid.amount + 1.28,
    );
    await request('PATCH', `/deliveryman/petition/cancel/${paid.id}`, 200, a);
    await request('PATCH', `/deliveryman/petition/cancel/${paid.id}`, 200, a);
    assert.equal(
      (await database.getRepository(Balance).findOneBy({ userId: a.id }))
        .amount,
      beforePaid.amount,
    );
    assert.equal(
      (await database.getRepository(Balance).findOneBy({ userId: client.id }))
        .money,
      customerBefore + 8,
    );
    const poor = await actor('deliveryman', 'rider-poor', 0);
    await connect(poor);
    const tooExpensive = await order();
    await request(
      'PATCH',
      `/deliveryman/petition/apply/${tooExpensive.id}`,
      400,
      poor,
    );
    assert.equal(
      (await database.getRepository(Order).findOneBy({ id: tooExpensive.id }))
        .status,
      1,
    );
    const scarce = [await order(), await order()];
    await database
      .getRepository(Balance)
      .update({ userId: poor.id }, { balance: 0.22 });
    const scarceClaims = await Promise.all(
      scarce.map((o) =>
        call('PATCH', `/deliveryman/petition/apply/${o.id}`, poor),
      ),
    );
    assert.deepEqual(scarceClaims.map((r) => r.status).sort(), [200, 400]);
    assert.equal(
      (await database.getRepository(Balance).findOneBy({ userId: poor.id }))
        .balance,
      0,
    );
    checks++;
    const rollback = await order();
    const balanceBeforeRollback = await database
      .getRepository(Balance)
      .findOneBy({ userId: a.id });
    await database.query(
      `CREATE FUNCTION reject_fixture_assignment() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN IF NEW.id = ${rollback.id} AND NEW.status = 100 THEN RAISE EXCEPTION 'fixture assignment failure'; END IF; RETURN NEW; END $$`,
    );
    await database.query(
      'CREATE TRIGGER reject_fixture_assignment BEFORE UPDATE ON public."order" FOR EACH ROW EXECUTE FUNCTION reject_fixture_assignment()',
    );
    await request(
      'PATCH',
      `/deliveryman/petition/apply/${rollback.id}`,
      500,
      a,
    );
    assert.equal(
      (await database.getRepository(Balance).findOneBy({ userId: a.id }))
        .balance,
      balanceBeforeRollback.balance,
    );
    assert.equal(
      (await database.getRepository(Order).findOneBy({ id: rollback.id }))
        .status,
      1,
    );
    await database.query(
      'DROP TRIGGER reject_fixture_assignment ON public."order"',
    );
    await database.query('DROP FUNCTION reject_fixture_assignment()');
    const secondDevice = randomUUID();
    await request('POST', '/auth/login', 201, null, {
      email: a.email,
      password,
      idDevice: secondDevice,
    });
    const {
      LocationWsService,
    } = require('../dist/location-ws/location-ws.service');
    const locations = app.get(LocationWsService);
    await locations.updateLocation(a.id, a.idDevice, [-4.03, -79.2]);
    const { Session } = require('../dist/auth/entities/session.entity');
    const sessions = await database
      .getRepository(Session)
      .find({ where: { user: { id: a.id } } });
    assert.equal(
      sessions.find((s) => s.idDevice === secondDevice).location,
      null,
    );
    assert.equal(
      sessions.find((s) => s.idDevice === a.idDevice).location.x,
      -4.03,
    );
    checks++;
    const watchers = await locations.watcherIds(a.id);
    assert(watchers.includes(client.id));
    assert(!(await locations.canWatch(b.id, a.id)));
    checks++;
    const existingIncome = await request(
      'GET',
      `/deliveryman/petition/earnings/${day}`,
      200,
      a,
    );
    assert.equal(existingIncome.deliveries.length, 1);
    await order({
      status: 300,
      deliveryman: a,
      deliveredAt: new Date(),
      cancelledAt: new Date(),
      deliverymanProfit: 2,
    });
    const afterCancelled = await request(
      'GET',
      `/deliveryman/petition/earnings/${day}`,
      200,
      a,
    );
    assert.equal(afterCancelled.earnings, existingIncome.earnings);
    const legacy = await order({ preparationStatus: null });
    await request('PATCH', `/deliveryman/petition/apply/${legacy.id}`, 200, a);
    await request(
      'PATCH',
      `/deliveryman/petition/collect/${legacy.id}`,
      200,
      a,
    );
    await request('PATCH', '/deliveryman/petition/activate', 200, a, {
      idDevice: a.idDevice,
      isOnline: false,
      latitude: point.x,
      longitude: point.y,
    });
    const remaining = await request(
      'GET',
      `/deliveryman/petition/near?idDevice=${a.idDevice}`,
      200,
      a,
    );
    assert.equal(remaining.isOnline, false);
    assert(remaining.petitions.every((o) => o.isAssignedToMe));
    await request(
      'PATCH',
      `/deliveryman/petition/deliver/${legacy.id}`,
      200,
      a,
      {},
    );
    console.log(
      JSON.stringify({
        status: 'passed',
        checks,
        coverage: [
          'device isolation',
          'availability',
          'ownership',
          'distance',
          'commission',
          'idempotency',
          'concurrent claims',
          'atomic balances',
          'cash and paid refunds',
          'kitchen gate',
          'delivery timestamps',
          'earnings',
          'legacy flow',
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
