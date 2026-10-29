import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:planck/main.dart' as application;
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/provider/preferences_provider.dart';
import 'package:planck/src/services/auth_service.dart';
import 'package:planck/src/screens/profile/profile_screen.dart';
import 'package:planck/src/screens/main/tab_main_screen.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'actual client profile loads its saved phone and has no bottom overflow',
    (tester) async {
      const email = String.fromEnvironment('UI_LOCAL_EMAIL'),
          password = String.fromEnvironment('UI_LOCAL_PASSWORD');
      expect(email, isNotEmpty);
      final preferences = PreferencesProvider();
      await preferences.init();
      final user = await AuthService().login(email, password);
      expect(user, isNotNull);
      preferences.user = user!;
      preferences.token = user.token;
      await application.main();
      await tester.pumpAndSettle();
      final s = S.of(tester.element(find.byType(TabMainScreen)));
      await tester.tap(find.text(s.account).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text(s.editProfile));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, s.bSaveChanges),
            )
            .onPressed,
        isNull,
      );
      final beforePhone = preferences.user.phone,
          beforeEmail = preferences.user.email;
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
      await binding.takeScreenshot('ui-form-profile-local');
      await tester.showKeyboard(find.byType(TextFormField).at(1));
      await tester.pumpAndSettle();
      final view = View.of(tester.element(find.byType(TextFormField).at(1)));
      await tester.runAsync(() async {
        for (var i = 0; i < 20 && view.viewInsets.bottom == 0; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
      });
      await tester.pumpAndSettle();
      final inset = view.viewInsets.bottom / view.devicePixelRatio;
      expect(inset, greaterThan(0));
      expect(
        tester.getRect(find.byKey(const ValueKey('form-footer'))).bottom,
        lessThanOrEqualTo(
          view.physicalSize.height / view.devicePixelRatio - inset + 1,
        ),
      );
      expect(tester.takeException(), isNull);
      await binding.takeScreenshot('ui-form-profile-local-keyboard');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      expect(preferences.user.phone, beforePhone);
      expect(preferences.user.email, beforeEmail);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );
}
