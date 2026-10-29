import 'package:flutter/material.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/screens/manager/product/product_controller.dart';
import 'package:delivery_app/src/widgets/group_dropdown/group_dropdown_controller.dart';
import 'package:delivery_app/src/widgets/forms/form_options.dart';
import 'package:provider/provider.dart';

class GroupDropdown extends StatelessWidget {
  const GroupDropdown(this.productController, {super.key});
  final ProductController productController;
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) =>
        GroupDropdownController(productController.companyProduct.group),
    child: Consumer<GroupDropdownController>(
      builder: (context, c, _) => FormField<int>(
        validator: (_) => c.group.id <= 0 ? S.of(context).selectOption : null,
        onSaved: (_) => productController.companyProduct.group = c.group,
        builder: (field) => FormOptionControl(
          label: S.of(context).lselectGroup,
          value: c.dropdown.name,
          error: field.errorText,
          busy: c.inAsyncCall,
          onTap: () => showFormOptions(
            context,
            title: S.of(context).lselectGroup,
            items: c.groupItems,
            onSelected: (option) async {
              await c.setDropdown(option);
              field.didChange(c.group.id);
            },
          ),
        ),
      ),
    ),
  );
}
