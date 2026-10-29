import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:planck/constants/constants.dart';
import 'package:planck/constants/types_constant.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/common/status_label.dart';
import 'package:planck/src/provider/preferences_provider.dart';
import 'package:planck/src/services/auth_service.dart';

class PushProvider {
  static PushProvider? _instance;
  factory PushProvider() => _instance ??= PushProvider._(
    kExternalServicesEnabled ? FirebaseMessaging.instance : null,
    FlutterLocalNotificationsPlugin(),
    PreferencesProvider(),
    AuthService(),
    kExternalServicesEnabled
        ? FirebaseMessaging.onMessage
        : const Stream.empty(),
    kExternalServicesEnabled,
  );

  PushProvider.testing({
    required FirebaseMessaging messaging,
    required FlutterLocalNotificationsPlugin notifications,
    required PreferencesProvider preferences,
    required AuthService authService,
    Stream<RemoteMessage> messages = const Stream.empty(),
  }) : this._(
         messaging,
         notifications,
         preferences,
         authService,
         messages,
         false,
       );

  PushProvider._(
    this._firebaseMessaging,
    this._localNotifications,
    this.prefs,
    this._authService,
    this._messages,
    this._registerBackground,
  );
  final FirebaseMessaging? _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final PreferencesProvider prefs;
  final AuthService _authService;
  final Stream<RemoteMessage> _messages;
  final bool _registerBackground;
  final _notificationsStream =
      StreamController<Map<String, dynamic>>.broadcast();
  StreamSubscription<RemoteMessage>? _messageSubscription;
  StreamSubscription<String>? _tokenSubscription;
  Future<bool?>? _localInitialization;
  bool _initialized = false;

  final androidPlatformChannelSpecifics = const AndroidNotificationDetails(
    '${kNameApp}_CHANNEL_PLANCK',
    '$kNameApp NOTIFICATIONS PLANCK',
    groupKey: '$kNameApp-NOTIFICATIONS-PLANCK',
    playSound: true,
    autoCancel: true,
    importance: Importance.max,
    priority: Priority.high,
  );

  Stream<Map<String, dynamic>> get notifications => _notificationsStream.stream;

  Future<void> initializeLocalNotifications() async {
    _localInitialization ??= _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    await _localInitialization;
  }

  Future<void> getToken() async {
    final messaging = _firebaseMessaging;
    if (messaging == null) return;
    try {
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      final settings = await messaging.requestPermission(
        alert: true,
        sound: true,
        badge: true,
      );
      if (settings.authorizationStatus != AuthorizationStatus.authorized &&
          settings.authorizationStatus != AuthorizationStatus.provisional)
        return;
      await messaging.setAutoInitEnabled(true);
      // Keep legacy registration tokens until the backend supports FID targets.
      // Do not mix register()/onRegistered with this compatibility path.
      // ignore: deprecated_member_use
      final token = await messaging.getToken().timeout(
        const Duration(seconds: 15),
      );
      if (token != null) await _saveToken(token);
    } catch (error) {
      if (kDebugMode) debugPrint('Push token unavailable: $error');
    }
  }

  Future<void> _saveToken(String token) async {
    prefs.tokenPush = token;
    if (prefs.isAuth) await _authService.updateTokenPush(token);
  }

  Future<void> showNotification(RemoteNotification push) async {
    await initializeLocalNotifications();
    await _localNotifications.show(
      id: 1682,
      title: push.title,
      body: push.body,
      notificationDetails: NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> cancelAll() => _localNotifications.cancelAll();

  Future<void> init() async {
    if (_initialized) return;
    await initializeLocalNotifications();
    if (_registerBackground)
      FirebaseMessaging.onBackgroundMessage(_messageHandler);
    _messageSubscription = _messages.listen((message) {
      if (!message.data.containsKey('type')) return;
      _notificationsStream.add(message.data);
      unawaited(checkMessage(message));
    });
    // Match the backend's existing token-based Firebase Admin payloads.
    // ignore: deprecated_member_use
    _tokenSubscription = _firebaseMessaging?.onTokenRefresh.listen((token) {
      unawaited(
        _saveToken(token).catchError((Object error) {
          if (kDebugMode) debugPrint('Push token refresh failed: $error');
        }),
      );
    });
    _initialized = true;
    unawaited(getToken());
  }

  Future<void> checkMessage(RemoteMessage message) async {
    if (!message.data.containsKey('type')) return;
    String? title, body;
    if (message.data['title'] is String && message.data['body'] is String) {
      title = message.data['title'] as String;
      body = message.data['body'] as String;
    } else if (message.data['type'] == TypesNotification.changeOrderStatust) {
      final status = int.tryParse('${message.data['status']}');
      final companyType = int.tryParse('${message.data['companyType']}');
      if (status == null || companyType == null) return;
      title = kNameApp;
      body = statusOrderLabel(status, companyType);
    }
    if (title == null || body == null) return;
    try {
      await showNotification(RemoteNotification(title: title, body: body));
    } catch (error) {
      if (kDebugMode) debugPrint('Local notification unavailable: $error');
    }
  }

  Future<void> dispose() async {
    await _messageSubscription?.cancel();
    await _tokenSubscription?.cancel();
    await _notificationsStream.close();
    if (identical(_instance, this)) _instance = null;
  }
}

@pragma('vm:entry-point')
Future<void> _messageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await PreferencesProvider().init();
  await S.load(
    Locale(PreferencesProvider().locale.split(RegExp('[_-]')).first),
  );
  await PushProvider().checkMessage(message);
}
