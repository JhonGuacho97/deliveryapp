import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:planck/src/models/address_model.dart';
import 'package:planck/src/models/product_model.dart';
import 'package:planck/src/provider/db_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  late DBProvider database;
  setUp(
    () => database = DBProvider(
      databaseFactory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    ),
  );
  tearDown(() => database.close());

  ProductModel product(int id, {int company = 2}) => ProductModel(
    id: id,
    companyId: company,
    companyName: "Chef's local",
    name: "Combo O'Reilly",
    description: "Sin 'picante'",
    type: 1,
    price: 3.25,
    image: '',
    note: "Cliente's nota",
  );
  AddressModel address(int id) => AddressModel(
    id: id,
    alias: "Casa O'Reilly",
    address: "Calle 'A'",
    location: Location(x: -0.2, y: -78.5),
  );

  test('cart stores quoted text with parameterized SQL', () async {
    await database.createProduct(product(1), 1);
    final rows = await database.loadProducts(1);
    expect(rows.single.name, "Combo O'Reilly");
    expect(rows.single.companyName, "Chef's local");
    expect(rows.single.note, "Cliente's nota");
    expect(rows.single.price, 3.25);
  });

  test('updates quantity and note without changing other products', () async {
    await database.createProduct(product(1), 1);
    await database.createProduct(product(2), 1);
    final changed = product(1)
      ..number = 4
      ..note = "Más 'salsa'";
    await database.updateProduct(changed);
    final rows = await database.loadProducts(1);
    expect(rows.first.number, 4);
    expect(rows.first.note, "Más 'salsa'");
    expect(rows.last.number, 1);
  });

  test('keeps store and taxi carts isolated', () async {
    await database.createProduct(product(1), 1);
    await database.createProduct(product(2), 2, lt: -0.2, lg: -78.5);
    await database.deleteAllProduct(1);
    expect(await database.countProducts(1), 0);
    expect(await database.countProducts(2), 1);
    expect((await database.loadProducts(2)).single.lt, -0.2);
  });

  test('removing a company preserves products from other companies', () async {
    await database.createProduct(product(1), 1);
    await database.createProduct(product(2, company: 3), 1);
    await database.deleteProductByCompany(2);
    expect((await database.loadProducts(1)).single.id, 2);
  });

  test(
    'replaces the selected address atomically and preserves coordinates',
    () async {
      await database.createAddress(address(1));
      await database.createAddress(address(2));
      expect((await database.loadAddress())!.id, 2);
      expect((await database.loadAddress())!.address, "Calle 'A'");
      expect((await database.loadAddress())!.location.y, -78.5);
      await database.deleteAddressByID(1);
      expect(await database.loadAddress(), isNotNull);
      await database.deleteAddressByID(2);
      expect(await database.loadAddress(), isNull);
    },
  );

  test('concurrent callers share the same initialized database', () async {
    await Future.wait([
      database.createProduct(product(1), 1),
      database.createAddress(address(1)),
    ]);
    expect(await database.countProducts(1), 1);
    expect(await database.loadAddress(), isNotNull);
  });

  test('existing version 2 data survives closing and reopening', () async {
    final directory = await Directory.systemTemp.createTemp(
      'delivery-sqlite-migration-',
    );
    final path = '${directory.path}/fixture.db';
    final first = DBProvider(
      databaseFactory: databaseFactoryFfi,
      databasePath: path,
    );
    final second = DBProvider(
      databaseFactory: databaseFactoryFfi,
      databasePath: path,
    );
    try {
      await first.createProduct(product(1), 1);
      await first.createAddress(address(1));
      await first.close();
      expect(await second.countProducts(1), 1);
      expect((await second.loadAddress())!.alias, "Casa O'Reilly");
    } finally {
      await first.close();
      await second.close();
      expect(
        directory.absolute.path,
        startsWith(Directory.systemTemp.absolute.path),
      );
      await directory.delete(recursive: true);
    }
  });
}
