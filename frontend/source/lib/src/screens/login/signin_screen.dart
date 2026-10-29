import 'package:flutter/material.dart';
import 'package:planck/constants/constants.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/screens/login/access_controller.dart';
import 'package:planck/src/screens/login/widget/email_input.dart';
import 'package:planck/src/screens/login/widget/google_button.dart';
import 'package:planck/src/screens/login/widget/password_input.dart';
import 'package:planck/src/screens/login/widget/signin_button.dart';
import 'package:planck/src/screens/login/widget/auth_header.dart';
import 'package:planck/src/screens/recover/recover_screen.dart';
import 'package:planck/src/widgets/forms/form_page.dart';
import 'package:provider/provider.dart';

class SigninScreen extends StatelessWidget {
  SigninScreen({super.key});
  final _form = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => AccessController(),
    child: Consumer<AccessController>(
      builder: (context, c, _) => FormPage(
        showAppBar: false,
        formKey: _form,
        busy: c.inAsyncCall,
        footer: SigninButton(c, formKey: _form),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthHeader(signin: true),
            EmailInput(c),
            const SizedBox(height: 22),
            PasswordInput(c),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RecoverScreen()),
                ),
                child: Text(S.of(context).bRecoverAccount),
              ),
            ),
            if (kExternalServicesEnabled) ...[
              const SizedBox(height: 16),
              GoogleButton(c),
            ],
          ],
        ),
      ),
    ),
  );
}
