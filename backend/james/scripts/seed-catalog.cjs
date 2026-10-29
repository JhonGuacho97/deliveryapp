const {
  existsSync,
  readFileSync,
  writeFileSync,
  mkdirSync,
} = require('node:fs');
const { join } = require('node:path');
const fixtures = require('./fixtures/catalog-demo.json');

async function seedCatalog(database, owner) {
  const { User } = require('../dist/auth/entities/user.entity');
  const { Company } = require('../dist/admin/company/entities/company.entity');
  const { Store } = require('../dist/admin/store/entities/store.entity');
  const {
    Category,
  } = require('../dist/admin/category/entities/category.entity');
  const {
    CompanyCategory,
  } = require('../dist/admin/company-category/entities/company-category.entity');
  const { Product } = require('../dist/admin/product/entities/product.entity');
  const {
    HoursOperation,
  } = require('../dist/admin/hours-peration/entities/hours-peration.entity');
  return database.transaction(async (manager) => {
    const save = (type, value) =>
      manager.save(type, manager.create(type, value));
    const user = await manager.findOneByOrFail(User, { id: owner.managerId });
    const result = {
      restaurants: [],
      updatedImages: { companies: 0, products: 0 },
      created: {
        companies: 0,
        stores: 0,
        products: 0,
        categories: 0,
        links: 0,
        hours: 0,
      },
    };
    for (const spec of fixtures) {
      let company = spec.primary
        ? await manager.findOneByOrFail(Company, { id: owner.companyId })
        : await manager.findOne(Company, {
            where: { name: spec.name },
            relations: { user: true },
          });
      if (company && !spec.primary && company.user?.id !== user.id)
        throw Error('Demo name belongs to another account: ' + spec.name);
      if (!company) {
        company = await save(Company, {
          name: spec.name,
          address: spec.address,
          contact: '0990000001',
          email: user.email,
          image: spec.image || '',
          marker: '',
          location: spec.location,
          user,
        });
        result.created.companies++;
      }
      const owned = await manager.findOne(Company, {
        where: { id: company.id },
        relations: { user: true },
      });
      if (owned.user?.id !== user.id)
        throw Error('Demo company ownership mismatch');
      if (!owned.image && spec.image) {
        await manager.update(
          Company,
          { id: company.id },
          { image: spec.image },
        );
        result.updatedImages.companies++;
      }
      let store = spec.primary
        ? await manager.findOneByOrFail(Store, { id: owner.storeId })
        : await manager.findOne(Store, {
            where: { company: { id: company.id } },
            select: { id: true, name: true, deletedAt: true },
            withDeleted: true,
          });
      if (store?.deletedAt)
        throw Error('A demo store was deleted; it was not restored');
      if (!store) {
        store = await save(Store, {
          name: spec.name,
          address: spec.address,
          contact: '0990000001',
          email: user.email,
          location: spec.location,
          company,
          user,
        });
        result.created.stores++;
        for (let day = 0; day < 7; day++) {
          await save(HoursOperation, {
            store,
            day,
            open: '00:00:00',
            close: '23:59:59',
            timeZone: -5,
          });
          result.created.hours++;
        }
      }
      let category = await manager.findOneBy(Category, { name: spec.category });
      if (!category) {
        category = await save(Category, { name: spec.category, image: '' });
        result.created.categories++;
      }
      if (
        !(await manager.existsBy(CompanyCategory, {
          company: { id: company.id },
          category: { id: category.id },
        }))
      ) {
        await save(CompanyCategory, { company, category });
        result.created.links++;
      }
      const products = [];
      for (let index = 0; index < spec.menu.length; index++) {
        const [name, price, description, image = ''] = spec.menu[index];
        const existing =
          spec.primary && index === 0 && owner.productId
            ? await manager.findOne(Product, {
                where: { id: owner.productId },
                select: {
                  id: true,
                  name: true,
                  price: true,
                  image: true,
                  deletedAt: true,
                  company: { id: true },
                },
                relations: { company: true },
                withDeleted: true,
              })
            : await manager.findOne(Product, {
                where: { name },
                select: {
                  id: true,
                  name: true,
                  price: true,
                  image: true,
                  deletedAt: true,
                  company: { id: true },
                },
                relations: { company: true },
                withDeleted: true,
              });
        if (existing && existing.company.id !== company.id)
          throw Error('Demo product belongs to another company: ' + name);
        let product = existing;
        if (!product) {
          product = await save(Product, {
            name,
            price,
            description,
            image,
            type: 1,
            company,
          });
          result.created.products++;
        } else if (!product.deletedAt && !product.image && image) {
          await manager.update(Product, { id: product.id }, { image });
          result.updatedImages.products++;
        }
        products.push({
          id: product.id,
          name: product.name,
          price: product.price,
          deleted: !!product.deletedAt,
        });
      }
      result.restaurants.push({
        companyId: company.id,
        storeId: store.id,
        name: store.name,
        category: category.name,
        products,
      });
    }
    return result;
  });
}
async function main() {
  const database = require('../dist/database/data-source').default;
  if (
    process.env.NODE_ENV !== 'development' ||
    !['localhost', '127.0.0.1', '::1'].includes(database.options.host)
  )
    throw Error('Catalog demo data requires local development');
  const local = join(__dirname, '../.local'),
    ownerFile = join(local, 'restaurant-credentials.json');
  if (!existsSync(ownerFile)) throw Error('Run db:seed:restaurant first');
  const owner = JSON.parse(readFileSync(ownerFile, 'utf8'));
  await database.initialize();
  try {
    const result = await seedCatalog(database, owner);
    mkdirSync(local, { recursive: true });
    const file = join(local, 'catalog-demo.json');
    writeFileSync(file, JSON.stringify(result, null, 2) + '\n');
    console.log(
      JSON.stringify({
        status: 'seeded',
        restaurants: result.restaurants.length,
        products: result.restaurants.reduce(
          (n, r) => n + r.products.filter((p) => !p.deleted).length,
          0,
        ),
        created: result.created,
        updatedImages: result.updatedImages,
        report: file,
      }),
    );
  } finally {
    await database.destroy();
  }
}
module.exports = { seedCatalog };
if (require.main === module)
  main().catch((e) => {
    console.error(e.message);
    process.exitCode = 1;
  });
