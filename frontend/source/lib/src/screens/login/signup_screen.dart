import 'package:flutter/material.dart';
import 'package:planck/constants/constants.dart';
import 'package:planck/src/screens/login/access_controller.dart';
import 'package:planck/src/screens/login/widget/email_input.dart';
import 'package:planck/src/screens/login/widget/google_button.dart';
import 'package:planck/src/screens/login/widget/name_input.dart';
import 'package:planck/src/screens/login/widget/password_input.dart';
import 'package:planck/src/screens/login/widget/phone_input.dart';
import 'package:planck/src/screens/login/widget/signup_button.dart';
import 'package:planck/src/screens/login/widget/auth_header.dart';
import 'package:planck/src/widgets/forms/form_page.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});
  final _form = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => AccessController(),
    child: Consumer<AccessController>(
      builder: (context, c, _) => FormPage(
        showAppBar: false,
        formKey: _form,
        busy: c.inAsyncCall,
        footer: SignupButton(c, formKey: _form),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthHeader(signin: false),
            NameInput(c),
            const SizedBox(height: 18),
            PhoneInput(c),
            const SizedBox(height: 18),
            EmailInput(c),
            const SizedBox(height: 18),
            PasswordInput(c),
            if (kExternalServicesEnabled) ...[
              const SizedBox(height: 20),
              GoogleButton(c),
            ],
          ],
        ),
      ),
    ),
  );
}
