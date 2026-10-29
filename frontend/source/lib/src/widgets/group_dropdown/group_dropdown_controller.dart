import 'package:delivery_app/src/models/dropdown_option.dart';
import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/models/group_model.dart';
import 'package:delivery_app/src/services/group_service.dart';

class GroupDropdownController extends ChangeNotifier {
  final GroupService groupService = GroupService();
  final List<GroupModel> _groups = [];
  GroupModel _group = GroupModel(id: 0);

  DropdownOption _dropdown = DropdownOption(
    name: S.current.lselectGroup,
    value: '0',
  );

  bool _inAsyncCall = false;
  bool _isGroupSelected = true;
  final List<DropdownOption> _groupItems = [];

  GroupDropdownController(GroupModel? groupProduct) {
    if (groupProduct != null) {
      group = groupProduct;
      _dropdown = DropdownOption(name: group.name, value: group.id.toString());
    }
    loadGroup();
  }

  bool get isGroupSelected => _isGroupSelected;

  set isGroupSelected(bool isGroupSelected) {
    _isGroupSelected = isGroupSelected;
    notifyListeners();
  }

  bool get inAsyncCall => _inAsyncCall;

  set inAsyncCall(bool asyncCall) {
    _inAsyncCall = asyncCall;
    notifyListeners();
  }

  List<GroupModel> get groups => _groups;

  GroupModel get group => _group;

  set group(GroupModel group) {
    _group = group;
    notifyListeners();
  }

  DropdownOption get dropdown => _dropdown;

  Future<bool> setDropdown(DropdownOption dropdown) async {
    _dropdown = dropdown;
    _group = _groups.firstWhere((adr) => adr.id.toString() == dropdown.value);
    notifyListeners();
    return true;
  }

  List<DropdownOption> get groupItems => _groupItems;

  setGroupItems(List<GroupModel> groups) {
    _groupItems.clear();
    for (var group in groups) {
      _groupItems.add(
        DropdownOption(name: group.name, value: group.id.toString()),
      );
    }
    notifyListeners();
  }

  loadGroup() async {
    inAsyncCall = true;
    final groups = await groupService.getGroups();
    _groups.clear();
    _groups.addAll(groups);
    setGroupItems(groups);
    inAsyncCall = false;
    notifyListeners();
  }
}
