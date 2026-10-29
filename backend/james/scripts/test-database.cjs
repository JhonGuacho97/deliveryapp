const assert = require('node:assert/strict');
const { randomBytes, randomUUID } = require('node:crypto');
const { Client } = require('pg');
const { DataSource } = require('typeorm');
const source = require('../dist/database/data-source').default;
const { User } = require('../dist/auth/entities/user.entity');
const { Session } = require('../dist/auth/entities/session.entity');
const { Company } = require('../dist/admin/company/entities/company.entity');
const { Store } = require('../dist/admin/store/entities/store.entity');
const { Category } = require('../dist/admin/category/entities/category.entity');
const {
  CompanyCategory,
} = require('../dist/admin/company-category/entities/company-category.entity');
const {
  HoursOperation,
} = require('../dist/admin/hours-peration/entities/hours-peration.entity');
const { Product } = require('../dist/admin/product/entities/product.entity');
const { Address } = require('../dist/client/address/entities/address.entity');
const {
  ViewCompany,
} = require('../dist/client/market/views/company.view.entity');
const {
  ViewProduct,
} = require('../dist/client/market/views/product.view.entity');
const {
  ViewCategory,
} = require('../dist/client/market/views/category.view.entity');

async function main() {
  if (
    process.env.NODE_ENV === 'production' ||
    !['localhost', '127.0.0.1', '::1'].includes(source.options.host)
  )
    throw Error('Database tests require a local development server.');
  const name = `delivery_migration_test_${process.pid}_${randomBytes(4).toString('hex')}`;
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
  let created = false;
  await admin.connect();
  try {
    const available = await admin.query(
      'SELECT 1 FROM pg_available_extensions WHERE name=$1',
      ['postgis'],
    );
    assert(
      available.rowCount,
      'Install PostGIS for PostgreSQL 16 before running the database tests.',
    );
    await admin.query(
      `CREATE DATABASE "${name}" ENCODING 'UTF8' TEMPLATE template0`,
    );
    created = true;
    await database.initialize();
    assert.equal(
      (await database.runMigrations()).length,
      database.migrations.length,
    );
    assert.equal((await database.runMigrations()).length, 0);
    assert.equal(
      (await database.driver.createSchemaBuilder().log()).upQueries.length,
      0,
    );
    console.log('PASS: migrations apply once and match the entity schema.');
    const runner = database.createQueryRunner();
    await runner.connect();
    await runner.startTransaction();
    try {
      const manager = runner.manager;
      const save = (type, data) =>
        manager.save(type, manager.create(type, data));
      const user = await save(User, {
        fullName: 'Fixture',
        email: 'fixture@example.test',
        password: 'not-a-real-login-hash',
        roles: ['client'],
      });
      const location = { x: -0.2, y: -78.5 };
      const company = await save(Company, {
        name: 'Fixture company',
        address: 'Calle 1',
        contact: '0900000000',
        email: 'fixture@example.test',
        location: { ...location },
        user,
      });
      const category = await save(Category, { name: 'Fixture category' });
      await save(CompanyCategory, { company, category });
      const store = await save(Store, {
        name: 'Fixture store',
        address: 'Calle 1',
        contact: '0900000000',
        email: 'fixture@example.test',
        location: { ...location },
        company,
        user,
      });
      for (let day = 0; day < 7; day++)
        await save(HoursOperation, {
          store,
          day,
          open: '00:00:00',
          close: '23:59:59',
        });
      await save(Product, {
        name: 'Fixture product',
        description: 'Fixture description',
        image: '',
        price: 3.25,
        company,
      });
      assert.equal((await manager.find(ViewCompany)).length, 1);
      assert.equal((await manager.find(ViewCategory)).length, 1);
      assert.equal((await manager.find(ViewProduct))[0].companyId, company.id);
      const distances = await runner.query(
        'SELECT ST_DistanceSphere(ST_GeomFromText($1),location::geometry) AS distance FROM store WHERE id=$2',
        ['POINT(-0.2 -78.5)', store.id],
      );
      assert.equal(Number(distances[0].distance), 0);
      const address = await save(Address, {
        alias: 'Casa',
        address: 'Calle 1',
        location: { ...location },
        user,
      });
      assert.equal(
        (await manager.findOneBy(Address, { id: address.id })).location.x,
        location.x,
      );
      await manager.softDelete(Address, address.id);
      assert.equal(await manager.count(Address), 0);
      const sessionUser = await save(User, {
        fullName: 'Session fixture',
        email: 'session@example.test',
        password: 'not-a-real-login-hash',
      });
      await save(Session, { user: sessionUser, idDevice: randomUUID() });
      await manager.delete(User, sessionUser.id);
      assert.equal(await manager.count(Session), 0);
      console.log(
        'PASS: views, spatial calculations, points, soft delete and session cascade use real PostgreSQL.',
      );
    } finally {
      await runner.rollbackTransaction();
      await runner.release();
    }
    for (let migration = 0; migration < database.migrations.length; migration++)
      await database.undoLastMigration();
    const absent = await database.query('SELECT to_regclass($1) AS relation', [
      'public.user',
    ]);
    assert.equal(absent[0].relation, null);
    assert.equal(
      (await database.runMigrations()).length,
      database.migrations.length,
    );
    assert.equal(
      (await database.driver.createSchemaBuilder().log()).upQueries.length,
      0,
    );
    console.log(
      'PASS: migrations revert and reapply in the disposable database.',
    );
  } finally {
    if (database.isInitialized) await database.destroy();
    if (created && name.startsWith('delivery_migration_test_'))
      await admin.query(`DROP DATABASE "${name}"`);
    await admin.end();
  }
}
main().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
