import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:integration_test/integration_test.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/provider/preferences_provider.dart';
import 'package:planck/src/screens/login/signin_screen.dart';
import 'package:planck/src/screens/login/login_controller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Android persists and reloads preferences', (tester) async {
    final preferences = await SharedPreferences.getInstance();
    const key = 'migration_smoke_fixture';
    await preferences.setString(key, 'session-fixture');
    await preferences.reload();
    expect(preferences.getString(key), 'session-fixture');
    await preferences.remove(key);
  });

  testWidgets('Android reads a valid GPS position', (tester) async {
    expect(
      await Geolocator.checkPermission(),
      isNot(LocationPermission.denied),
    );
    final position = await Geolocator.getCurrentPosition(
      locationSettings: AndroidSettings(
        forceLocationManager: true,
        accuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 30),
      ),
    );
    // Existing AVD routes can replace a manually injected geo fix.
    expect(position.latitude, inInclusiveRange(-90, 90));
    expect(position.longitude, inInclusiveRange(-180, 180));
    expect(position.accuracy, greaterThanOrEqualTo(0));
  });

  testWidgets('Android posts and removes a local notification', (tester) async {
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    const id = 900131;
    try {
      await plugin.show(
        id: id,
        title: 'Prueba local',
        body: 'Migración Flutter',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'migration-fixture',
            'Pruebas locales',
          ),
        ),
      );
      expect(
        (await plugin.getActiveNotifications()).any((item) => item.id == id),
        isTrue,
      );
    } finally {
      await plugin.cancel(id: id);
    }
  });

  testWidgets('Android image picker recovers an empty pending selection', (
    tester,
  ) async {
    expect((await ImagePicker().retrieveLostData()).isEmpty, isTrue);
  });

  testWidgets('Android SQLite preserves quoted names and quantities', (
    tester,
  ) async {
    final path = '${await getDatabasesPath()}/migration_smoke_fixture.db';
    final database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE fixture (id INTEGER PRIMARY KEY, name TEXT, quantity INTEGER)',
        );
      },
    );
    try {
      await database.insert('fixture', {
        'id': 1,
        'name': "Comercio O'Reilly",
        'quantity': 2,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      final rows = await database.query('fixture');
      expect(rows.single['name'], "Comercio O'Reilly");
      expect(rows.single['quantity'], 2);
    } finally {
      await database.close();
      await deleteDatabase(path);
    }
    expect(File(path).existsSync(), isFalse);
  });

  testWidgets('sign-in form renders and validates offline on Android', (
    tester,
  ) async {
    await PreferencesProvider().init();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        supportedLocales: S.delegate.supportedLocales,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(fontFamily: 'Inter'),
        home: ChangeNotifierProvider(
          create: (_) => LoginController(),
          child: SigninScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(tester.state<FormState>(find.byType(Form)).validate(), isFalse);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 2));
  });
}
