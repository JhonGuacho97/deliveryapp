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
    throw Error('Courier demo data requires local development');
  const local = join(__dirname, '../.local'),
    file = join(local, 'courier-credentials.json');
  const previous = existsSync(file)
    ? JSON.parse(readFileSync(file, 'utf8'))
    : null;
  const email = previous?.email ?? 'motorizado.demo@delivery.local',
    password =
      previous?.password ?? randomBytes(12).toString('base64url') + '!A1';
  const { User } = require('../dist/auth/entities/user.entity'),
    { Order } = require('../dist/client/market/entities/order.entity'),
    { Store } = require('../dist/admin/store/entities/store.entity'),
    { Product } = require('../dist/admin/product/entities/product.entity'),
    { Balance } = require('../dist/client/balance/entities/balance.entity');
  await source.initialize();
  try {
    const existing = await source.getRepository(User).findOneBy({ email });
    if (existing) {
      if (!previous || previous.courierId !== existing.id)
        throw Error('Existing demo email was not changed');
      console.log(
        JSON.stringify({ status: 'already seeded', credentials: file }),
      );
      return;
    }
    const restaurant = JSON.parse(
      readFileSync(join(local, 'restaurant-credentials.json'), 'utf8'),
    );
    const store = await source
      .getRepository(Store)
      .findOneByOrFail({ id: restaurant.storeId });
    const customer = await source
      .getRepository(User)
      .findOneByOrFail({ id: restaurant.customerId });
    const product = await source
      .getRepository(Product)
      .findOneByOrFail({ id: restaurant.productId });
    const result = await source.transaction(async (manager) => {
      const user = await manager.save(
        User,
        manager.create(User, {
          email,
          password: await bcrypt.hash(password, 12),
          fullName: 'Motorizado de prueba',
          roles: ['deliveryman'],
          phone: '0990000003',
        }),
      );
      await manager.save(
        Balance,
        manager.create(Balance, { userId: user.id, user, balance: 20 }),
      );
      const order = await manager.save(
        Order,
        manager.create(Order, {
          note: 'Demostración local de reparto',
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
          location: { x: -4.0242, y: -79.199 },
          orderedAt: new Date(),
          user: customer,
          store,
          preparationStatus: 'ready',
          preparationMinutes: 15,
          acceptedAt: new Date(),
          readyAt: new Date(),
        }),
      );
      return {
        email,
        password,
        courierId: user.id,
        orderId: order.id,
        storeId: store.id,
        demoOperatingBalance: 20,
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
