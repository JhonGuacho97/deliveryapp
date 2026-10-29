import 'package:planck/src/widgets/forms/form_fields.dart';
import 'package:flutter/material.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/models/product_model.dart';
import 'package:planck/src/screens/cart/cart_controller.dart';

class NoteInput extends StatelessWidget {
  const NoteInput({
    super.key,
    required this.product,
    required this.cartController,
  });
  final ProductModel product;
  final CartController cartController;
  @override
  Widget build(BuildContext context) => AppTextField(
    required: false,
    key: ValueKey('note-${product.id}'),
    initialValue: product.note,
    minLines: 1,
    maxLines: 4,
    maxLength: 102,
    label: S.of(context).hNoteProdcut,
    onChanged: (value) {
      product.note = value;
      cartController.updateProduct(product);
    },
  );
}
