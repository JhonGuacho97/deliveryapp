import 'package:flutter/material.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/screens/profile/profile_controller.dart';
import 'package:delivery_app/src/screens/profile/widget/password_input.dart';
import 'package:delivery_app/src/widgets/forms/form_page.dart';

class PasswordDialog extends StatelessWidget {
  PasswordDialog(
    this.profileController, {
    super.key,
    required this.onPressedOk,
  });
  final ProfileController profileController;
  final Function onPressedOk;
  final _form = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) => AppFormDialog(
    title: S.of(context).bChangePassword,
    formKey: _form,
    child: PasswordInput(profileController),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(S.of(context).bCancel),
      ),
      FilledButton(
        onPressed: () {
          if (!_form.currentState!.validate()) return;
          _form.currentState!.save();
          FocusScope.of(context).unfocus();
          Navigator.pop(context);
          onPressedOk();
        },
        child: Text(S.of(context).bSaveChanges),
      ),
    ],
  );
}
