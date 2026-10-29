import 'package:flutter/material.dart';

import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/provider/preferences_provider.dart';
import 'package:planck/src/screens/login/signin_screen.dart';
import 'package:planck/src/screens/login/signup_screen.dart';
import 'package:planck/src/screens/recover/recover_screen.dart';
import 'package:planck/src/screens/admin/credit/credit_screen.dart';
import 'package:planck/src/screens/profile/profile_screen.dart';
import 'package:planck/src/screens/profile/widget/password_dialog.dart';
import 'package:planck/src/screens/manager/enrollment/widget/enrollment_form.dart';
import 'package:planck/src/screens/manager/product/product_screen.dart';
import 'package:planck/src/screens/manager/products/products_controller.dart';
import 'package:planck/src/screens/address/address_controller.dart';
import 'package:planck/src/screens/address/widget/address_dialog.dart';
import 'package:planck/src/models/address_model.dart';
import 'package:planck/src/widgets/forms/form_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/form_fixtures.dart';
import '../support/restaurant_fixtures.dart';

void main() {
  testWidgets(
    'closing recovery while its request is pending does not update disposed UI',
    (tester) async {
      final response = Completer<http.Response>();
      await http.runWithClient(() async {
        await tester.pumpWidget(formReviewApp(RecoverScreen()));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byType(TextFormField),
          'cliente@example.test',
        );
        await tester.tap(find.byType(FilledButton));
        await tester.pump();
        await tester.pumpWidget(const SizedBox.shrink());
        response.complete(http.Response('{}', 200));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }, () => MockClient((_) => response.future));
    },
  );
  for (final fail in [false, true])
    testWidgets(
      'product form saves through the shared fields and keeps failed drafts; fail=$fail',
      (tester) async {
        final service = RestaurantStoreFixture()..fail = fail;
        final products = ProductsController(
          restaurantStore(),
          service: service,
          loadOnCreate: false,
        );
        addTearDown(products.dispose);
        await tester.pumpWidget(
          formReviewApp(
            Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  child: const Text('Nuevo'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProductScreen(products)),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Nuevo'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey('product-name')),
          'Bowl de prueba',
        );
        await tester.enterText(
          find.byKey(const ValueKey('product-description')),
          'Pollo, arroz y vegetales frescos.',
        );
        await tester.enterText(
          find.byKey(const ValueKey('product-price')),
          '7,25',
        );
        await tester.tap(find.byKey(const ValueKey('save-menu-product')));
        await tester.pumpAndSettle();
        if (fail) {
          expect(find.byType(ProductScreen), findsOneWidget);
          expect(find.text('Bowl de prueba'), findsOneWidget);
          expect(products.products, isEmpty);
        } else {
          expect(find.byType(ProductScreen), findsNothing);
          expect(products.products.single.name, 'Bowl de prueba');
          expect(products.products.single.price, 7.25);
        }
        expect(tester.takeException(), isNull);
      },
    );
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'userId': 2,
      'fullName': 'Cliente local',
      'email': 'cliente@example.test',
      'phone': '0990000002',
      'roles': ['client'],
      'token': 'fixture',
      'image': '',
    });
    await PreferencesProvider().init();
    await S.load(const Locale('es'));
  });
  for (final dark in [false, true])
    for (final name in [
      'profile',
      'courier profile',
      'manager profile',
      'sign in',
      'sign up',
      'recovery',
      'credit',
      'enrollment',
      'new product',
      'edit product',
    ]) {
      testWidgets(
        '$name fits 320 px, large text and an open keyboard; dark=$dark',
        (tester) async {
          tester.view.physicalSize = const Size(320, 640);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetViewInsets);
          if (name == 'courier profile')
            await PreferencesProvider().preferences!.setStringList('roles', [
              'deliveryman',
            ]);
          if (name == 'manager profile')
            await PreferencesProvider().preferences!.setStringList('roles', [
              'manager',
            ]);
          final profile = formProfile();
          final products = ProductsController(
            restaurantStore(),
            service: RestaurantStoreFixture(),
            loadOnCreate: false,
          );
          Widget screen = switch (name) {
            'profile' ||
            'courier profile' ||
            'manager profile' => ProfileScreen(controller: profile),
            'sign in' => SigninScreen(),
            'sign up' => SignupScreen(),
            'recovery' => RecoverScreen(),
            'credit' => CreditScreen(),
            'enrollment' => EnrollmentForm(),
            'new product' => ProductScreen(products),
            _ => ProductScreen(
              products,
              product:
                  (products.service as RestaurantStoreFixture).products.first,
            ),
          };
          await tester.pumpWidget(
            formReviewApp(screen, dark: dark, scale: 1.3),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final footerButton = find.descendant(
            of: find.byKey(const ValueKey('form-footer')),
            matching: find.byType(FilledButton),
          );
          expect(tester.getSize(footerButton).width, closeTo(272, 0.1));
          expect(find.byType(AppTextField), findsWidgets);
          if (name.contains('profile'))
            expect(
              tester
                  .widget<FilledButton>(
                    find.widgetWithText(FilledButton, S.current.bSaveChanges),
                  )
                  .onPressed,
              isNull,
            );
          tester.view.viewInsets = const FakeViewPadding(bottom: 280);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(
            tester.getBottomLeft(find.byKey(const ValueKey('form-footer'))).dy,
            lessThanOrEqualTo(360),
          );
          if (find.byType(Form).evaluate().isNotEmpty)
            tester.state<FormState>(find.byType(Form).first).validate();
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
          profile.dispose();
          products.dispose();
        },
      );
    }
  for (final name in ['password', 'address'])
    testWidgets('$name dialog scrolls with keyboard and validation', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      final profile = formProfile();
      addTearDown(profile.dispose);
      await tester.pumpWidget(
        formReviewApp(
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => name == 'password'
                      ? PasswordDialog(profile, onPressedOk: () {})
                      : AddressDialog(
                          AddressController(
                            AddressModel(location: Location(x: -4, y: -79)),
                          ),
                        ),
                ),
                child: const Text('Abrir'),
              ),
            ),
          ),
          scale: 1.3,
        ),
      );
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      await tester.pumpAndSettle();
      expect(
        tester.state<FormState>(find.byType(Form).last).validate(),
        isFalse,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text(S.current.bCancel));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });
  testWidgets(
    'profile saves a changed email while retaining an untouched local phone',
    (tester) async {
      final auth = FormAuthFixture(), profile = formProfile(auth: auth);
      addTearDown(profile.dispose);
      await tester.pumpWidget(
        formReviewApp(ProfileScreen(controller: profile)),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'nuevo@example.test',
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FilledButton, S.current.bSaveChanges),
      );
      await tester.pumpAndSettle();
      expect(auth.updates, 1);
      expect(auth.savedPhone, '0990000002');
      expect(profile.hasChanges, isFalse);
      expect(PreferencesProvider().user.email, 'nuevo@example.test');
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('a rejected profile save keeps the draft and permits retry', (
    tester,
  ) async {
    final auth = FormAuthFixture()..fail = true,
        profile = formProfile(auth: auth);
    addTearDown(profile.dispose);
    await tester.pumpWidget(formReviewApp(ProfileScreen(controller: profile)));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'nuevo@example.test',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, S.current.bSaveChanges));
    await tester.pumpAndSettle();
    expect(auth.updates, 1);
    expect(profile.hasChanges, isTrue);
    expect(PreferencesProvider().user.email, 'cliente@example.test');
    expect(find.text('nuevo@example.test'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('credit rejects an invalid amount before parsing or sending it', (
    tester,
  ) async {
    await tester.pumpWidget(formReviewApp(CreditScreen()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).last, 'abc');
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
