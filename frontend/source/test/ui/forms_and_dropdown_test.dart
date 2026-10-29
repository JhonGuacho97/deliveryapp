import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planck/constants/types_constant.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/provider/preferences_provider.dart';
import 'package:planck/src/screens/login/signin_screen.dart';
import 'package:planck/src/screens/login/login_controller.dart';
import 'package:planck/src/screens/login/signup_screen.dart';
import 'package:planck/src/screens/recover/recover_screen.dart';
import 'package:planck/src/widgets/payment_dropdown/payment_dropdown.dart';
import 'package:planck/src/widgets/payment_dropdown/payment_dropdown_controller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget localized(Widget home) => MaterialApp(
  locale: const Locale('es'),
  supportedLocales: S.delegate.supportedLocales,
  localizationsDelegates: const [
    S.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  home: ChangeNotifierProvider(create: (_) => LoginController(), child: home),
);

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferencesProvider().init();
    await S.load(const Locale('es'));
  });
  for (final screen in <String, Widget Function()>{
    'sign in': () => SigninScreen(),
    'sign up': () => SignupScreen(),
    'recovery': () => RecoverScreen(),
  }.entries) {
    testWidgets('${screen.key} renders and rejects incomplete forms offline', (
      tester,
    ) async {
      await tester.pumpWidget(localized(screen.value()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(tester.state<FormState>(find.byType(Form)).validate(), isFalse);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'payment selector preserves API ids after the dropdown migration',
    (tester) async {
      final controller = PaymentDropdownController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        localized(
          ChangeNotifierProvider.value(
            value: controller,
            child: const Scaffold(body: PaymentDropdown()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(PaymentDropdown));
      await tester.pumpAndSettle();
      expect(find.text(S.current.lPayCash), findsOneWidget);
      await tester.tap(find.text(S.current.lPayCash));
      await tester.pumpAndSettle();
      expect(controller.payment.type, TypesPayment.cash);
      expect(controller.dropdown.value, TypesPayment.cash.toString());
      expect(tester.takeException(), isNull);
    },
  );
}
