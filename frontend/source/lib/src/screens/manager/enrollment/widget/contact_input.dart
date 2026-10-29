import 'package:flutter/material.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/screens/manager/enrollment/enrollment_controller.dart';
import 'package:delivery_app/src/widgets/forms/form_fields.dart';

class ContactInput extends StatelessWidget {
  const ContactInput({super.key, required this.enrollmentController});
  final EnrollmentController enrollmentController;
  @override
  Widget build(BuildContext context) => AppPhoneField(
    label: S.of(context).hPhone,
    initialValue: enrollmentController.enrollment.contact,
    onSaved: (value) => enrollmentController.enrollment.contact = value,
  );
}
