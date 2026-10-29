import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:planck/constants/constants.dart';
import 'package:planck/src/bloc/location_bloc.dart';
import 'package:planck/src/bloc/socket_bloc.dart';
import 'package:planck/src/models/user_model.dart';
import 'package:planck/src/provider/preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../support/fixtures.dart';

class _Socket extends Mock implements io.Socket {}

class _Gps extends GeolocatorPlatform {
  bool enabled = true;
  LocationPermission permission = LocationPermission.whileInUse;
  Position? lastPosition;
  bool fail = false;
  LocationSettings? requestedSettings;
  final positions = StreamController<Position>.broadcast();

  @override
  Future<bool> isLocationServiceEnabled() async => enabled;
  @override
  Future<LocationPermission> checkPermission() async => permission;
  @override
  Future<LocationPermission> requestPermission() async => permission;
  @override
  Future<Position?> getLastKnownPosition({
    bool forceLocationManager = false,
  }) async => lastPosition;
  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async {
    requestedSettings = locationSettings;
    if (fail) throw TimeoutException('fixture GPS unavailable');
    return point;
  }

  @override
  Stream<Position> getPositionStream({LocationSettings? locationSettings}) =>
      positions.stream;
}

final point = Position(
  latitude: -0.2,
  longitude: -78.5,
  timestamp: DateTime(2026),
  accuracy: 5,
  altitude: 0,
  altitudeAccuracy: 1,
  heading: 0,
  headingAccuracy: 1,
  speed: 0,
  speedAccuracy: 1,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late GeolocatorPlatform original;
  late _Gps gps;
  late SocketBloc sockets;
  late _Socket socket;
  late LocationBloc location;
  late DateTime now;
  setUp(() async {
    SharedPreferences.setMockInitialValues({'uuid': testDeviceId});
    await PreferencesProvider().init();
    PreferencesProvider().user = UserModel.fromJson(userFixture());
    PreferencesProvider().token = 'fixture-session';
    original = GeolocatorPlatform.instance;
    gps = _Gps();
    GeolocatorPlatform.instance = gps;
    socket = _Socket();
    when(() => socket.connected).thenReturn(true);
    when(() => socket.connect()).thenReturn(socket);
    when(() => socket.on('l', any())).thenAnswer((_) => () {});
    sockets = SocketBloc.connection(socketFactory: (_, options) => socket);
    now = DateTime(2026);
    location = LocationBloc.testing(socketBloc: sockets, now: () => now);
  });
  tearDown(() async {
    await location.stop();
    clearInteractions(socket);
    sockets.disposeStreams();
    await gps.positions.close();
    GeolocatorPlatform.instance = original;
  });

  test(
    'denied permission returns the configured map fallback without connecting',
    () async {
      gps.permission = LocationPermission.deniedForever;
      expect(await location.determinePosition(), [klatitudeMap, klongitudeMap]);
      expect(await location.start(), isFalse);
      expect(sockets.socket, isNull);
    },
  );
  test('disabled GPS uses the last position when available', () async {
    gps.enabled = false;
    gps.lastPosition = point;
    expect(await location.determinePosition(), [-0.2, -78.5]);
    expect(await location.start(), isFalse);
  });
  test(
    'current position uses location settings and a bounded timeout',
    () async {
      expect(await location.determinePosition(), [-0.2, -78.5]);
      expect(gps.requestedSettings!.timeLimit, const Duration(seconds: 45));
      gps.fail = true;
      expect(await location.determinePosition(), [klatitudeMap, klongitudeMap]);
    },
  );
  test(
    'tracking is idempotent, throttles updates and stops the subscription',
    () async {
      expect(await location.start(), isTrue);
      expect(await location.start(), isTrue);
      gps.positions.add(point);
      await Future<void>.delayed(Duration.zero);
      gps.positions.add(point);
      await Future<void>.delayed(Duration.zero);
      now = now.add(const Duration(seconds: 6));
      gps.positions.add(point);
      await Future<void>.delayed(Duration.zero);
      verify(
        () => socket.emit('l', {
          'id': 7,
          'p': [-0.2, -78.5],
        }),
      ).called(2);
      await location.stop();
      clearInteractions(socket);
      gps.positions.add(point);
      await Future<void>.delayed(Duration.zero);
      verifyNoMoreInteractions(socket);
    },
  );
}
