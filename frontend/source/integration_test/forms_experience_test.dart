import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/provider/preferences_provider.dart';
import 'package:planck/src/screens/profile/profile_screen.dart';
import 'package:planck/src/screens/profile/widget/password_dialog.dart';
import 'package:planck/src/screens/login/signin_screen.dart';
import 'package:planck/src/screens/login/signup_screen.dart';
import 'package:planck/src/screens/recover/recover_screen.dart';
import 'package:planck/src/screens/admin/credit/credit_screen.dart';
import 'package:planck/src/screens/manager/enrollment/widget/enrollment_form.dart';
import 'package:planck/src/screens/manager/product/product_screen.dart';
import 'package:planck/src/screens/manager/products/products_controller.dart';
import 'package:planck/src/screens/address/address_controller.dart';
import 'package:planck/src/screens/address/widget/address_dialog.dart';
import 'package:planck/src/models/address_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/support/form_fixtures.dart';
import '../test/support/restaurant_fixtures.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'clean forms render, validate and keep save visible above the Android keyboard',
    (tester) async {
      final preferences = PreferencesProvider();
      await preferences.init();
      final native = preferences.preferences;
      SharedPreferences.setMockInitialValues({
        'userId': 2,
        'fullName': 'Cliente local',
        'email': 'cliente@example.test',
        'phone': '0990000002',
        'roles': ['client'],
        'token': 'form-fixture',
        'image': '',
      });
      await preferences.init();
      final profile = formProfile(), service = RestaurantStoreFixture();
      final products = ProductsController(
        restaurantStore(),
        service: service,
        loadOnCreate: false,
      );
      var surfaceReady = false;
      Future<void> show(Widget screen, {bool dark = false}) async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await tester.pumpWidget(formReviewApp(screen, dark: dark));
        await tester.pumpAndSettle();
        if (!surfaceReady) {
          await binding.convertFlutterSurfaceToImage();
          await tester.pumpAndSettle();
          surfaceReady = true;
        }
      }

      Future<void> capture(String name) async {
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await binding.takeScreenshot(name);
      }

      try {
        await show(ProfileScreen(controller: profile));
        await capture('ui-form-profile');
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'nuevo@example.test',
        );
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
        await capture('ui-form-profile-keyboard');
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await tester.tap(
          find.widgetWithText(FilledButton, S.current.bSaveChanges),
        );
        await tester.pumpAndSettle();
        expect(preferences.user.email, 'nuevo@example.test');
        await capture('ui-form-profile-saved');
        await show(ProfileScreen(controller: profile), dark: true);
        await capture('ui-form-profile-dark');
        await show(SigninScreen());
        await capture('ui-form-signin');
        await show(SignupScreen());
        await capture('ui-form-signup');
        await show(RecoverScreen());
        await capture('ui-form-recovery');
        await show(CreditScreen());
        await capture('ui-form-credit');
        await show(EnrollmentForm());
        await capture('ui-form-enrollment');
        await show(ProductScreen(products));
        await capture('ui-form-product-create');
        await tester.tap(find.byKey(const ValueKey('save-menu-product')));
        await tester.pumpAndSettle();
        expect(find.text(S.current.productNameError), findsOneWidget);
        await capture('ui-form-product-errors');
        await show(ProductScreen(products, product: service.products.first));
        await capture('ui-form-product-edit');
        await show(
          Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  child: const Text('Dirección'),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => AddressDialog(
                      AddressController(
                        AddressModel(
                          alias: 'Casa',
                          address: 'Calle Principal 123',
                          location: Location(x: -4, y: -79),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Dirección'));
        await tester.pumpAndSettle();
        await capture('ui-form-address-dialog');
        await show(
          Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  child: const Text('Contraseña'),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => PasswordDialog(profile, onPressedOk: () {}),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Contraseña'));
        await tester.pumpAndSettle();
        await capture('ui-form-password-dialog');
      } finally {
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        profile.dispose();
        products.dispose();
        preferences.preferences = native;
      }
    },
  );
}
