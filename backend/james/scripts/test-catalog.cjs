const assert = require('node:assert/strict');
const { randomBytes, randomUUID } = require('node:crypto');
const { Client } = require('pg');
const { DataSource } = require('typeorm');
const source = require('../dist/database/data-source').default;
const { seedCatalog } = require('./seed-catalog.cjs');
async function main() {
  if (
    process.env.NODE_ENV === 'production' ||
    !['localhost', '127.0.0.1', '::1'].includes(source.options.host)
  )
    throw Error('Catalog checks require local PostgreSQL');
  const options = source.options,
    name =
      'delivery_catalog_test_' +
      process.pid +
      '_' +
      randomBytes(4).toString('hex');
  const admin = new Client({
    host: options.host,
    port: options.port,
    user: options.username,
    password: options.password,
    database: 'postgres',
  });
  const db = new DataSource({ ...options, database: name, logging: false });
  let app,
    created = false,
    checks = 0;
  const eq = (a, b, label) => {
    assert.deepEqual(a, b, label);
    checks++;
  };
  const ok = (value, label) => {
    assert(value, label);
    checks++;
  };
  await admin.connect();
  try {
    await admin.query(
      'CREATE DATABASE "' + name + "\" ENCODING 'UTF8' TEMPLATE template0",
    );
    created = true;
    await db.initialize();
    await db.runMigrations();
    const { User } = require('../dist/auth/entities/user.entity'),
      { Company } = require('../dist/admin/company/entities/company.entity'),
      { Store } = require('../dist/admin/store/entities/store.entity'),
      { Product } = require('../dist/admin/product/entities/product.entity'),
      {
        HoursOperation,
      } = require('../dist/admin/hours-peration/entities/hours-peration.entity'),
      { Category } = require('../dist/admin/category/entities/category.entity'),
      {
        CompanyCategory,
      } = require('../dist/admin/company-category/entities/company-category.entity');
    const save = (type, value) =>
      db.manager.save(type, db.manager.create(type, value));
    const password = randomBytes(12).toString('hex'),
      hash = await require('bcrypt').hash(password, 4);
    const manager = await save(User, {
      fullName: 'Catalog manager',
      email: 'manager@example.test',
      password: hash,
      roles: ['manager'],
    });
    const customer = await save(User, {
      fullName: 'Catalog client',
      email: 'client@example.test',
      password: hash,
      roles: ['client'],
    });
    const point = { x: -4.0236715, y: -79.1978733 };
    const company = await save(Company, {
      name: 'Restaurante de prueba',
      address: 'Local fixture',
      contact: '0990000000',
      email: manager.email,
      location: { ...point },
      user: manager,
    });
    const store = await save(Store, {
      name: 'Restaurante de prueba',
      address: 'Local fixture',
      contact: '0990000000',
      email: manager.email,
      location: { ...point },
      company,
      user: manager,
    });
    for (let day = 0; day < 7; day++)
      await save(HoursOperation, {
        store,
        day,
        open: '00:00:00',
        close: '23:59:59',
        timeZone: -5,
      });
    const product = await save(Product, {
      name: 'Bowl de pollo · Prueba local',
      price: 6.5,
      description: 'Original dish',
      image: '',
      company,
    });
    const owner = {
      managerId: manager.id,
      companyId: company.id,
      storeId: store.id,
      productId: product.id,
    };
    const first = await seedCatalog(db, owner);
    eq(first.restaurants.length, 5, 'five restaurants');
    eq(
      await db.getRepository(Product).count({ where: { image: '' } }),
      0,
      'all demo dishes have illustrative photos',
    );
    eq(
      await db.getRepository(Company).count({ where: { image: '' } }),
      0,
      'all demo restaurants have covers',
    );
    eq(
      first.restaurants.map((r) => r.products.length),
      [6, 6, 6, 6, 6],
      'six menu items per restaurant',
    );
    await db.getRepository(Product).update(product.id, {
      price: 6.75,
      image: 'https://example.test/custom-dish.jpg',
    });
    await db.getRepository(Company).update(company.id, {
      image: 'https://example.test/custom-restaurant.jpg',
    });
    const repeated = await seedCatalog(db, owner);
    eq(
      Object.values(repeated.created),
      [0, 0, 0, 0, 0, 0],
      'seed is idempotent',
    );
    eq(
      (await db.getRepository(Product).findOneBy({ id: product.id })).price,
      6.75,
      'seed preserves edited prices',
    );
    eq(
      repeated.updatedImages,
      { companies: 0, products: 0 },
      'repeated image seeding is idempotent',
    );
    eq(
      (await db.getRepository(Product).findOneBy({ id: product.id })).image,
      'https://example.test/custom-dish.jpg',
      'seed preserves a custom dish image',
    );
    eq(
      (await db.getRepository(Company).findOneBy({ id: company.id })).image,
      'https://example.test/custom-restaurant.jpg',
      'seed preserves a custom cover',
    );
    eq(
      await db.getRepository(HoursOperation).count(),
      35,
      'seven schedules per restaurant',
    );
    Object.assign(process.env, {
      NODE_ENV: 'test',
      DB_NAME: name,
      DB_SYNCHRONIZE: 'false',
      EXTERNAL_SERVICES_ENABLED: 'false',
    });
    const { FilterKM } = require('../dist/common/glob/filter');
    FilterKM.STORES_NEARBY = 5000;
    const { NestFactory } = require('@nestjs/core'),
      { AppModule } = require('../dist/app.module'),
      { configureApp } = require('../dist/configure-app');
    app = await NestFactory.create(AppModule, { logger: false });
    configureApp(app);
    await app.listen(0, '127.0.0.1');
    const base = (await app.getUrl()) + '/api';
    async function request(path, token, body) {
      const response = await fetch(base + path, {
        method: body ? 'POST' : 'GET',
        signal: AbortSignal.timeout(10000),
        headers: {
          'Content-Type': 'application/json',
          ...(token ? { Authorization: 'Bearer ' + token } : {}),
        },
        body: body ? JSON.stringify(body) : undefined,
      });
      const value = await response.json();
      eq(response.status, body ? 201 : 200, path + ' ' + JSON.stringify(value));
      return value;
    }
    const login = await request('/auth/login', null, {
      email: customer.email,
      password,
      idDevice: randomUUID(),
    });
    const params = '?latitude=' + point.x + '&longitude=' + point.y;
    const catalog = await request('/client/market/companies' + params);
    eq(catalog.companies.length, 5, 'default address has five restaurants');
    ok(
      catalog.companies.every(
        (c) =>
          c.type === 10 &&
          typeof c.isOpen === 'boolean' &&
          Number.isInteger(c.categoryId),
      ),
      'mobile company contract',
    );
    eq(catalog.products.length, 5, 'home has one product per open restaurant');
    for (const restaurant of first.restaurants) {
      const menu = await request(
        '/client/market/products/company/' + restaurant.companyId,
      );
      eq(menu.products.length, 6, 'full menu is available');
      ok(
        menu.products.every(
          (p) =>
            p.description &&
            p.price > 0 &&
            p.companyId === restaurant.companyId,
        ),
        'complete menu values',
      );
    }
    const pizzas = first.restaurants[1];
    const search = (term, extra = '') =>
      request(
        '/client/market/companies' +
          params +
          '&query=' +
          encodeURIComponent(term) +
          extra,
      );
    const pizzaSearch = await search('  PiZZ  ');
    eq(
      pizzaSearch.products.length,
      4,
      'search includes every pizza, not only the featured one',
    );
    eq(
      pizzaSearch.companies.map((c) => c.id),
      [pizzas.companyId],
      'search includes the restaurant serving the dishes',
    );
    const extraPizza = await save(Product, {
      name: 'Pizza mini de barrio',
      price: 4,
      description: 'Un plato adicional fuera del destacado',
      image: '',
      company: { id: first.restaurants[2].companyId },
    });
    const acrossMenus = await search('pizz');
    eq(
      acrossMenus.products.length,
      5,
      'global search spans multiple restaurant menus',
    );
    eq(
      acrossMenus.companies.map((c) => c.id),
      [pizzas.companyId, first.restaurants[2].companyId],
      'all related restaurants are returned',
    );
    await db.getRepository(Product).softDelete(extraPizza.id);
    const specific = await search('pepperoni');
    eq(
      specific.products.length,
      1,
      'a dish outside the featured list is searchable',
    );
    eq(
      specific.companies.map((c) => c.id),
      [pizzas.companyId],
      'dish name finds its restaurant even when the store name does not match',
    );
    eq(
      (await search('Esquina')).companies.map((c) => c.id),
      [pizzas.companyId],
      'restaurant name is searchable',
    );
    eq(
      (await search('mozzarella')).products.length,
      3,
      'dish descriptions are searchable',
    );
    eq((await search('cafe')).companies.length, 1, 'search ignores accents');
    eq(
      (await search('inexistente')).products,
      [],
      'a search without matches has no featured fallback',
    );
    eq((await search('%')).companies, [], 'percent is literal');
    eq((await search('_')).products, [], 'underscore is literal');
    eq(
      (await search("' OR 1=1 --")).companies,
      [],
      'search input is bound, never SQL',
    );
    eq(
      (await search('   ')).companies.length,
      5,
      'whitespace keeps the normal home',
    );
    const pizzaPage1 = await search('pizz', '&limit=2'),
      pizzaPage2 = await search('pizz', '&limit=2&offset=2');
    eq(
      new Set([...pizzaPage1.products, ...pizzaPage2.products].map((p) => p.id))
        .size,
      4,
      'dish pagination is stable and independent of restaurant pagination',
    );
    const category = await db
      .getRepository(Category)
      .findOneBy({ name: 'Pizzas' });
    const filtered = await request(
      '/client/market/companies' + params + '&categoryId=' + category.id,
    );
    eq(
      (await search('pizz', '&categoryId=' + category.id)).products.length,
      4,
      'search respects selected category',
    );
    eq(
      (await search('pollo', '&categoryId=' + category.id)).products,
      [],
      'search does not leak dishes outside selected category',
    );
    eq(
      filtered.companies.map((c) => c.id),
      [pizzas.companyId],
      'category filter isolates the pizzeria',
    );
    const fees = await request(
      '/client/market/delivery-cost/companies/' +
        first.restaurants.map((r) => r.companyId).join(',') +
        params,
      login.token,
    );
    eq(fees.fees.length, 5, 'checkout quotes every restaurant');
    ok(
      fees.fees.every(
        (f) =>
          Number.isFinite(f.deliveryfee) &&
          f.deliveryfee >= 1.25 &&
          f.deliveryfee < 3,
      ),
      'quotes use nearby coordinates',
    );
    const pizzaStore = await db
      .getRepository(Store)
      .findOneBy({ id: pizzas.storeId });
    const [expected] = await db.query(
      'SELECT ST_Distance(ST_SetSRID(ST_MakePoint($1,$2),4326)::geography, ST_SetSRID(ST_MakePoint($3,$4),4326)::geography) AS meters',
      [point.y, point.x, pizzaStore.location.y, pizzaStore.location.x],
    );
    ok(
      Math.abs(
        fees.fees.find((f) => f.store_id === pizzas.storeId).deliveryfee -
          (1.25 + (expected.meters / 1000) * 0.55),
      ) < 0.002,
      'fee agrees with independent geography distance',
    );
    await db.getRepository(Product).softDelete(product.id);
    eq(
      (await search('Bowl de pollo')).products,
      [],
      'deleted dishes are not searchable',
    );
    const reduced = await request(
      '/client/market/products/company/' + company.id,
    );
    eq(reduced.products.length, 5, 'deleted products stay out of the menu');
    const reseed = await seedCatalog(db, owner);
    eq(reseed.created.products, 0, 'seed does not resurrect deleted products');
    ok(
      reseed.restaurants[0].products[0].deleted,
      'report marks deleted menu items',
    );
    const shared = await save(Category, {
      name: 'Shared regional category',
      image: '',
    });
    const far = await save(Company, {
      name: 'Far store',
      address: 'Far',
      contact: '0990000000',
      email: manager.email,
      location: { x: 10, y: 10 },
      user: manager,
    });
    await save(Store, {
      name: 'Far store',
      address: 'Far',
      contact: '0990000000',
      email: manager.email,
      location: { x: 10, y: 10 },
      company: far,
      user: manager,
    });
    await save(CompanyCategory, { company: far, category: shared });
    await save(CompanyCategory, { company, category: shared });
    const categories = await request('/client/market/categories' + params);
    ok(
      categories.categories.some((c) => c.id === shared.id),
      'category filtering happens before deduplication',
    );
    const withFar = await request('/client/market/companies' + params);
    eq(
      (await search('Far store')).companies,
      [],
      'global search preserves delivery area',
    );
    ok(
      !withFar.companies.some((c) => c.id === far.id),
      'far stores are excluded with a five kilometer test radius',
    );
    await db.getRepository(HoursOperation).delete({ store: { id: store.id } });
    const noHours = await request('/client/market/companies' + params);
    const noSchedule = noHours.companies.find((c) => c.storeId === store.id);
    ok(
      noSchedule && !noSchedule.isOpen && noSchedule.open === '00:00:00',
      'a restaurant without hours remains visible as closed',
    );
    await db.getRepository(Store).softDelete(pizzas.storeId);
    eq(
      (await search('pizz')).products,
      [],
      'deleted stores cannot contribute search results',
    );
    const withoutDeleted = await request('/client/market/companies' + params);
    ok(
      !withoutDeleted.companies.some((c) => c.id === pizzas.companyId),
      'deleted stores are excluded',
    );
    const categoriesAfter = await request('/client/market/categories' + params);
    ok(
      !categoriesAfter.categories.some((c) => c.id === category.id),
      'deleted store does not keep its category visible',
    );
    await save(HoursOperation, {
      store,
      day: 3,
      open: '16:00:00',
      close: '20:00:00',
      timeZone: -5,
    });
    const {
      companyViewQuery,
    } = require('../dist/client/market/views/company.view.entity');
    const runner = db.createQueryRunner();
    await runner.connect();
    try {
      async function openAt(instant) {
        const sql = companyViewQuery.replaceAll(
          'NOW()',
          "TIMESTAMPTZ '" + instant + "'",
        );
        const rows = await runner.query(
          'SELECT * FROM (' + sql + ') v WHERE v."storeId"=$1',
          [store.id],
        );
        return rows[0].isOpen;
      }
      for (const zone of ['UTC', 'America/Bogota']) {
        await runner.query("SET TIME ZONE '" + zone + "'");
        eq(
          await openAt('2026-10-28 21:00:00+00'),
          true,
          '16:00 Ecuador is open in ' + zone,
        );
        eq(
          await openAt('2026-10-28 20:59:59+00'),
          false,
          'before opening in ' + zone,
        );
        eq(
          await openAt('2026-10-29 01:00:00+00'),
          false,
          'closing boundary in ' + zone,
        );
      }
      await runner.query(
        'UPDATE public.hours_operation SET open=$1,close=$2 WHERE "storeId"=$3',
        ['22:00:00', '02:00:00', store.id],
      );
      eq(
        await openAt('2026-10-29 06:00:00+00'),
        true,
        'overnight carries into the next day',
      );
      eq(
        await openAt('2026-10-29 07:00:00+00'),
        false,
        'overnight closing boundary',
      );
      await runner.query(
        'UPDATE public.hours_operation SET day=0 WHERE "storeId"=$1',
        [store.id],
      );
      eq(
        await openAt('2026-11-02 06:00:00+00'),
        true,
        'Sunday overnight carries into Monday',
      );
    } finally {
      await runner.query("SET TIME ZONE 'UTC'");
      await runner.release();
    }
    console.log(
      JSON.stringify({
        status: 'passed',
        checks,
        restaurants: 5,
        products: 30,
        coverage: [
          'real client contract',
          'seed idempotency',
          'edited data preserved',
          'menus',
          'categories',
          'soft deletes',
          'default address',
          'geographic fees',
          'database time zone',
          'overnight hours',
        ],
      }),
    );
  } finally {
    if (app) await app.close();
    if (db.isInitialized) await db.destroy();
    if (created) await admin.query('DROP DATABASE "' + name + '" WITH (FORCE)');
    await admin.end();
  }
}
main().catch((e) => {
  console.error(e.stack);
  process.exitCode = 1;
});
