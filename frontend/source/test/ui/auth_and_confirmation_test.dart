import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/screens/login/login_screen.dart';
import 'package:delivery_app/src/provider/preferences_provider.dart';
import 'package:delivery_app/src/widgets/confirmation_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/form_fixtures.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesProvider().init();
  });

  testWidgets(
    'auth tabs keep drafts and follow the visible form after resizing',
    (tester) async {
      await tester.pumpWidget(formReviewApp(const LoginScreen()));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).first,
        'cliente@example.test',
      );
      await tester.tap(find.text(S.current.bSignup).first);
      await tester.pumpAndSettle();
      expect(find.text(S.current.authCreateTitle), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(4));
      await tester.enterText(find.byType(TextFormField).first, 'María Local');
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpAndSettle();
      await tester.tap(find.text(S.current.bSignin).first);
      await tester.pumpAndSettle();
      expect(find.text(S.current.authWelcome), findsOneWidget);
      expect(find.text('cliente@example.test'), findsOneWidget);
      await tester.tap(find.text(S.current.bSignup).first);
      await tester.pumpAndSettle();
      expect(find.text('María Local'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final dark in [false, true]) {
    testWidgets(
      'confirmation has readable text and only confirms on acceptance ($dark)',
      (tester) async {
        var confirmed = 0;
        await tester.pumpWidget(
          formReviewApp(
            Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => ConfirmationDialog(
                      '¿Cerrar sesión?',
                      labelOk: S.current.signOut,
                      onPressedOk: () => confirmed++,
                    ),
                  ),
                  child: const Text('Abrir'),
                ),
              ),
            ),
            dark: dark,
          ),
        );
        await tester.pumpAndSettle();
        Future<void> open() async {
          await tester.tap(find.text('Abrir'));
          await tester.pumpAndSettle();
        }

        await open();
        final button = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, S.current.signOut),
        );
        final background = button.style!.backgroundColor!.resolve({})!;
        final foreground = button.style!.foregroundColor!.resolve({})!;
        final ratio =
            (foreground.computeLuminance() + .05) /
            (background.computeLuminance() + .05);
        expect(ratio > 1 ? ratio : 1 / ratio, greaterThanOrEqualTo(4.5));
        await tester.tap(find.text(S.current.bCancel));
        await tester.pumpAndSettle();
        expect(confirmed, 0);
        await open();
        await tester.tap(find.text(S.current.signOut));
        await tester.pumpAndSettle();
        expect(confirmed, 1);
        expect(find.byType(AlertDialog), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
