const {
  existsSync,
  mkdirSync,
  readFileSync,
  writeFileSync,
} = require('node:fs');
const { join } = require('node:path');
const { randomBytes } = require('node:crypto');
const { Client } = require('pg');
const bcrypt = require('bcrypt');
const dataSource = require('../dist/database/data-source').default;
const { User } = require('../dist/auth/entities/user.entity');
const { Balance } = require('../dist/client/balance/entities/balance.entity');

function localOnly() {
  if (
    process.env.NODE_ENV === 'production' ||
    !['localhost', '127.0.0.1', '::1'].includes(dataSource.options.host) ||
    ['postgres', 'template0', 'template1'].includes(dataSource.options.database)
  ) {
    throw new Error(
      'Local setup requires a loopback host, a development environment and a dedicated database.',
    );
  }
}

async function createDatabase() {
  localOnly();
  const options = dataSource.options;
  const client = new Client({
    host: options.host,
    port: options.port,
    user: options.username,
    password: options.password,
    database: 'postgres',
    connectionTimeoutMillis: 5000,
  });
  await client.connect();
  try {
    const found = await client.query(
      'SELECT 1 FROM pg_database WHERE datname=$1',
      [options.database],
    );
    if (!found.rowCount) {
      const identifier = '"' + options.database.replace(/"/g, '""') + '"';
      await client.query(
        `CREATE DATABASE ${identifier} ENCODING 'UTF8' TEMPLATE template0`,
      );
    }
    console.log(
      `Local database ready: ${options.database} (${options.host}:${options.port})`,
    );
  } finally {
    await client.end();
  }
}

function credentials() {
  const directory = join(__dirname, '../.local');
  const filename = join(directory, 'credentials.json');
  mkdirSync(directory, { recursive: true });
  if (!existsSync(filename)) {
    const accounts = [
      {
        email: 'admin@delivery.local',
        fullName: 'Administrador local',
        phone: '0900000001',
        roles: ['admin', 'client'],
        password: `Adm-${randomBytes(12).toString('hex')}!7`,
      },
      {
        email: 'cliente@delivery.local',
        fullName: 'Cliente local',
        phone: '0900000002',
        roles: ['client'],
        password: `Cli-${randomBytes(12).toString('hex')}!7`,
      },
    ];
    writeFileSync(
      filename,
      JSON.stringify(
        { database: dataSource.options.database, accounts },
        null,
        2,
      ) + '\n',
      { flag: 'wx', mode: 0o600 },
    );
  }
  const saved = JSON.parse(readFileSync(filename, 'utf8'));
  if (
    saved.database !== dataSource.options.database ||
    !Array.isArray(saved.accounts) ||
    saved.accounts.length !== 2
  ) {
    throw new Error('The local credentials file does not match this database.');
  }
  return { filename, accounts: saved.accounts };
}

async function seedUsers() {
  localOnly();
  const saved = credentials();
  await dataSource.initialize();
  try {
    await dataSource.transaction(async (manager) => {
      const users = manager.getRepository(User);
      const balances = manager.getRepository(Balance);
      for (const account of saved.accounts) {
        let user = await users.findOne({
          where: { email: account.email },
          select: {
            id: true,
            email: true,
            password: true,
            roles: true,
            isActive: true,
          },
        });
        if (user) {
          if (!(await bcrypt.compare(account.password, user.password))) {
            throw new Error(
              `Existing account ${account.email} has another password; no credentials were reset.`,
            );
          }
          if (
            !user.isActive ||
            account.roles.some((role) => !user.roles.includes(role))
          ) {
            throw new Error(
              `Existing account ${account.email} has different permissions; no permissions were changed.`,
            );
          }
        } else {
          user = await users.save(
            users.create({
              email: account.email,
              fullName: account.fullName,
              phone: account.phone,
              roles: account.roles,
              isActive: true,
              password: await bcrypt.hash(account.password, 12),
            }),
          );
        }
        if (!(await balances.existsBy({ userId: user.id }))) {
          await balances.save(balances.create({ userId: user.id, user }));
        }
        console.log(
          `Local account ready: ${account.email} (${account.roles.join(', ')})`,
        );
      }
    });
    console.log(
      `Credentials saved locally, excluded from Git: ${saved.filename}`,
    );
  } finally {
    await dataSource.destroy();
  }
}

async function checkDatabase() {
  await dataSource.initialize();
  try {
    const extension = await dataSource.query(
      'SELECT postgis_version() AS version',
    );
    const pending = await dataSource.showMigrations();
    const schema = await dataSource.driver.createSchemaBuilder().log();
    const users = await dataSource
      .getRepository(User)
      .find({ select: { id: true, email: true, roles: true, isActive: true } });
    console.log(
      JSON.stringify(
        {
          database: dataSource.options.database,
          postgis: extension[0].version,
          pendingMigrations: pending,
          schemaChanges: schema.upQueries.length,
          users,
        },
        null,
        2,
      ),
    );
    if (pending || schema.upQueries.length)
      throw new Error(
        'The database does not match the migration history/entities.',
      );
  } finally {
    await dataSource.destroy();
  }
}

const command = process.argv[2];
const commands = {
  create: createDatabase,
  seed: seedUsers,
  check: checkDatabase,
};
if (!commands[command]) throw new Error('Expected create, seed or check.');
commands[command]().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
