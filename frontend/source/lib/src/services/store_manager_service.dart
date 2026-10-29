import 'package:delivery_app/src/models/company_product_model.dart';
import 'package:delivery_app/src/models/hour_model.dart';
import 'package:delivery_app/src/models/store_company_model.dart';
import 'package:delivery_app/src/services/restaurant_api.dart';

class StoreManagerService {
  Future<List<StoreCompanyModel>> getCompanies({
    bool throwOnError = false,
  }) async {
    try {
      return ((await restaurantApi('GET', 'manager/store/companies'))['stores']
              as List)
          .map((value) => StoreCompanyModel.fromJson(value))
          .toList();
    } catch (_) {
      if (throwOnError) rethrow;
      return [];
    }
  }

  Future<List<CompanyProductModel>> getProducts(
    int id, {
    bool throwOnError = false,
  }) async {
    try {
      return ((await restaurantApi(
                'GET',
                'manager/store/products/$id',
              ))['products']
              as List)
          .map((value) => CompanyProductModel.fromJson(value))
          .toList();
    } catch (_) {
      if (throwOnError) rethrow;
      return [];
    }
  }

  Future<List<HourModel>> getHours(int id, {bool throwOnError = false}) async {
    try {
      return ((await restaurantApi('GET', 'manager/store/hours/$id'))['hours']
              as List)
          .map((value) => HourModel.fromJson(value))
          .toList();
    } catch (_) {
      if (throwOnError) rethrow;
      return [];
    }
  }

  Future<HourModel> updateHour(
    HourModel hour, {
    bool throwOnError = false,
  }) async {
    try {
      return HourModel.fromJson(
        (await restaurantApi(
          'PATCH',
          'manager/store/hours/${hour.id}',
          body: hour.toHttpBodyUpdate(),
        ))['hour'],
      );
    } catch (_) {
      if (throwOnError) rethrow;
      return hour;
    }
  }

  Future<CompanyProductModel?> createProduct(
    CompanyProductModel product,
    int companyId,
  ) async {
    try {
      return CompanyProductModel.fromJson(
        (await restaurantApi(
          'POST',
          'manager/store/product',
          body: product.toHttpBodyCreate(companyId),
        ))['product'],
      );
    } catch (_) {
      return null;
    }
  }

  Future<CompanyProductModel?> updateProduct(
    CompanyProductModel product,
  ) async {
    try {
      return CompanyProductModel.fromJson(
        (await restaurantApi(
          'PATCH',
          'manager/store/product/${product.id}',
          body: product.toHttpBodyUpdate(),
        ))['product'],
      );
    } catch (_) {
      return null;
    }
  }
}
