import 'package:flutter/material.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/screens/profile/profile_controller.dart';
import 'package:delivery_app/src/widgets/forms/form_fields.dart';

class PhoneInput extends StatelessWidget {
  const PhoneInput(this.profileController, {super.key});
  final ProfileController profileController;
  @override
  Widget build(BuildContext context) => AppPhoneField(
    label: S.of(context).hPhone,
    initialValue: profileController.olpPhone,
    onSaved: (value) => profileController.phone = value,
    preserveUnchanged: true,
    onEdited: profileController.markChanged,
  );
}
