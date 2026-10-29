import 'package:flutter/material.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/models/category_model.dart';
import 'package:planck/src/widgets/category_dropdown/category_dropdown_controller.dart';
import 'package:planck/src/widgets/forms/form_options.dart';
import 'package:provider/provider.dart';

class CategoryDropdown extends StatelessWidget {
  const CategoryDropdown(this.category, {super.key});
  final CategoryModel category;
  @override
  Widget build(BuildContext context) {
    final c = context.watch<CategoryDropdownController>(), s = S.of(context);
    return FormField<int>(
      validator: (_) => c.category.id <= 0 ? s.selectOption : null,
      onSaved: (_) {
        category.id = c.category.id;
        category.image = c.category.image;
      },
      builder: (field) => FormOptionControl(
        label: s.tCategories,
        value: c.dropdown.name,
        error: field.errorText,
        busy: c.inAsyncCall,
        onTap: () => showFormOptions(
          context,
          title: s.tCategories,
          items: c.categoryItems,
          onSelected: (option) async {
            await c.setDropdown(option);
            field.didChange(c.category.id);
          },
        ),
      ),
    );
  }
}
