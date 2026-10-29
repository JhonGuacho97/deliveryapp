import 'package:planck/src/widgets/forms/form_fields.dart';
import 'package:flutter/material.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/screens/address/address_controller.dart';

class AliasInput extends StatelessWidget {
  const AliasInput({super.key, required this.addressController});

  final AddressController addressController;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: S.of(context).hAlias,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.sentences,

      initialValue: addressController.address.alias,
      onSaved: (alias) => addressController.address.alias = alias!,
      validator: (value) {
        if (value!.trim().length < 2) {
          return S.of(context).eValidatoCharacters(2);
        }
        return null;
      },
    );
  }
}
