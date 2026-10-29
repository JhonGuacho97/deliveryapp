import 'package:delivery_app/src/widgets/forms/form_fields.dart';
import 'package:flutter/material.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/screens/login/access_controller.dart';

class PasswordInput extends StatelessWidget {
  const PasswordInput(this.accessController, {super.key});
  final AccessController accessController;

  @override
  Widget build(BuildContext context) {
    return AppPasswordField(
      label: S.of(context).hPassword,

      initialValue: accessController.password,
      onSaved: (password) => accessController.password = password!,
      validator: (value) {
        if (value!.trim().length < 6) {
          return S.of(context).eValidatoCharacters(6);
        }
        return null;
      },
    );
  }
}
