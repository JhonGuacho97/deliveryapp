import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:delivery_app/constants/constants.dart';
import 'package:delivery_app/src/models/product_model.dart';
import 'package:delivery_app/src/provider/preferences_provider.dart';

class PaymentService {
  PaymentService({
    http.Client? client,
    String? baseUrl,
    String Function()? token,
  }) : _client = client,
       baseUrl = baseUrl ?? kDomain,
       _token = token ?? (() => PreferencesProvider().token);

  final http.Client? _client;
  final String baseUrl;
  final String Function() _token;

  Future<dynamic> _request(String method, String path, [Object? body]) async {
    final client = _client ?? http.Client();
    try {
      final request =
          http.Request(method, Uri.parse('${baseUrl}client/payments/$path'))
            ..headers.addAll({
              'Authorization': 'Bearer ${_token()}',
              'Content-Type': 'application/json; charset=UTF-8',
            });
      if (body != null) request.body = jsonEncode(body);
      final response = await http.Response.fromStream(
        await client.send(request).timeout(const Duration(seconds: 12)),
      ).timeout(const Duration(seconds: 12));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      }
    } catch (_) {
      // Provider payloads and authorization headers must not reach logs.
    } finally {
      if (_client == null) client.close();
    }
    return null;
  }

  Future<Map<String, dynamic>?> configuration() async {
    final result = await _request('GET', 'configuration');
    return result is Map<String, dynamic> ? result : null;
  }

  Future<Map<String, dynamic>?> payment(
    List<ProductModel> products,
    double money,
    String currency,
  ) async {
    final result = await _request('POST', 'payment', {
      'currency': currency,
      'money': money,
      'products': products.map((x) => x.toJson()).toList(),
    });
    return result is Map<String, dynamic> ? result : null;
  }

  Future<Map<String, dynamic>?> status(int id) async {
    final result = await _request('GET', '$id/status');
    return result is Map<String, dynamic> ? result : null;
  }

  Future<bool> confirm(int paymentId) async =>
      await _request('PATCH', 'confirm/$paymentId') == true;

  Future<bool> cancel(int paymentId) async =>
      await _request('PATCH', 'cancel/$paymentId') == true;
}
