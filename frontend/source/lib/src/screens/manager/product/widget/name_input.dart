import 'package:delivery_app/src/widgets/forms/form_fields.dart';
import 'package:flutter/material.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/screens/manager/product/product_controller.dart';

class NameInput extends StatelessWidget {
  const NameInput({super.key, required this.productController});

  final ProductController productController;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: S.of(context).hProductName,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.sentences,

      initialValue: productController.companyProduct.name,
      onSaved: (name) => productController.companyProduct.name = name!,
      validator: (value) {
        if (value!.trim().length < 4) {
          return S.of(context).eValidatoCharacters(4);
        }
        return null;
      },
    );
  }
}
