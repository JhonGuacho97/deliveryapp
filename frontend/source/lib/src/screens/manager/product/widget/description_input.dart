import 'package:planck/src/widgets/forms/form_fields.dart';
import 'package:flutter/material.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/screens/manager/product/product_controller.dart';

class DescriptionInput extends StatelessWidget {
  const DescriptionInput({super.key, required this.productController});

  final ProductController productController;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: S.of(context).hProductDescription,
      maxLines: 4,
      minLines: 1,
      keyboardType: TextInputType.streetAddress,
      textCapitalization: TextCapitalization.sentences,

      initialValue: productController.companyProduct.description,
      onSaved: (description) =>
          productController.companyProduct.description = description!,
      validator: (value) {
        if (value!.trim().length < 10) {
          return S.of(context).eValidatoCharacters(10);
        }
        return null;
      },
    );
  }
}
