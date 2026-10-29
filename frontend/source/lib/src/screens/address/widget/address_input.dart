import 'package:delivery_app/src/widgets/forms/form_fields.dart';
import 'package:flutter/material.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/screens/address/address_controller.dart';

class AddressInput extends StatelessWidget {
  const AddressInput({super.key, required this.addressController});

  final AddressController addressController;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: S.of(context).hAddress,
      maxLines: 4,
      minLines: 1,
      keyboardType: TextInputType.streetAddress,
      textCapitalization: TextCapitalization.sentences,

      initialValue: addressController.address.address,
      onSaved: (address) => addressController.address.address = address!,
      validator: (value) {
        if (value!.trim().length < 3) {
          return S.of(context).eValidatoCharacters(3);
        }
        return null;
      },
    );
  }
}
