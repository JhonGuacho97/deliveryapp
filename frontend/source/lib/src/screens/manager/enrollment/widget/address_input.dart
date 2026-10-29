import 'package:planck/src/widgets/forms/form_fields.dart';
import 'package:flutter/material.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/screens/manager/enrollment/enrollment_controller.dart';

class AddressInput extends StatelessWidget {
  const AddressInput({super.key, required this.enrollmentController});

  final EnrollmentController enrollmentController;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: S.of(context).hAddress,
      maxLines: 4,
      minLines: 1,
      keyboardType: TextInputType.streetAddress,
      textCapitalization: TextCapitalization.sentences,

      initialValue: enrollmentController.enrollment.address,
      onSaved: (address) =>
          enrollmentController.enrollment.address = address!.trim(),
      validator: (value) {
        if (value!.trim().length < 10) {
          return S.of(context).eValidatoCharacters(10);
        }
        return null;
      },
    );
  }
}
