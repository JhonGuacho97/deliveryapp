import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:delivery_app/constants/constants.dart';
import 'package:delivery_app/src/provider/preferences_provider.dart';

class RestaurantApiException implements Exception {
  const RestaurantApiException(this.statusCode);
  final int statusCode;
}

Future<Map<String, dynamic>> restaurantApi(
  String method,
  String path, {
  Object? body,
}) async {
  final client = http.Client();
  final uri = Uri.parse('$kDomain$path');
  final headers = {
    'Authorization': 'Bearer ${PreferencesProvider().token}',
    'Content-Type': 'application/json; charset=UTF-8',
  };
  final encoded = body is String
      ? body
      : body == null
      ? null
      : jsonEncode(body);
  try {
    final response = await (switch (method) {
      'POST' => client.post(uri, headers: headers, body: encoded),
      'PATCH' => client.patch(uri, headers: headers, body: encoded),
      _ => client.get(uri, headers: headers),
    }).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200 && response.statusCode != 201)
      throw RestaurantApiException(response.statusCode);
    return jsonDecode(response.body) as Map<String, dynamic>;
  } on RestaurantApiException {
    rethrow;
  } catch (_) {
    throw const RestaurantApiException(0);
  } finally {
    client.close();
  }
}
