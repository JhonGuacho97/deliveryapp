import 'package:flutter/material.dart';
import 'package:planck/constants/code_error_constant.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/screens/login/access_controller.dart';
import 'package:planck/src/screens/login/login_controller.dart';
import 'package:planck/src/screens/main/tab_main_screen.dart';
import 'package:planck/src/widgets/primary_button.dart';
import 'package:provider/provider.dart';

class SignupButton extends StatelessWidget {
  const SignupButton(
    this.accessController, {
    super.key,
    required GlobalKey<FormState> formKey,
  }) : _formKey = formKey;
  final AccessController accessController;
  final GlobalKey<FormState> _formKey;

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      text: S.of(context).bSignup,
      onPressed: () async {
        FocusScope.of(context).unfocus();
        if (!_formKey.currentState!.validate()) return;
        _formKey.currentState!.save();

        final navigator = Navigator.of(context);
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        final sContext = S.of(context);

        final codeError = await accessController.signup();
        if (!context.mounted) return;

        String? error;

        switch (codeError) {
          case CodeError.none:
            navigator.pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const TabMainScreen()),
              (Route<dynamic> route) {
                return false;
              },
            );
            break;
          case CodeError.unknown:
            error = sContext.errUnknown;
            break;
          case CodeError.emailUnique:
            error = sContext.errEmailUnique(accessController.email);
            break;
          case CodeError.phoneUnique:
            error = sContext.errPhoneUnique(accessController.phone);
            break;
          default:
        }

        if (error != null) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              duration: const Duration(milliseconds: 4500),
              content: Text(error),
              action: SnackBarAction(
                label: sContext.bSignin,
                textColor: Colors.white,
                onPressed: () {
                  Provider.of<LoginController>(
                    context,
                    listen: false,
                  ).currentScreen = 0;
                },
              ),
            ),
          );
        }
      },
    );
  }
}
