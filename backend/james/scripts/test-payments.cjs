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
    throw Error('Payment checks require local PostgreSQL');
  const name = `delivery_payment_test_${process.pid}_${randomBytes(4).toString('hex')}`;
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
    checks = 0,
    prepareCount = 0,
    stripeCalls = 0;
  await admin.connect();
  try {
    await admin.query(
      `CREATE DATABASE "${name}" ENCODING 'UTF8' TEMPLATE template0`,
    );
    created = true;
    await database.initialize();
    await database.runMigrations();
    assert.equal(
      (await database.driver.createSchemaBuilder().log()).upQueries.length,
      0,
    );
    checks++;
    // Upgrade an actual pre-provider Stripe record without changing its status or crediting it.
    await database.undoLastMigration();
    const old = await database.query(
      `INSERT INTO payment (money,currency,products,response,status) VALUES (3.25,'USD','[]','{"id":"pi_legacy"}',100) RETURNING id`,
    );
    await database.runMigrations();
    const legacy = (
      await database.query('SELECT * FROM payment WHERE id=$1', [old[0].id])
    )[0];
    assert.equal(legacy.provider, 'stripe');
    assert.equal(legacy.amountCents, 325);
    assert.equal(legacy.status, 100);
    assert.equal(legacy.creditedAt, null);
    checks++;
    Object.assign(process.env, {
      NODE_ENV: 'test',
      DB_NAME: name,
      DB_SYNCHRONIZE: 'false',
      EXTERNAL_SERVICES_ENABLED: 'false',
      PAYMENTS_ENABLED: 'true',
      PAYMENT_PROVIDER: 'payphone',
      STRIPE_ENABLED: 'false',
      PAYPHONE_MODE: 'test',
      PAYPHONE_TOKEN: 'fixture-private-token',
      PAYPHONE_STORE_ID: 'fixture-store',
      PAYPHONE_RESPONSE_URL:
        'http://localhost:3000/api/client/payments/payphone/return',
    });
    const { Test } = require('@nestjs/testing');
    const { AppModule } = require('../dist/app.module');
    const { configureApp } = require('../dist/configure-app');
    const {
      PayphoneGateway,
      StripeGateway,
    } = require('../dist/client/payments/payment-gateways');
    const results = new Map();
    const fakePayphone = {
      async create(payment) {
        prepareCount++;
        return {
          response: {
            paymentId: 'opaque-' + payment.id,
            payWithCard:
              'https://pay.payphonetodoesposible.com/Anonymous/Index?paymentId=opaque-' +
              payment.id,
            payWithPayPhone:
              'https://pay.payphonetodoesposible.com/PayPhone/Index?paymentId=opaque-' +
              payment.id,
          },
        };
      },
      async verify(payment, id) {
        const result = results.get(payment.clientTransactionId) || {};
        if (result.error) throw Error('Simulated provider outage');
        return {
          state: 'approved',
          transactionId: id,
          clientTransactionId: payment.clientTransactionId,
          amountCents: payment.amountCents,
          currency: payment.currency,
          ...result,
        };
      },
    };
    const disabledStripe = {
      create() {
        stripeCalls++;
        throw Error('Disabled');
      },
      verify() {
        stripeCalls++;
        throw Error('Disabled');
      },
      cancel() {
        stripeCalls++;
        throw Error('Disabled');
      },
    };
    const module = await Test.createTestingModule({ imports: [AppModule] })
      .overrideProvider(PayphoneGateway)
      .useValue(fakePayphone)
      .overrideProvider(StripeGateway)
      .useValue(disabledStripe)
      .compile();
    app = module.createNestApplication({ logger: false });
    configureApp(app);
    await app.listen(0, '127.0.0.1');
    const base = (await app.getUrl()) + '/api';
    const { User } = require('../dist/auth/entities/user.entity');
    const {
      Balance,
    } = require('../dist/client/balance/entities/balance.entity');
    const {
      Payment,
    } = require('../dist/client/payments/entities/payment.entity');
    const save = (type, data) =>
      database.manager.save(type, database.manager.create(type, data));
    const password = randomBytes(16).toString('hex');
    const hash = await require('bcrypt').hash(password, 4);
    async function request(method, path, expected, actor, body) {
      const response = await fetch(base + path, {
        method,
        signal: AbortSignal.timeout(15000),
        headers: {
          'Content-Type': 'application/json',
          ...(actor ? { Authorization: 'Bearer ' + actor.token } : {}),
        },
        body: body === undefined ? undefined : JSON.stringify(body),
      });
      const data = await response.json();
      assert.equal(
        response.status,
        expected,
        method + ' ' + path + ' ' + JSON.stringify(data),
      );
      checks++;
      return data;
    }
    async function actor(suffix, role = 'client') {
      const user = await save(User, {
        fullName: suffix,
        email: suffix + '@example.test',
        password: hash,
        roles: [role],
      });
      const login = await request('POST', '/auth/login', 201, null, {
        email: user.email,
        password,
        idDevice: randomUUID(),
      });
      return { ...user, token: login.token };
    }
    const a = await actor('a'),
      b = await actor('b'),
      manager = await actor('manager', 'manager');
    const body = (money = 10) => ({
      money,
      currency: 'USD',
      products: [
        {
          id: 1,
          name: 'Fixture meal',
          description: 'Fixture',
          image: '',
          price: money,
          number: 1,
          total: money,
          note: '',
        },
      ],
    });
    const newPayment = (money, who = a) =>
      request('POST', '/client/payments/payment', 201, who, body(money));
    const reference = (payment) =>
      new URL(payment.response.checkoutUrl).pathname.split('/').pop();
    const balance = async () =>
      (await database.manager.findOneBy(Balance, { userId: a.id }))?.money || 0;
    async function callback(payment, id, status = 200) {
      const response = await fetch(
        base +
          '/client/payments/payphone/return?id=' +
          id +
          '&clientTransactionId=' +
          reference(payment),
      );
      const html = await response.text();
      assert.equal(response.status, status, html);
      assert(!html.includes(process.env.PAYPHONE_TOKEN));
      assert(!html.includes(reference(payment)));
      checks++;
      return html;
    }
    const config = await request('GET', '/client/payments/configuration', 200);
    assert.equal(config.provider, 'payphone');
    assert.equal(config.enabled, true);
    assert.equal(config.stripeEnabled, false);
    await request('POST', '/client/payments/payment', 401, null, body());
    await request('POST', '/client/payments/payment', 403, manager, body());
    for (const invalid of [0, -1, 0.5, 1.001, 10001])
      await request('POST', '/client/payments/payment', 400, a, body(invalid));
    await request('POST', '/client/payments/payment', 400, a, {
      ...body(),
      currency: 'EUR',
    });
    const [first, same] = await Promise.all([newPayment(10), newPayment(10)]);
    assert.equal(first.id, same.id);
    assert.equal(prepareCount, 1);
    assert.equal(await balance(), 0);
    checks++;
    const bridge = await fetch(
      base + '/client/payments/payphone/start/' + reference(first),
    );
    assert.equal(bridge.headers.get('referrer-policy'), 'origin');
    assert((await bridge.text()).includes('Tarjeta de débito o crédito'));
    checks++;
    await request('GET', `/client/payments/${first.id}/status`, 404, b);
    await request('PATCH', `/client/payments/confirm/${first.id}`, 404, b);
    assert.equal(
      await request('PATCH', `/client/payments/confirm/${first.id}`, 200, a),
      false,
    );
    assert.equal(await balance(), 0);
    checks++;
    await request('PATCH', `/client/payments/cancel/${first.id}`, 409, a);
    results.set(reference(first), { state: 'pending' });
    await callback(first, 1001);
    assert.equal(
      (await request('GET', `/client/payments/${first.id}/status`, 200, a))
        .status,
      1,
    );
    assert.equal(await balance(), 0);
    checks++;
    results.delete(reference(first));
    await Promise.all([
      callback(first, 1001),
      callback(first, 1001),
      request('GET', `/client/payments/${first.id}/status`, 200, a),
    ]);
    await callback(first, 1001);
    assert.equal(await balance(), 10);
    checks++;
    const confirmed = await request(
      'GET',
      `/client/payments/${first.id}/status`,
      200,
      a,
    );
    assert.equal(confirmed.status, 100);
    assert(confirmed.creditedAt);
    checks++;
    const canceled = await newPayment(3);
    results.set(reference(canceled), { state: 'canceled' });
    await callback(canceled, 1002);
    assert.equal(
      (await request('GET', `/client/payments/${canceled.id}/status`, 200, a))
        .status,
      400,
    );
    assert.equal(await balance(), 10);
    checks++;
    for (const [field, value] of [
      ['amountCents', 1],
      ['currency', 'EUR'],
      ['clientTransactionId', 'wrong'],
      ['transactionId', '9999'],
    ]) {
      const payment = await newPayment(4 + checks / 100);
      results.set(reference(payment), { [field]: value });
      await callback(payment, 2000 + payment.id, 503);
      assert.equal(await balance(), 10);
      assert.equal(
        (await database.manager.findOneBy(Payment, { id: payment.id })).status,
        1,
      );
      checks++;
    }
    const retry = await newPayment(6.25);
    results.set(reference(retry), { error: true });
    await callback(retry, 3001, 503);
    assert.equal(await balance(), 10);
    results.delete(reference(retry));
    assert.equal(
      (await request('GET', `/client/payments/${retry.id}/status`, 200, a))
        .status,
      100,
    );
    assert.equal(await balance(), 16.25);
    checks++;
    const p1 = await newPayment(7.25),
      p2 = await newPayment(8.35);
    await Promise.all([callback(p1, 4001), callback(p2, 4002)]);
    assert.equal(await balance(), 31.85);
    checks++;
    const rollback = await newPayment(2.15);
    await database.query(
      `CREATE FUNCTION fail_credit_fixture() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN IF NEW.status=100 AND NEW.id=${rollback.id} THEN RAISE EXCEPTION 'Simulated save failure'; END IF; RETURN NEW; END $$`,
    );
    await database.query(
      'CREATE TRIGGER fail_credit_fixture BEFORE UPDATE ON payment FOR EACH ROW EXECUTE FUNCTION fail_credit_fixture()',
    );
    await callback(rollback, 5001, 503);
    assert.equal(await balance(), 31.85);
    checks++;
    await database.query('DROP TRIGGER fail_credit_fixture ON payment');
    assert.equal(
      (await request('GET', `/client/payments/${rollback.id}/status`, 200, a))
        .status,
      100,
    );
    assert.equal(await balance(), 34);
    checks++;
    const historic = await save(Payment, {
      userId: a.id,
      money: 3.25,
      amountCents: 325,
      provider: 'stripe',
      currency: 'USD',
      products: [],
      response: { id: 'pi_legacy_pending' },
    });
    assert.equal(
      (await request('GET', `/client/payments/${historic.id}/status`, 200, a))
        .status,
      1,
    );
    await request('PATCH', `/client/payments/confirm/${historic.id}`, 503, a);
    assert.equal(stripeCalls, 0);
    checks++;
    process.env.PAYMENTS_ENABLED = 'false';
    await request('POST', '/client/payments/payment', 503, a, body());
    assert.equal(
      (await request('GET', '/client/payments/configuration', 200)).enabled,
      false,
    );
    assert.equal(await balance(), 34);
    console.log(
      JSON.stringify({
        status: 'passed',
        checks,
        coverage: [
          'migration preserves Stripe history',
          'HTTP localhost',
          'ownership',
          'integer amounts',
          'concurrent checkout reuse',
          'verified credit',
          'mismatched callbacks',
          'pending and declined',
          'retries',
          'exactly-once credit',
          'atomic wallet increments',
          'transaction rollback',
          'Stripe disabled',
          'no token in HTML',
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
