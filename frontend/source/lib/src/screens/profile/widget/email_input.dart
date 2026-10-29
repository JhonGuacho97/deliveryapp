import 'package:planck/src/widgets/forms/form_fields.dart';
import 'package:flutter/material.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/common/validator.dart';
import 'package:planck/src/screens/profile/profile_controller.dart';

class EmailInput extends StatelessWidget {
  const EmailInput(this.profileController, {super.key});
  final ProfileController profileController;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: S.of(context).hEmail,
      keyboardType: TextInputType.emailAddress,
      textCapitalization: TextCapitalization.none,

      initialValue: profileController.email,
      onSaved: (email) => profileController.email = email!,
      validator: (value) => validateEmail(context, value!),
    );
  }
}
