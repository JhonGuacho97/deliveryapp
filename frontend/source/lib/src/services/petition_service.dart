import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:planck/constants/constants.dart';
import 'package:planck/src/models/petition_model.dart';
import 'package:planck/src/provider/preferences_provider.dart';

class CourierApiException implements Exception {
  const CourierApiException(this.status, [this.code]);
  final int status;
  final int? code;
}

class CourierFeed {
  const CourierFeed(this.petitions, this.isOnline);
  final List<PetitionModel> petitions;
  final bool isOnline;
}

class CourierEarnings {
  const CourierEarnings({
    required this.day,
    required this.completedCount,
    required this.earnings,
    this.operatingBalance,
    this.settlementAmount,
    this.unpricedCount = 0,
    this.deliveries = const [],
  });
  final String day;
  final int completedCount, unpricedCount;
  final double earnings;
  final double? operatingBalance, settlementAmount;
  final List<PetitionModel> deliveries;
  factory CourierEarnings.fromJson(Map<String, dynamic> json) =>
      CourierEarnings(
        day: json['day'],
        completedCount: json['completedCount'],
        earnings: (json['earnings'] as num).toDouble(),
        unpricedCount: json['unpricedCount'] ?? 0,
        operatingBalance: (json['operatingBalance'] as num?)?.toDouble(),
        settlementAmount: (json['settlementAmount'] as num?)?.toDouble(),
        deliveries: [
          for (final item in json['deliveries'] ?? [])
            PetitionModel.fromJson(item),
        ],
      );
}

class PetitionService {
  final prefs = PreferencesProvider();
  Future<dynamic> _request(String path, {Map<String, dynamic>? body}) async {
    final client = http.Client();
    try {
      final uri = Uri.parse(
        '$kDomain'
        'deliveryman/petition/$path',
      );
      final headers = {
        'Authorization': 'Bearer ${prefs.token}',
        'Content-Type': 'application/json; charset=UTF-8',
      };
      final response =
          await (body == null
                  ? client.get(uri, headers: headers)
                  : client.patch(uri, headers: headers, body: jsonEncode(body)))
              .timeout(const Duration(seconds: 20));
      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        throw CourierApiException(response.statusCode);
      }
      if (response.statusCode != 200)
        throw CourierApiException(
          response.statusCode,
          decoded is Map ? decoded['codeError'] as int? : null,
        );
      return decoded;
    } finally {
      client.close();
    }
  }

  Future<CourierFeed> readFeed() async {
    final data = await _request('near/?idDevice=${prefs.idDevice}');
    return CourierFeed([
      for (final p in data['petitions']) PetitionModel.fromJson(p),
    ], data['isOnline'] == true);
  }

  Future<PetitionModel> readDelivery(int id) async =>
      PetitionModel.fromJson((await _request('id/$id'))['petition']);
  Future<CourierEarnings> readEarnings(String day) async =>
      CourierEarnings.fromJson(await _request('earnings/$day'));
  Future<PetitionModel> changeDelivery(int id, String action) async =>
      PetitionModel.fromJson(
        (await _request('$action/$id', body: {}))['petition'],
      );
  Future<void> setAvailability(
    bool online,
    double latitude,
    double longitude,
  ) async {
    final result = await _request(
      'activate/',
      body: {
        'idDevice': prefs.idDevice,
        'isOnline': online,
        'latitude': latitude,
        'longitude': longitude,
      },
    );
    if (result != true) throw const CourierApiException(502);
  }

  Future<List<PetitionModel>> readHistory(String day) async => [
    for (final p in (await _request('ordered-at/$day'))['petitions'])
      PetitionModel.fromJson(p),
  ];

  // Compatibility for older routes. Failures propagate instead of masquerading as success.
  Future<PetitionModel> findPetition(PetitionModel p) => readDelivery(p.id);
  Future<List<PetitionModel>> findNearPetitions() async =>
      (await readFeed()).petitions;
  Future<List<PetitionModel>> history(String day) => readHistory(day);
  Future<PetitionModel> collect(PetitionModel p) =>
      changeDelivery(p.id, 'collect');
  Future<PetitionModel> cancel(PetitionModel p) =>
      changeDelivery(p.id, 'cancel');
  Future<bool> deliver(PetitionModel p) async {
    await changeDelivery(p.id, 'deliver');
    return true;
  }

  Future<Map<String, dynamic>?> apply(PetitionModel p) async => {
    'petition': (await changeDelivery(p.id, 'apply')).toJson(),
  };
  Future<bool> activate(
    bool online,
    dynamic latitude,
    dynamic longitude,
  ) async {
    await setAvailability(
      online,
      (latitude as num).toDouble(),
      (longitude as num).toDouble(),
    );
    return true;
  }
}
