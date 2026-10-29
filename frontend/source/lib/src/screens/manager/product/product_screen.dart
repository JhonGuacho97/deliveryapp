import 'package:planck/src/widgets/forms/form_page.dart';
import 'package:planck/src/widgets/forms/form_fields.dart';
import 'package:flutter/material.dart';
import 'package:planck/constants/constants.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/common/file_helper.dart';
import 'package:planck/src/models/company_product_model.dart';
import 'package:planck/src/screens/manager/products/products_controller.dart';
import 'package:planck/src/widgets/avatar_image.dart';
import 'package:planck/src/widgets/upload_file/upload_file.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen(this.productsController, {super.key, this.product});
  final ProductsController productsController;
  final CompanyProductModel? product;
  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final _form = GlobalKey<FormState>();
  late final draft = CompanyProductModel.fromJson(
    (widget.product ?? CompanyProductModel(id: 0)).toJson(),
  );
  late final _name = TextEditingController(text: draft.name);
  late final _description = TextEditingController(text: draft.description);
  late final _price = TextEditingController(
    text: draft.price > 0 ? draft.price.toStringAsFixed(2) : '',
  );
  bool _busy = false;
  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    draft.name = _name.text.trim();
    draft.description = _description.text.trim();
    draft.price = double.parse(_price.text.replaceAll(',', '.'));
    setState(() => _busy = true);
    final saved = await widget.productsController.save(draft);
    if (!mounted) return;
    setState(() => _busy = false);
    final s = S.of(context);
    if (saved) {
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(SnackBar(content: Text(s.mRChangesMadeCorrectly)));
    } else
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(s.kitchenActionError)));
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context), theme = Theme.of(context);
    return FormPage(
      title: draft.id == 0 ? s.bNewProduct : s.editProduct,
      formKey: _form,
      busy: _busy,
      footer: Padding(
        padding: const EdgeInsets.all(10),
        child: FilledButton(
          key: const ValueKey('save-menu-product'),
          onPressed: _busy ? null : _save,
          child: Text(s.saveProduct),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.productsController.storeCompany.name,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: 96,
                height: 96,
                child: draft.image.isNotEmpty
                    ? AvatarImage(image: draft.image, width: 96)
                    : ColoredBox(
                        color: theme.colorScheme.surfaceContainerLow,
                        child: const Icon(Icons.restaurant_outlined, size: 32),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(s.photoOptional, style: theme.textTheme.bodySmall),
          ),
          if (kExternalServicesEnabled)
            Center(
              child: OutlinedButton(
                onPressed: _busy
                    ? null
                    : () => showDialog(
                        context: context,
                        builder: (_) => UploadFile((image) async {
                          setState(() => _busy = true);
                          final url = await uploadFile(
                            image,
                            'product/${widget.productsController.storeCompany.company.id}',
                            '${DateTime.now().millisecondsSinceEpoch}',
                            kTargetWidthProduct,
                          );
                          if (!mounted) return;
                          setState(() {
                            if (url.isNotEmpty) draft.image = url;
                            _busy = false;
                          });
                        }),
                      ),
                child: Text(s.editImage),
              ),
            ),
          const SizedBox(height: 28),
          AppTextField(
            key: const ValueKey('product-name'),
            label: s.productNameLabel,
            controller: _name,
            enabled: !_busy,
            textCapitalization: TextCapitalization.sentences,
            validator: (value) =>
                (value ?? '').trim().length < 4 ? s.productNameError : null,
          ),
          const SizedBox(height: 22),
          AppTextField(
            key: const ValueKey('product-description'),
            label: s.productDescriptionLabel,
            controller: _description,
            enabled: !_busy,
            minLines: 3,
            maxLines: 6,
            textInputAction: TextInputAction.newline,
            validator: (value) => (value ?? '').trim().length < 10
                ? s.productDescriptionError
                : null,
          ),
          const SizedBox(height: 22),
          AppTextField(
            key: const ValueKey('product-price'),
            label: s.productPriceLabel,
            controller: _price,
            enabled: !_busy,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            validator: (value) {
              final amount = double.tryParse(
                (value ?? '').replaceAll(',', '.'),
              );
              return amount == null || !amount.isFinite || amount <= 0
                  ? s.productPriceError
                  : null;
            },
          ),
        ],
      ),
    );
  }
}
