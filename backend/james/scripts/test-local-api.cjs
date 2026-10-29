const assert = require('node:assert/strict');
const { readFileSync, writeFileSync } = require('node:fs');
const { join } = require('node:path');
const { randomUUID } = require('node:crypto');
if (require('node:fs').existsSync('.env')) process.loadEnvFile('.env');

async function main() {
  if (
    process.env.NODE_ENV !== 'development' ||
    !['localhost', '127.0.0.1', '::1'].includes(process.env.DB_HOST)
  )
    throw Error('This smoke test is only for local development.');
  const accounts = JSON.parse(
    readFileSync(join(__dirname, '../.local/credentials.json'), 'utf8'),
  ).accounts;
  const base = `http://localhost:${Number(process.env.PORT || 3000)}/api`;
  const results = [];
  async function request(method, route, status, token, body) {
    const response = await fetch(`${base}${route}`, {
      method,
      signal: AbortSignal.timeout(10000),
      headers: {
        'Content-Type': 'application/json',
        ...(token ? { Authorization: `Bearer ${token}` } : {}),
      },
      body: body === undefined ? undefined : JSON.stringify(body),
    });
    assert.equal(response.status, status, `${method} ${route}`);
    const text = await response.text();
    results.push({ method, route, status });
    return text ? JSON.parse(text) : null;
  }
  await request('GET', '/admin/company', 401);
  for (const account of accounts) {
    const device = randomUUID();
    await request('POST', '/auth/login', 401, null, {
      email: account.email,
      password: 'Incorrect-local-password!',
      idDevice: device,
    });
    const login = await request('POST', '/auth/login', 201, null, {
      email: account.email,
      password: account.password,
      idDevice: device,
    });
    assert.equal(login.email, account.email);
    assert(!('password' in login) && !('passwordTemporary' in login));
    for (const role of account.roles) assert(login.roles.includes(role));
    try {
      await request('PATCH', `/auth/check/${device}`, 200, login.token);
      const balance = await request('GET', '/client/balance', 200, login.token);
      assert.equal(balance.balance.money, 0);
      await request(
        'GET',
        '/admin/company',
        account.roles.includes('admin') ? 200 : 403,
        login.token,
      );
      await request('GET', '/client/market/orders', 200, login.token);
      await request('GET', '/client/address', 200, login.token);
      if (process.env.EXTERNAL_SERVICES_ENABLED === 'false') {
        await request('POST', '/client/payments/payment', 503, login.token, {
          money: 10,
          currency: 'usd',
          products: [
            {
              id: 1,
              name: 'Fixture',
              description: 'Fixture product',
              image: '',
              note: '',
              price: 10,
              number: 1,
              total: 10,
            },
          ],
        });
        await request(
          'GET',
          '/client/address/geocode/fixture',
          503,
          login.token,
        );
      }
    } finally {
      await request('DELETE', `/auth/log-out/${device}`, 200, login.token);
    }
    await request('GET', '/client/balance', 401, login.token);
  }
  if (!process.argv.includes('--auth-only')) {
    await request(
      'GET',
      '/client/market/companies?latitude=-0.2&longitude=-78.5',
      200,
    );
    await request(
      'GET',
      '/client/market/categories?latitude=-0.2&longitude=-78.5',
      200,
    );
  }
  const report = {
    url: base,
    checks: results.length,
    checkedAt: new Date().toISOString(),
    results,
  };
  writeFileSync(
    join(__dirname, '../.local/api-smoke-report.json'),
    JSON.stringify(report, null, 2) + '\n',
  );
  console.log(
    JSON.stringify(
      {
        url: base,
        checks: results.length,
        accounts: accounts.map((account) => account.email),
        status: 'passed',
      },
      null,
      2,
    ),
  );
}
main().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
