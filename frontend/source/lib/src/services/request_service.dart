import 'package:planck/src/models/request_model.dart';
import 'package:planck/src/provider/preferences_provider.dart';
import 'package:planck/src/services/restaurant_api.dart';

class RequestService {
  Future<RequestModel> findRequest(
    RequestModel request, {
    bool throwOnError = false,
  }) async {
    try {
      return RequestModel.fromJson(
        (await restaurantApi(
          'GET',
          'manager/request/id/${request.id}',
        ))['request'],
      );
    } catch (_) {
      if (throwOnError) rethrow;
      return request;
    }
  }

  Future<List<RequestModel>> findNearRequests({
    bool throwOnError = false,
  }) async {
    try {
      final data = await restaurantApi(
        'GET',
        'manager/request/near/?idDevice=${PreferencesProvider().idDevice}',
      );
      return (data['requests'] as List)
          .map((value) => RequestModel.fromJson(value))
          .toList();
    } catch (_) {
      if (throwOnError) rethrow;
      return [];
    }
  }

  Future<List<RequestModel>> history(
    String day, {
    bool throwOnError = false,
  }) async {
    try {
      final data = await restaurantApi(
        'GET',
        'manager/request/ordered-at/$day',
      );
      return (data['requests'] as List)
          .map((value) => RequestModel.fromJson(value))
          .toList();
    } catch (_) {
      if (throwOnError) rethrow;
      return [];
    }
  }

  Future<RequestModel> accept(int id, int minutes) async =>
      RequestModel.fromJson(
        (await restaurantApi(
          'PATCH',
          'manager/request/$id/accept',
          body: {'preparationMinutes': minutes},
        ))['request'],
      );
  Future<RequestModel> ready(int id) async => RequestModel.fromJson(
    (await restaurantApi('PATCH', 'manager/request/$id/ready'))['request'],
  );
}
