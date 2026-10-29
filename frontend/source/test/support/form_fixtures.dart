import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/models/balance_model.dart';
import 'package:delivery_app/src/models/category_model.dart';
import 'package:delivery_app/src/screens/profile/profile_controller.dart';
import 'package:delivery_app/src/screens/login/login_controller.dart';
import 'package:delivery_app/src/screens/manager/enrollment/enrollment_controller.dart';
import 'package:delivery_app/src/widgets/category_dropdown/category_dropdown_controller.dart';
import 'package:delivery_app/src/services/auth_service.dart';
import 'package:delivery_app/theme.dart';
import 'package:provider/provider.dart';

class FormAuthFixture extends AuthService {
  int updates = 0;
  bool fail = false;
  String? savedPhone;
  Completer<void>? gate;
  @override
  Future<Map<String, dynamic>?> update(
    String email,
    String fullName,
    String phone,
  ) async {
    updates++;
    savedPhone = phone;
    await gate?.future;
    return fail
        ? null
        : {
            'user': {
              'id': 2,
              'email': email,
              'fullName': fullName,
              'phone': phone,
              'image': '',
              'roles': ['client'],
              'addresses': [],
            },
          };
  }
}

class FormCategoriesFixture extends CategoryDropdownController {
  @override
  Future<void> loadCategory() async {
    categories.add(CategoryModel(id: 1, name: 'Comida casera', image: ''));
    setCategoryItems(categories);
  }
}

ProfileController formProfile({FormAuthFixture? auth}) =>
    ProfileController(auth: auth ?? FormAuthFixture(), loadOnCreate: false)
      ..balance = BalanceModel(userId: 2, money: 10, balance: 20, amount: 3);
Widget formReviewApp(Widget home, {bool dark = false, double scale = 1}) =>
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginController()),
        ChangeNotifierProvider(create: (_) => EnrollmentController()),
        ChangeNotifierProvider<CategoryDropdownController>(
          create: (_) => FormCategoriesFixture(),
        ),
      ],
      child: Builder(
        builder: (context) => MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: const Locale('es'),
          supportedLocales: S.delegate.supportedLocales,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: dark ? darkThemeData(context) : lightThemeData(context),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: home,
        ),
      ),
    );
