import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:planck/main.dart' as application;
import 'package:planck/constants/constants.dart';
import 'package:planck/src/provider/preferences_provider.dart';
import 'package:planck/src/services/auth_service.dart';
import 'package:planck/src/screens/deliveryman/petitions/petitions_screen.dart';
import 'package:planck/src/screens/deliveryman/petitions/petitions_controller.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'local courier logs in, uses actual GPS and sees the real ready offer',
    (tester) async {
      expect(kExternalServicesEnabled, isFalse);
      const email = String.fromEnvironment('UI_LOCAL_EMAIL'),
          password = String.fromEnvironment('UI_LOCAL_PASSWORD');
      expect(email, isNotEmpty);
      final preferences = PreferencesProvider();
      await preferences.init();
      final user = await AuthService().login(email, password);
      expect(user, isNotNull);
      expect(user!.roles, contains('deliveryman'));
      preferences.user = user;
      preferences.token = user.token;
      await application.main();
      await tester.pumpAndSettle();
      expect(find.byType(PetitionsScreen), findsOneWidget);
      final c = tester
          .element(find.byType(PetitionsScreen))
          .read<PetitionsController>();
      await tester.runAsync(() async {
        expect(await c.setAvailability(true), isTrue);
        await c.loadPetitions();
      });
      await tester.pumpAndSettle();
      expect(c.offers, isNotEmpty);
      expect(
        c.offers.any((p) => p.note == 'Demostración local de reparto'),
        isTrue,
      );
      expect(c.offers.every((p) => p.pickupDistanceMeters != null), isTrue);
      expect(c.error, isNull);
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
      await binding.takeScreenshot('ui-courier-local-offers');
      await tester.tap(find.text('Ingresos').last);
      await tester.pumpAndSettle();
      await tester.runAsync(c.loadEarnings);
      await tester.pumpAndSettle();
      expect(c.earnings!.operatingBalance, 20);
      expect(c.earnings!.earnings, 0);
      await binding.takeScreenshot('ui-courier-local-income');
      await tester.tap(find.text('Entregas').last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );
}
