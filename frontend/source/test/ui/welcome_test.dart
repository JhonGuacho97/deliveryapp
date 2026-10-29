import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/provider/preferences_provider.dart';
import 'package:planck/src/screens/login/login_screen.dart';
import 'package:planck/src/screens/welcome/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/form_fixtures.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesProvider().init();
  });
  for (final width in [320.0, 411.0]) {
    for (final dark in [false, true]) {
      testWidgets(
        'welcome explains delivery and scrolls with large text at $width px, dark=$dark',
        (tester) async {
          tester.view.physicalSize = Size(width, 640);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(
            formReviewApp(const WelcomeScreen(), dark: dark, scale: 1.3),
          );
          await tester.pumpAndSettle();
          expect(find.text(S.current.welcomeTitle), findsOneWidget);
          expect(find.text(S.current.welcomeTracking), findsOneWidget);
          expect(find.textContaining('Powered by'), findsNothing);
          await tester.ensureVisible(
            find.byKey(const ValueKey('welcome-access')),
          );
          await tester.pumpAndSettle();
          expect(
            tester
                .widget<OutlinedButton>(
                  find.byKey(const ValueKey('welcome-access')),
                )
                .onPressed,
            isNotNull,
          );
          expect(
            tester
                .widget<FilledButton>(
                  find.byKey(const ValueKey('welcome-explore')),
                )
                .onPressed,
            isNotNull,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
  testWidgets('welcome opens sign in and registration', (tester) async {
    await tester.pumpWidget(formReviewApp(const WelcomeScreen()));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('welcome-access')));
    await tester.tap(find.byKey(const ValueKey('welcome-access')));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    await tester.tap(find.text(S.current.bSignup).first);
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNWidgets(4));
    expect(tester.takeException(), isNull);
  });
}
