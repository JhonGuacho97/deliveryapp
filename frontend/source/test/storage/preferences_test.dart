import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:planck/src/models/user_model.dart';
import 'package:planck/src/provider/db_provider.dart';
import 'package:planck/src/provider/preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fixtures.dart';

class _Database extends Mock implements DBProvider {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final preferences = PreferencesProvider();
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'uuid': testDeviceId,
      'locale': 'es',
    });
    await preferences.init();
  });

  test('preserves an existing device id across initialization', () async {
    expect(preferences.idDevice, testDeviceId);
    await preferences.init();
    expect(preferences.idDevice, testDeviceId);
  });

  test('new installations create a stable UUID', () async {
    await preferences.preferences!.remove('uuid');
    final id = preferences.idDevice;
    expect(id, matches(RegExp(r'^[a-f0-9-]{36}$')));
    expect(preferences.idDevice, id);
  });

  test('user id alone does not represent an authenticated session', () {
    preferences.user = UserModel.fromJson(userFixture());
    expect(preferences.isAuth, isFalse);
    preferences.token = 'test-session-token';
    expect(preferences.isAuth, isTrue);
    expect(preferences.user.roles, ['client']);
  });

  test('logout clears session and selected address while retaining locale and device id', () async {
    final database = _Database();
    when(() => database.deleteAddress()).thenAnswer((_) async => 1);
    preferences.user = UserModel.fromJson(userFixture());
    preferences.token = 'test-session-token';
    preferences.isOnline = true;
    await preferences.clean(database: database);
    expect(preferences.isGuest, isTrue);
    expect(preferences.isAuth, isFalse);
    expect(preferences.isOnline, isFalse);
    expect(preferences.idDevice, testDeviceId);
    expect(preferences.locale, 'es');
    verify(() => database.deleteAddress()).called(1);
  });

  test('nullable tokens clear values without throwing', () {
    preferences.token = null;
    preferences.tokenPush = null;
    expect(preferences.token, '');
    expect(preferences.tokenPush, isNull);
  });
}
