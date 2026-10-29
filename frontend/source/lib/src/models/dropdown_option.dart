import 'package:drop_down_list/model/selected_list_item.dart';

/// Keeps the API identifier separate from the label rendered by the SDK.
class DropdownOption extends SelectedListItem<String> {
  DropdownOption({required String name, required this.value})
    : super(data: name);
  final String value;
  String get name => data;
}
