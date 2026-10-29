import 'package:delivery_app/src/widgets/forms/form_fields.dart';
import 'package:flutter/material.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/common/validator.dart';
import 'package:delivery_app/src/screens/manager/enrollment/enrollment_controller.dart';

class EmailInput extends StatelessWidget {
  const EmailInput({super.key, required this.enrollmentController});
  final EnrollmentController enrollmentController;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: S.of(context).hEmail,
      keyboardType: TextInputType.emailAddress,
      textCapitalization: TextCapitalization.none,

      initialValue: enrollmentController.enrollment.email,
      onSaved: (name) => enrollmentController.enrollment.email = name!.trim(),
      validator: (value) => validateEmail(context, value!),
    );
  }
}
