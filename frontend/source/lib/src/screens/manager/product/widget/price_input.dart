import 'package:delivery_app/src/widgets/forms/form_fields.dart';
import 'package:delivery_app/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/common/validator.dart';
import 'package:delivery_app/src/screens/manager/product/product_controller.dart';

class PriceInput extends StatelessWidget {
  const PriceInput({super.key, required this.productController});

  final ProductController productController;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: S.of(context).lPrice,
      keyboardType: TextInputType.number,
      textCapitalization: TextCapitalization.sentences,

      initialValue: productController.companyProduct.price.toStringAsFixed(
        kCoinDecimals,
      ),
      onSaved: (price) {
        price = price!.trim();
        price = price.replaceFirst(',', '.');
        productController.companyProduct.price = double.parse(price);
      },
      validator: (value) => validatePrice(context, value!),
    );
  }
}
