const {
  existsSync,
  readFileSync,
  writeFileSync,
  mkdirSync,
} = require('node:fs');
const { join } = require('node:path');
const { randomBytes } = require('node:crypto');
const bcrypt = require('bcrypt');
const source = require('../dist/database/data-source').default;

async function main() {
  if (
    process.env.NODE_ENV !== 'development' ||
    !['localhost', '127.0.0.1', '::1'].includes(source.options.host)
  )
    throw Error('Restaurant demo data is only allowed in local development');
  const local = join(__dirname, '../.local');
  const file = join(local, 'restaurant-credentials.json');
  const previous = existsSync(file)
    ? JSON.parse(readFileSync(file, 'utf8'))
    : null;
  const email = previous?.email ?? 'restaurante.demo@delivery.local';
  const password =
    previous?.password ?? randomBytes(12).toString('base64url') + '!A1';
  const { User } = require('../dist/auth/entities/user.entity');
  const { Balance } = require('../dist/client/balance/entities/balance.entity');
  const { Company } = require('../dist/admin/company/entities/company.entity');
  const { Store } = require('../dist/admin/store/entities/store.entity');
  const {
    Category,
  } = require('../dist/admin/category/entities/category.entity');
  const {
    CompanyCategory,
  } = require('../dist/admin/company-category/entities/company-category.entity');
  const {
    HoursOperation,
  } = require('../dist/admin/hours-peration/entities/hours-peration.entity');
  const { Product } = require('../dist/admin/product/entities/product.entity');
  const { Order } = require('../dist/client/market/entities/order.entity');
  await source.initialize();
  try {
    const existing = await source.getRepository(User).findOneBy({ email });
    if (existing) {
      if (!previous || existing.id !== previous.managerId)
        throw Error(
          'The demo email belongs to an existing account; it was not changed',
        );
      if (
        !(await source.getRepository(Balance).existsBy({ userId: existing.id }))
      )
        await source
          .getRepository(Balance)
          .save({ userId: existing.id, user: existing });
      console.log(
        JSON.stringify({ status: 'already seeded', credentials: file }),
      );
      return;
    }
    const accounts = JSON.parse(
      readFileSync(join(local, 'credentials.json'), 'utf8'),
    ).accounts;
    const clientAccount = accounts.find(
      (account) =>
        account.roles.includes('client') && !account.roles.includes('admin'),
    );
    if (!clientAccount)
      throw Error(
        'Create the local client account before seeding the restaurant',
      );
    const customer = await source
      .getRepository(User)
      .findOneBy({ email: clientAccount.email });
    if (!customer)
      throw Error(
        'Create the local client account before seeding the restaurant',
      );
    const result = await source.transaction(async (manager) => {
      const save = (type, value) =>
        manager.save(type, manager.create(type, value));
      const user = await save(User, {
        email,
        password: await bcrypt.hash(password, 12),
        fullName: 'Restaurante de prueba',
        roles: ['manager'],
      });
      await save(Balance, { userId: user.id, user });
      const location = { x: -4.0236715, y: -79.1978733 };
      const company = await save(Company, {
        name: 'Restaurante de prueba',
        address: 'Dirección de demostración local',
        contact: '0990000001',
        email,
        image: '',
        marker: '',
        location: { ...location },
        user,
      });
      const category = await save(Category, {
        name: 'Demostración local',
        image: '',
      });
      await save(CompanyCategory, { company, category });
      const store = await save(Store, {
        name: 'Restaurante de prueba',
        address: 'Dirección de demostración local',
        contact: '0990000001',
        email,
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
          timeZone: -5,
        });
      const product = await save(Product, {
        name: 'Bowl de pollo · Prueba local',
        description:
          'Producto de demostración para revisar el menú y los pedidos.',
        price: 6.5,
        type: 1,
        image: '',
        company,
      });
      const order = await save(Order, {
        note: 'Demostración local',
        address: 'Dirección de prueba · Centro',
        products: [
          {
            id: product.id,
            name: product.name,
            description: product.description,
            image: '',
            price: 6.5,
            number: 2,
            total: 13,
            note: 'Sin cebolla en un bowl.',
          },
        ],
        deliveryFee: 1.5,
        total: 14.5,
        payment: 5001,
        location: { ...location },
        orderedAt: new Date(),
        user: customer,
        store,
      });
      return {
        email,
        password,
        managerId: user.id,
        companyId: company.id,
        storeId: store.id,
        productId: product.id,
        orderId: order.id,
        customerId: customer.id,
      };
    });
    mkdirSync(local, { recursive: true });
    writeFileSync(file, JSON.stringify(result, null, 2) + '\n', {
      mode: 0o600,
    });
    console.log(
      JSON.stringify({
        status: 'seeded',
        credentials: file,
        storeId: result.storeId,
        orderId: result.orderId,
      }),
    );
  } finally {
    await source.destroy();
  }
}
main().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
