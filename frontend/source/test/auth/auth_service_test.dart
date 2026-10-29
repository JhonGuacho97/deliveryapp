import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:delivery_app/src/provider/preferences_provider.dart';
import 'package:delivery_app/src/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final preferences = PreferencesProvider();
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'uuid': testDeviceId,
      'token': 'test-session-token',
    });
    await preferences.init();
  });

  test(
    'login posts the expected contract and parses the returned user',
    () async {
      await http.runWithClient(
        () async {
          final user = await AuthService().login(
            'client@example.test',
            'test-password',
          );
          expect(user!.id, 7);
          expect(user.token, 'test-session-token');
        },
        () => MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/api/auth/login');
          final body = jsonDecode(request.body);
          expect(body['email'], 'client@example.test');
          expect(body['idDevice'], testDeviceId);
          return http.Response(jsonEncode(userFixture()), 201);
        }),
      );
    },
  );

  test('login rejects unauthorized responses', () async {
    await http.runWithClient(() async {
      expect(
        await AuthService().login('client@example.test', 'incorrect'),
        isNull,
      );
    }, () => MockClient((_) async => http.Response('{}', 401)));
  });

  test('malformed responses do not create a session', () async {
    await http.runWithClient(() async {
      expect(
        await AuthService().login('client@example.test', 'test-password'),
        isNull,
      );
    }, () => MockClient((_) async => http.Response('not-json', 201)));
  });

  test(
    'push token updates accept the actual NestJS PATCH 200 response',
    () async {
      await http.runWithClient(
        () async {
          expect(await AuthService().updateTokenPush('push-fixture'), isTrue);
        },
        () => MockClient((request) async {
          expect(request.method, 'PATCH');
          expect(request.url.path, '/api/auth/update-token-push');
          expect(request.headers['Authorization'], 'Bearer test-session-token');
          expect(jsonDecode(request.body)['tokenPush'], 'push-fixture');
          return http.Response('{}', 200);
        }),
      );
    },
  );

  test('logout preserves the device-bound API route', () async {
    await http.runWithClient(
      () async {
        expect(await AuthService().logOut(), isTrue);
      },
      () => MockClient((request) async {
        expect(request.method, 'DELETE');
        expect(request.url.path, '/api/auth/log-out/$testDeviceId');
        return http.Response('{}', 200);
      }),
    );
  });
}
