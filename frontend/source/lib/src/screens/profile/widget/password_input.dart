import 'package:planck/src/widgets/forms/form_fields.dart';
import 'package:flutter/material.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/screens/profile/profile_controller.dart';

class PasswordInput extends StatelessWidget {
  const PasswordInput(this.profileController, {super.key});
  final ProfileController profileController;

  @override
  Widget build(BuildContext context) {
    return AppPasswordField(
      label: S.of(context).hPassword,

      onSaved: (password) => profileController.password = password!,
      validator: (value) {
        if (value!.trim().length < 6) {
          return S.of(context).eValidatoCharacters(6);
        }
        return null;
      },
    );
  }
}
