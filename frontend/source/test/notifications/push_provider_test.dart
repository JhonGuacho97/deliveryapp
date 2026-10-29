// The backend still uses legacy FCM tokens; cover that compatibility path.
// ignore_for_file: deprecated_member_use
import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:delivery_app/src/models/user_model.dart';
import 'package:delivery_app/src/provider/preferences_provider.dart';
import 'package:delivery_app/src/provider/push_provider.dart';
import 'package:delivery_app/src/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fixtures.dart';

class _Messaging extends Mock implements FirebaseMessaging {}

class _Notifications extends Mock implements FlutterLocalNotificationsPlugin {}

class _Settings extends Mock implements NotificationSettings {}

class _Auth extends Mock implements AuthService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    registerFallbackValue(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    registerFallbackValue(const NotificationDetails());
  });
  final preferences = PreferencesProvider();
  late _Messaging messaging;
  late _Notifications notifications;
  late _Settings settings;
  late _Auth auth;
  late PushProvider provider;
  late StreamController<RemoteMessage> messages;
  late StreamController<String> tokens;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'uuid': testDeviceId});
    await preferences.init();
    messaging = _Messaging();
    notifications = _Notifications();
    settings = _Settings();
    auth = _Auth();
    messages = StreamController<RemoteMessage>.broadcast();
    tokens = StreamController<String>.broadcast();
    when(() => settings.authorizationStatus)
        .thenReturn(AuthorizationStatus.authorized);
    when(
      () => messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      ),
    ).thenAnswer((_) async {});
    when(
      () => messaging.requestPermission(alert: true, sound: true, badge: true),
    ).thenAnswer((_) async => settings);
    when(() => messaging.setAutoInitEnabled(true)).thenAnswer((_) async {});
    when(() => messaging.getToken())
        .thenAnswer((_) async => 'initial-push-token');
    when(() => messaging.onTokenRefresh).thenAnswer((_) => tokens.stream);
    when(() => notifications.initialize(settings: any(named: 'settings')))
        .thenAnswer((_) async => true);
    when(
      () => notifications.show(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        notificationDetails: any(named: 'notificationDetails'),
      ),
    ).thenAnswer((_) async {});
    when(() => auth.updateTokenPush(any())).thenAnswer((_) async => true);
    provider = PushProvider.testing(
      messaging: messaging,
      notifications: notifications,
      preferences: preferences,
      authService: auth,
      messages: messages.stream,
    );
  });
  tearDown(() async {
    await provider.dispose();
    await messages.close();
    await tokens.close();
  });

  test('permission denial does not request a cloud token', () async {
    when(() => settings.authorizationStatus)
        .thenReturn(AuthorizationStatus.denied);
    await provider.getToken();
    verifyNever(() => messaging.getToken());
    expect(preferences.tokenPush, isNull);
  });

  test('initialization is idempotent', () async {
    await provider.init();
    await provider.init();
    await Future<void>.delayed(Duration.zero);
    verify(() => notifications.initialize(settings: any(named: 'settings')))
        .called(1);
    expect(preferences.tokenPush, 'initial-push-token');
  });

  test('authenticated sessions synchronize the received token', () async {
    preferences.user = UserModel.fromJson(userFixture());
    preferences.token = 'test-session-token';
    await provider.getToken();
    verify(() => auth.updateTokenPush('initial-push-token')).called(1);
  });

  test('token rotation updates the active session', () async {
    preferences.user = UserModel.fromJson(userFixture());
    preferences.token = 'test-session-token';
    await provider.init();
    await Future<void>.delayed(Duration.zero);
    tokens.add('rotated-token');
    await Future<void>.delayed(Duration.zero);
    expect(preferences.tokenPush, 'rotated-token');
    verify(() => auth.updateTokenPush('rotated-token')).called(1);
  });

  test('foreground messages preserve the payload and use the new named notification API', () async {
    await provider.init();
    final received = provider.notifications.first;
    messages.add(
      const RemoteMessage(
        data: {'type': '1010', 'title': 'Pedido', 'body': 'Nuevo pedido'},
      ),
    );
    expect((await received)['type'], '1010');
    await Future<void>.delayed(Duration.zero);
    verify(
      () => notifications.show(
        id: 1682,
        title: 'Pedido',
        body: 'Nuevo pedido',
        notificationDetails: any(named: 'notificationDetails'),
      ),
    ).called(1);
  });

  test('malformed status payloads are ignored without crashing', () async {
    await provider.checkMessage(
      const RemoteMessage(
        data: {'type': '5001', 'status': 'invalid', 'companyType': '10'},
      ),
    );
    verifyNever(
      () => notifications.show(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        notificationDetails: any(named: 'notificationDetails'),
      ),
    );
  });

  test('cloud failures do not prevent startup', () async {
    when(() => messaging.getToken())
        .thenThrow(StateError('isolated token failure'));
    await provider.getToken();
    expect(preferences.tokenPush, isNull);
  });
}
