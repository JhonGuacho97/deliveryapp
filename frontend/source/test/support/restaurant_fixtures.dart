import 'package:delivery_app/constants/preparation_status.dart';
import 'package:delivery_app/src/models/company_product_model.dart';
import 'package:delivery_app/src/models/hour_model.dart';
import 'package:delivery_app/src/models/request_model.dart';
import 'package:delivery_app/src/models/store_company_model.dart' as stores;
import 'package:delivery_app/src/services/request_service.dart';
import 'package:delivery_app/src/services/store_manager_service.dart';
import 'package:delivery_app/src/services/restaurant_api.dart';

RequestModel restaurantOrder({
  int id = 1024,
  String? preparation = PreparationStatus.pending,
  int status = 1,
}) => RequestModel.fromJson({
  'id': id,
  'note': 'Casa',
  'address': 'Calle Norte 125 · Centro',
  'status': status,
  'preparationStatus': preparation,
  'preparationMinutes': preparation == PreparationStatus.preparing ? 25 : null,
  'products': [
    {
      'id': 1,
      'name': 'Bowl de pollo',
      'description': 'Pollo, vegetales y arroz fresco.',
      'price': 6.5,
      'number': 2,
      'total': 13,
      'image': '',
      'note': 'Sin cebolla en un bowl.',
    },
  ],
  'deliveryFee': 1.5,
  'total': 14.5,
  'location': {'x': -0.2, 'y': -78.5},
  'createdAt': '2026-10-28T12:00:00Z',
  'user': {
    'id': 7,
    'fullName': 'Cliente de prueba',
    'phone': '0900000000',
    'image': '',
  },
  'store': {
    'id': 1,
    'name': 'Casa Verde',
    'address': 'Calle Principal 320',
    'contact': '0900000001',
    'location': {'x': -0.21, 'y': -78.51},
    'company': {'image': ''},
  },
  'payment': 5001,
  'notificationsDeliveryman': 0,
});
stores.StoreCompanyModel restaurantStore() =>
    stores.StoreCompanyModel.fromJson({
      'id': 1,
      'name': 'Casa Verde',
      'address': 'Calle Principal 320',
      'contact': '0900000001',
      'email': 'restaurante@example.test',
      'startupCost': 1.25,
      'costKm': 0.55,
      'location': {'x': -0.2, 'y': -78.5},
      'sales': 0,
      'createdAt': '2026-10-28T12:00:00Z',
      'updatedAt': '2026-10-28T12:00:00Z',
      'company': {
        'id': 1,
        'name': 'Casa Verde',
        'address': 'Calle Principal 320',
        'contact': '0900000001',
        'email': 'restaurante@example.test',
        'image': '',
        'marker': '',
        'location': {'x': -0.2, 'y': -78.5},
        'createdAt': '2026-10-28T12:00:00Z',
        'updatedAt': '2026-10-28T12:00:00Z',
        'categories': [],
      },
    });

class RestaurantRequestsFixture extends RequestService {
  List<RequestModel> records = [restaurantOrder()];
  int accepts = 0, readies = 0;
  bool fail = false;
  @override
  Future<List<RequestModel>> findNearRequests({
    bool throwOnError = false,
  }) async {
    if (fail) throw const RestaurantApiException(0);
    return records
        .map((value) => RequestModel.fromJson(value.toJson()))
        .toList();
  }

  @override
  Future<List<RequestModel>> history(String day, {bool throwOnError = false}) =>
      findNearRequests(throwOnError: throwOnError);
  @override
  Future<RequestModel> findRequest(
    RequestModel request, {
    bool throwOnError = false,
  }) async => RequestModel.fromJson(
    records.firstWhere((value) => value.id == request.id).toJson(),
  );
  @override
  Future<RequestModel> accept(int id, int minutes) async {
    accepts++;
    if (fail) throw const RestaurantApiException(409);
    final order = records.firstWhere((value) => value.id == id)
      ..preparationStatus = PreparationStatus.preparing
      ..preparationMinutes = minutes
      ..acceptedAt = DateTime(2026, 10, 28, 12);
    return RequestModel.fromJson(order.toJson());
  }

  @override
  Future<RequestModel> ready(int id) async {
    readies++;
    if (fail) throw const RestaurantApiException(409);
    final order = records.firstWhere((value) => value.id == id)
      ..preparationStatus = PreparationStatus.ready
      ..readyAt = DateTime(2026, 10, 28, 12, 25);
    return RequestModel.fromJson(order.toJson());
  }
}

class RestaurantStoreFixture extends StoreManagerService {
  bool fail = false;
  List<CompanyProductModel> products = [
    CompanyProductModel(
      id: 1,
      name: 'Bowl de pollo',
      description: 'Pollo, vegetales y arroz fresco.',
      price: 6.5,
    ),
  ];
  List<HourModel> hours = [
    HourModel(id: 1, day: 1, open: '08:00:00', close: '22:00:00'),
  ];
  @override
  Future<List<stores.StoreCompanyModel>> getCompanies({
    bool throwOnError = false,
  }) async => [restaurantStore()];
  @override
  Future<List<CompanyProductModel>> getProducts(
    int id, {
    bool throwOnError = false,
  }) async =>
      products.map((p) => CompanyProductModel.fromJson(p.toJson())).toList();
  @override
  Future<List<HourModel>> getHours(int id, {bool throwOnError = false}) async =>
      hours.map((h) => HourModel.fromJson(h.toJson())).toList();
  @override
  Future<CompanyProductModel?> updateProduct(
    CompanyProductModel product,
  ) async {
    if (fail) return null;
    final saved = CompanyProductModel.fromJson(product.toJson());
    products[products.indexWhere((p) => p.id == product.id)] = saved;
    return saved;
  }

  @override
  Future<CompanyProductModel?> createProduct(
    CompanyProductModel product,
    int companyId,
  ) async {
    if (fail) return null;
    final saved = CompanyProductModel.fromJson({
      ...product.toJson(),
      'id': products.length + 1,
    });
    products.add(saved);
    return saved;
  }

  @override
  Future<HourModel> updateHour(
    HourModel hour, {
    bool throwOnError = false,
  }) async {
    if (fail) throw const RestaurantApiException(0);
    final saved = HourModel.fromJson(hour.toJson());
    hours[hours.indexWhere((h) => h.id == hour.id)] = saved;
    return saved;
  }
}
