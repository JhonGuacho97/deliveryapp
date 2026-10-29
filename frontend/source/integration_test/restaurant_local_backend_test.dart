import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:planck/constants/constants.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/main.dart' as application;
import 'package:planck/src/provider/preferences_provider.dart';
import 'package:planck/src/screens/manager/requests/requests_screen.dart';
import 'package:planck/src/services/auth_service.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'local restaurant logs in and loads its actual kitchen menu and business',
    (tester) async {
      expect(kExternalServicesEnabled, isFalse);
      const email = String.fromEnvironment('UI_LOCAL_EMAIL');
      const password = String.fromEnvironment('UI_LOCAL_PASSWORD');
      expect(
        email,
        isNotEmpty,
        reason: 'Pass the ignored local review configuration',
      );
      final preferences = PreferencesProvider();
      await preferences.init();
      final user = await AuthService().login(email, password);
      expect(user, isNotNull);
      expect(user!.roles, contains('manager'));
      preferences.user = user;
      preferences.token = user.token;
      await application.main();
      await tester.pumpAndSettle();
      expect(find.byType(RequestsScreen), findsOneWidget);
      expect(find.text('Sin cebolla en un bowl.'), findsOneWidget);
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
      await binding.takeScreenshot('ui-restaurant-local');
      final s = S.of(tester.element(find.byType(RequestsScreen)));
      await tester.tap(find.text(s.restaurantMenu).last);
      await tester.pumpAndSettle();
      expect(find.text('Bowl de pollo · Prueba local'), findsOneWidget);
      expect(find.text('6.50 USD'), findsOneWidget);
      await tester.tap(find.text(s.restaurantBusiness).last);
      await tester.pumpAndSettle();
      expect(find.text('Dirección de demostración local'), findsOneWidget);
      await tester.tap(find.text(s.manageHours));
      await tester.pumpAndSettle();
      expect(find.text('00:00'), findsWidgets);
      expect(find.text('23:59'), findsWidgets);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );
}
