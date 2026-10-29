import 'package:path/path.dart' as paths;
import 'package:path_provider/path_provider.dart';
import 'package:delivery_app/src/models/address_model.dart';
import 'package:delivery_app/src/models/product_model.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  static final DBProvider db = DBProvider();
  DBProvider({DatabaseFactory? databaseFactory, String? databasePath})
    : _factory = databaseFactory,
      _path = databasePath;

  final DatabaseFactory? _factory;
  final String? _path;
  Database? _database;
  Future<Database>? _opening;

  Future<Database> get database async {
    if (_database != null) return _database!;
    try {
      return _database = await (_opening ??= initDB());
    } catch (_) {
      _opening = null;
      rethrow;
    }
  }

  Future<Database> initDB() async {
    final path =
        _path ??
        paths.join(
          (await getApplicationDocumentsDirectory()).path,
          'delivery_app.db',
        );
    return (_factory ?? databaseFactory).openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE Product ('
            'id INTEGER PRIMARY KEY, companyId INTEGER, companyType INTEGER, '
            'companyName TEXT, storeId INTEGER, name TEXT, description TEXT, '
            'image TEXT, type INTEGER, number INTEGER, note TEXT, lt REAL, lg REAL, price REAL)',
          );
          await db.execute(
            'CREATE TABLE Address ('
            'id INTEGER PRIMARY KEY, alias TEXT, address TEXT, lt REAL, lg REAL)',
          );
        },
      ),
    );
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
    _opening = null;
  }

  Future<int> createProduct(
    ProductModel product,
    int companyType, {
    double lt = 0,
    double lg = 0,
  }) async {
    return (await database).insert('Product', {
      'id': product.id,
      'companyId': product.companyId,
      'companyType': companyType,
      'companyName': product.companyName,
      'name': product.name,
      'description': product.description,
      'image': product.image,
      'type': product.type,
      'price': product.price,
      'number': product.number,
      'note': product.note,
      'lt': lt,
      'lg': lg,
    });
  }

  Future<int> updateProduct(ProductModel product) async =>
      (await database).update(
        'Product',
        {'number': product.number, 'note': product.note},
        where: 'id = ?',
        whereArgs: [product.id],
      );

  Future<int> deleteProduct(ProductModel product) async =>
      (await database).delete(
        'Product',
        where: 'id = ? AND companyId = ?',
        whereArgs: [product.id, product.companyId],
      );

  Future<int> deleteProductByCompany(int companyId) async => (await database)
      .delete('Product', where: 'companyId = ?', whereArgs: [companyId]);

  Future<int> deleteAllProduct(int companyType) async => (await database)
      .delete('Product', where: 'companyType = ?', whereArgs: [companyType]);

  Future<List<ProductModel>> loadProducts(int companyType) async {
    final rows = await (await database).query(
      'Product',
      where: 'companyType = ?',
      whereArgs: [companyType],
      orderBy: 'companyId',
    );
    return rows.map(ProductModel.fromJson).toList();
  }

  Future<int> countProducts(int companyType) async =>
      Sqflite.firstIntValue(
        await (await database).rawQuery(
          'SELECT COUNT(*) FROM Product WHERE companyType = ?',
          [companyType],
        ),
      ) ??
      0;

  Future<int> createAddress(AddressModel address) async =>
      (await database).transaction((transaction) async {
        await transaction.delete('Address');
        return transaction.insert('Address', {
          'id': address.id,
          'alias': address.alias,
          'address': address.address,
          'lt': address.location.x,
          'lg': address.location.y,
        });
      });

  Future<AddressModel?> loadAddress() async {
    final rows = await (await database).query('Address');
    return rows.isEmpty ? null : AddressModel.fromJsonLocalDB(rows.first);
  }

  Future<int> deleteAddress() async => (await database).delete('Address');

  Future<int> deleteAddressByID(int id) async =>
      (await database).delete('Address', where: 'id = ?', whereArgs: [id]);
}
