import 'dart:async';

import 'package:delivery_app/constants/code_error_constant.dart';
import 'package:delivery_app/src/bloc/location_bloc.dart';
import 'package:delivery_app/src/models/petition_model.dart';
import 'package:delivery_app/src/services/petition_service.dart';
import 'package:delivery_app/src/screens/deliveryman/petitions/petitions_controller.dart';

import 'restaurant_fixtures.dart';

PetitionModel courierOrder({
  int id = 2048,
  int status = 1,
  bool mine = false,
  String? preparation = 'ready',
}) {
  final json = restaurantOrder(
    id: id,
    status: status,
    preparation: preparation,
  ).toJson();
  json.addAll({
    'isAssignedToMe': mine,
    'estimatedProfit': 1.28,
    'deliverymanProfit': mine ? 1.28 : null,
    'pickupDistanceMeters': 850.0,
    'tripDistanceMeters': 2400.0,
    'assignedAt': mine ? '2026-10-28T12:00:00Z' : null,
  });
  return PetitionModel.fromJson(json);
}

class CourierLocationFixture extends LocationBloc {
  CourierLocationFixture() : super.testing();
  bool enabled = true, running = false;
  int requests = 0;
  @override
  Future<List<double>?> currentPosition() async {
    requests++;
    return enabled ? [-4.0236715, -79.1978733] : null;
  }

  @override
  Future<bool> start() async {
    running = enabled;
    return enabled;
  }

  @override
  Future<void> stop() async {
    running = false;
  }
}

class CourierFixture extends PetitionService {
  List<PetitionModel> records = [courierOrder()];
  bool online = false, fail = false;
  int mutations = 0, availabilityChanges = 0;
  Completer<void>? gate;
  @override
  Future<CourierFeed> readFeed() async {
    if (fail) throw const CourierApiException(503);
    return CourierFeed(
      records
          .where(
            (p) =>
                (p.isAssignedToMe && p.status < 200) ||
                (online && !p.isAssignedToMe && p.status == 1),
          )
          .map((p) => PetitionModel.fromJson(p.toJson()))
          .toList(),
      online,
    );
  }

  @override
  Future<PetitionModel> readDelivery(int id) async {
    if (fail) throw const CourierApiException(503);
    return PetitionModel.fromJson(
      records.firstWhere((p) => p.id == id).toJson(),
    );
  }

  @override
  Future<void> setAvailability(bool value, double lat, double lng) async {
    if (fail) throw const CourierApiException(503);
    availabilityChanges++;
    online = value;
  }

  @override
  Future<PetitionModel> changeDelivery(int id, String action) async {
    mutations++;
    await gate?.future;
    if (fail) throw const CourierApiException(409);
    final p = records.firstWhere((p) => p.id == id);
    if (action == 'apply') {
      p.isAssignedToMe = true;
      p.status = 100;
      p.deliverymanProfit = 1.28;
      p.assignedAt = DateTime.now();
    }
    if (action == 'collect') {
      if (p.preparationStatus == 'preparing')
        throw const CourierApiException(409);
      p.status = 101;
      p.collectedAt = DateTime.now();
    }
    if (action == 'deliver') {
      p.status = 200;
      p.deliveredAt = DateTime.now();
    }
    if (action == 'cancel') {
      p.status = 400;
      p.cancelledAt = DateTime.now();
    }
    return PetitionModel.fromJson(p.toJson());
  }

  @override
  Future<CourierEarnings> readEarnings(String day) async {
    if (fail) throw const CourierApiException(503);
    final completed = records.where((p) => p.status == 200).toList();
    return CourierEarnings(
      day: day,
      completedCount: completed.length,
      earnings: completed.length * 1.28,
      operatingBalance: 20,
      settlementAmount: 0,
      deliveries: completed,
    );
  }

  @override
  Future<List<PetitionModel>> readHistory(String day) async =>
      records.where((p) => p.isAssignedToMe).toList();
}

class CourierControllerFixture extends PetitionsController {
  CourierControllerFixture(
    CourierFixture service,
    CourierLocationFixture location,
  ) : super(
        service: service,
        location: location,
        notifications: const Stream.empty(),
        loadOnCreate: false,
      );
  @override
  Future<int> checkSession() async => CodeError.none;
}
