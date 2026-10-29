import 'package:flutter/material.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/models/category_model.dart';
import 'package:delivery_app/src/screens/main/tab1_controller.dart';
import 'package:provider/provider.dart';

class ListCategory extends StatelessWidget {
  const ListCategory(this.categories, {super.key});
  final List<CategoryModel> categories;
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<Tab1Controller>();
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories
            .map(
              (category) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    category.id == 0
                        ? S.of(context).allCategories
                        : category.name,
                  ),
                  selected: controller.selectedCategory.id == category.id,
                  showCheckmark: false,
                  selectedColor: scheme.primaryContainer,
                  backgroundColor: scheme.surface,
                  labelStyle: TextStyle(
                    color: controller.selectedCategory.id == category.id
                        ? scheme.onPrimaryContainer
                        : scheme.onSurfaceVariant,
                  ),
                  side: BorderSide(color: scheme.outlineVariant),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  onSelected: (_) => controller.selectedCategory = category,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
