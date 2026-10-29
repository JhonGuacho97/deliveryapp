import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:planck/src/provider/db_provider.dart';
import 'package:planck/src/provider/preferences_provider.dart';
import 'package:planck/src/screens/login/widget/google_button_controller.dart';
import 'package:planck/src/services/auth_service.dart';
import 'package:planck/src/services/google_identity_gateway.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fixtures.dart';

class _Google extends Mock implements GoogleIdentityGateway {}

class _Auth extends Mock implements AuthService {}

class _Database extends Mock implements DBProvider {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Google google;
  late _Auth auth;
  late GoogleButtonController controller;
  final preferences = PreferencesProvider();
  const identity = GoogleIdentity(
    id: '123456789012345678901',
    email: 'client@example.test',
    fullName: 'Cliente de prueba',
    image: '',
  );
  setUp(() async {
    SharedPreferences.setMockInitialValues({'uuid': testDeviceId});
    await preferences.init();
    google = _Google();
    auth = _Auth();
    controller = GoogleButtonController(
      gateway: google,
      authService: auth,
      preferences: preferences,
      database: _Database(),
    );
  });
  tearDown(() => controller.dispose());

  test(
    'Google cancellation never calls the backend or creates a session',
    () async {
      when(() => google.signIn()).thenAnswer((_) async => null);
      expect(await controller.sigInGoogle(), isNull);
      expect(preferences.isAuth, isFalse);
      verifyNever(() => auth.google(any(), any(), any(), any()));
    },
  );

  test('successful Google identity preserves user roles and session', () async {
    when(() => google.signIn()).thenAnswer((_) async => identity);
    when(() => auth.google(any(), any(), any(), any())).thenAnswer(
      (_) async => {
        'user': userFixture(roles: ['deliveryman']),
      },
    );
    expect((await controller.sigInGoogle())!.roles, ['deliveryman']);
    expect(preferences.token, 'test-session-token');
    expect(preferences.isAuth, isTrue);
  });

  test(
    'backend errors return null rather than a value with the wrong type',
    () async {
      when(() => google.signIn()).thenAnswer((_) async => identity);
      when(() => auth.google(any(), any(), any(), any()))
          .thenAnswer((_) async => {'codeError': 401});
      expect(await controller.sigInGoogle(), isNull);
      expect(preferences.isAuth, isFalse);
    },
  );

  test('native sign-in failure does not reuse a stale identity', () async {
    when(() => google.signIn())
        .thenThrow(StateError('isolated Google failure'));
    expect(await controller.sigInGoogle(), isNull);
    verifyNever(() => auth.google(any(), any(), any(), any()));
  });
}
