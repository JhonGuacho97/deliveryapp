import 'package:planck/src/widgets/forms/form_fields.dart';
import 'package:flutter/material.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/screens/manager/enrollment/enrollment_controller.dart';

class NameInput extends StatelessWidget {
  const NameInput({super.key, required this.enrollmentController});

  final EnrollmentController enrollmentController;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: S.of(context).hFullName,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.sentences,

      initialValue: enrollmentController.enrollment.name,
      onSaved: (name) => enrollmentController.enrollment.name = name!.trim(),
      validator: (value) {
        if (value!.trim().length < 5) {
          return S.of(context).eValidatoCharacters(5);
        }
        return null;
      },
    );
  }
}
