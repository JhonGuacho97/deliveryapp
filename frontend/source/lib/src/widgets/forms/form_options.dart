import 'dart:async';

import 'package:flutter/material.dart';
import 'package:drop_down_list/drop_down_list.dart';
import 'package:delivery_app/src/models/dropdown_option.dart';
import 'package:delivery_app/src/widgets/forms/form_fields.dart';

class FormOptionControl extends StatelessWidget {
  const FormOptionControl({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.error,
    this.busy = false,
  });
  final String label, value;
  final VoidCallback? onTap;
  final String? error;
  final bool busy;
  @override
  Widget build(BuildContext context) => FormFieldLabel(
    label: label,
    required: true,
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: busy ? null : onTap,
      child: InputDecorator(
        decoration: InputDecoration(errorText: error),
        child: Row(
          children: [
            Expanded(
              child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
            ),
            const SizedBox(width: 12),
            busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.expand_more_rounded, size: 20),
          ],
        ),
      ),
    ),
  );
}

void showFormOptions(
  BuildContext context, {
  required String title,
  required List<DropdownOption> items,
  required FutureOr<void> Function(DropdownOption) onSelected,
}) {
  DropDownState(
    dropDown: DropDown<String>(
      bottomSheetTitle: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      ),
      data: items,
      enableMultipleSelection: false,
      onSelected: (List<dynamic> selected) async {
        for (final item in selected) {
          if (item is DropdownOption) await onSelected(item);
        }
      },
    ),
  ).showModal(context);
}
