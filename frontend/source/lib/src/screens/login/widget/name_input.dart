import 'package:delivery_app/src/widgets/forms/form_fields.dart';
import 'package:flutter/material.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/screens/login/access_controller.dart';

class NameInput extends StatelessWidget {
  const NameInput(this.accessController, {super.key});
  final AccessController accessController;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: S.of(context).hFullName,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,

      initialValue: accessController.fullName,
      onSaved: (hFullName) => accessController.fullName = hFullName!,
      validator: (value) {
        if (value!.trim().length < 6) {
          return S.of(context).eValidatoCharacters(6);
        }
        return null;
      },
    );
  }
}
