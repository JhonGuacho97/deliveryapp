import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/models/petition_model.dart';
import 'package:planck/src/provider/preferences_provider.dart';
import 'package:planck/src/screens/deliveryman/petitions/petitions_screen.dart';
import 'package:planck/src/screens/deliveryman/petitions/petitions_controller.dart';
import 'package:planck/src/screens/deliveryman/petitions/courier_widgets.dart';
import 'package:planck/src/services/petition_service.dart';
import 'package:planck/theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/courier_fixtures.dart';

class _DelayedCourier extends CourierFixture {
  Completer<void>? feedGate, incomeGate;
  @override
  Future<CourierFeed> readFeed() async {
    final result = await super.readFeed();
    final gate = feedGate;
    feedGate = null;
    await gate?.future;
    return result;
  }

  @override
  Future<CourierEarnings> readEarnings(String day) async {
    final result = await super.readEarnings(day);
    final gate = incomeGate;
    incomeGate = null;
    await gate?.future;
    return result;
  }
}

Future<void> courierApp(
  WidgetTester tester,
  PetitionsController c, {
  bool dark = false,
}) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<PetitionsController>.value(
      value: c,
      child: Builder(
        builder: (context) => MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: const Locale('es'),
          supportedLocales: S.delegate.supportedLocales,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: dark ? darkThemeData(context) : lightThemeData(context),
          home: const PetitionsScreen(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test(
    'a feed started before acceptance cannot restore an unassigned offer',
    () async {
      final service = _DelayedCourier()..online = true;
      final c = CourierControllerFixture(service, CourierLocationFixture());
      addTearDown(c.dispose);
      await c.loadPetitions();
      final p = c.petitions.single;
      final gate = Completer<void>();
      service.feedGate = gate;
      final stale = c.loadPetitions();
      await Future<void>.delayed(Duration.zero);
      expect(await c.act(p, 'apply'), isTrue);
      gate.complete();
      await stale;
      expect(c.active.single.status, 100);
      expect(c.offers, isEmpty);
    },
  );
  test(
    'an older income response cannot erase a newly completed delivery',
    () async {
      final service = _DelayedCourier()
        ..records = [courierOrder(status: 101, mine: true)];
      final c = CourierControllerFixture(service, CourierLocationFixture());
      addTearDown(c.dispose);
      final gate = Completer<void>();
      service.incomeGate = gate;
      final stale = c.loadEarnings();
      await Future<void>.delayed(Duration.zero);
      expect(await c.act(service.records.single, 'deliver'), isTrue);
      await Future<void>.delayed(Duration.zero);
      gate.complete();
      await stale;
      expect(c.earnings!.earnings, 1.28);
      expect(c.earnings!.completedCount, 1);
    },
  );
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'uuid': '0a824db1-708e-4bf1-a50d-76c441073069',
      'token': 'fixture',
    });
    await PreferencesProvider().init();
    await S.load(const Locale('es'));
  });
  test(
    'lifecycle timestamps, snapshot profit and distances survive a round trip',
    () {
      final p = courierOrder(mine: true);
      p.deliveredAt = DateTime.utc(2026, 10, 28);
      p.collectedAt = DateTime.utc(2026, 10, 28, 1);
      final restored = PetitionModel.fromJson(p.toJson());
      expect(restored.isAssignedToMe, isTrue);
      expect(restored.deliverymanProfit, 1.28);
      expect(restored.deliveredAt, p.deliveredAt);
      expect(restored.collectedAt, p.collectedAt);
      expect(restored.tripDistanceMeters, 2400);
    },
  );
  test(
    'availability requires fresh GPS and persists only server confirmation',
    () async {
      final service = CourierFixture(),
          location = CourierLocationFixture()..enabled = false;
      final c = CourierControllerFixture(service, location);
      addTearDown(c.dispose);
      expect(await c.setAvailability(true), isFalse);
      expect(c.isOnline, isFalse);
      expect(service.availabilityChanges, 0);
      location.enabled = true;
      service.fail = true;
      expect(await c.setAvailability(true), isFalse);
      expect(c.isOnline, isFalse);
      service.fail = false;
      expect(await c.setAvailability(true), isTrue);
      expect(c.isOnline, isTrue);
      expect(PreferencesProvider().isOnline, isTrue);
    },
  );
  test(
    'disconnect does not ask for GPS and retains active deliveries',
    () async {
      final service = CourierFixture()
        ..online = true
        ..records = [courierOrder(mine: true, status: 100)];
      final location = CourierLocationFixture();
      final c = CourierControllerFixture(service, location);
      addTearDown(c.dispose);
      await c.loadPetitions();
      expect(await c.setAvailability(false), isTrue);
      await Future<void>.delayed(Duration.zero);
      expect(location.requests, 0);
      expect(c.active, hasLength(1));
      expect(location.running, isTrue);
    },
  );
  test(
    'failed action never changes the local order or reports success',
    () async {
      final service = CourierFixture()..online = true;
      final c = CourierControllerFixture(service, CourierLocationFixture());
      addTearDown(c.dispose);
      await c.loadPetitions();
      final p = c.petitions.single;
      service.fail = true;
      expect(await c.act(p, 'apply'), isFalse);
      expect(c.current(p).status, 1);
      expect(c.error, 'changed');
    },
  );
  test('double tap only submits one acceptance', () async {
    final service = CourierFixture()
      ..online = true
      ..gate = Completer<void>();
    final c = CourierControllerFixture(service, CourierLocationFixture());
    addTearDown(c.dispose);
    await c.loadPetitions();
    final p = c.petitions.single, first = c.act(c.petitions.single, 'apply');
    expect(await c.act(p, 'apply'), isFalse);
    expect(service.mutations, 1);
    service.gate!.complete();
    expect(await first, isTrue);
    expect(c.current(p).status, 100);
  });
  test(
    'HTTP rejection propagates and delivery sends no fabricated rating',
    () async {
      await http.runWithClient(
        () async {
          final service = PetitionService();
          await expectLater(
            service.changeDelivery(1, 'collect'),
            throwsA(isA<CourierApiException>()),
          );
          final delivered = await service.changeDelivery(2, 'deliver');
          expect(delivered.status, 200);
        },
        () => MockClient((request) async {
          if (request.url.path.contains('/collect/'))
            return http.Response('{"message":"not ready"}', 409);
          expect(jsonDecode(request.body), isEmpty);
          return http.Response(
            jsonEncode({
              'petition': courierOrder(status: 200, mine: true).toJson(),
            }),
            200,
          );
        }),
      );
    },
  );
  test(
    'income uses recorded earnings, not operating balance or delivery charge',
    () async {
      final c = CourierControllerFixture(
        CourierFixture()..records = [courierOrder(mine: true, status: 200)],
        CourierLocationFixture(),
      );
      addTearDown(c.dispose);
      await c.loadEarnings();
      expect(c.earnings!.earnings, 1.28);
      expect(c.earnings!.operatingBalance, 20);
      expect(c.earnings!.deliveries.length, 1);
      expect(courierMoney(null), '—');
      expect(courierDistance(850), '850 m');
    },
  );
  for (final dark in [false, true])
    testWidgets('small screen courier tabs and actions fit; dark=$dark', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final service = CourierFixture()..online = true;
      final c = CourierControllerFixture(service, CourierLocationFixture());
      await c.loadPetitions();
      await courierApp(tester, c, dark: dark);
      expect(find.text('Disponibles'), findsOneWidget);
      // The feed scrolls beneath the floating dock; reveal the whole offer.
      await tester.drag(find.byType(ListView).first, const Offset(0, -180));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('delivery-2048')));
      await tester.pumpAndSettle();
      expect(find.text('Aceptar entrega'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('courier-primary')));
      await tester.pumpAndSettle();
      expect(find.text('Confirmar retiro'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ingresos').last);
      await tester.pumpAndSettle();
      expect(find.text('Ganancia del día'), findsOneWidget);
      await tester.tap(find.text('Cuenta').last);
      await tester.pumpAndSettle();
      expect(find.text('Motorizado'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      c.dispose();
    });
}
