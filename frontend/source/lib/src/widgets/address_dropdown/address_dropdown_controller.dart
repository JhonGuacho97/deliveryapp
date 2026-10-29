import 'package:planck/src/models/dropdown_option.dart';
import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:planck/constants/constants.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/models/address_model.dart';
import 'package:planck/src/provider/db_provider.dart';
import 'package:planck/src/services/address_service.dart';

class AddressDropdownController extends ChangeNotifier {
  final AddressService addressService = AddressService();
  final List<AddressModel> _addresses = [];

  DropdownOption _dropdown = DropdownOption(
    name: S.current.lNewAddress,
    value: '0',
  );
  bool _inAsyncCall = false;
  final List<DropdownOption> _addressItems = [];

  AddressDropdownController() {
    initAddress();
    loadAddress();
  }

  bool get inAsyncCall => _inAsyncCall;

  set inAsyncCall(bool asyncCall) {
    _inAsyncCall = asyncCall;
    notifyListeners();
  }

  DropdownOption get dropdown => _dropdown;

  // When an address is created, we change the view using an address
  Future<bool> setDropdownByAddess(AddressModel address) async {
    _dropdown = DropdownOption(
      name: address.alias,
      value: address.id.toString(),
    );
    await DBProvider.db.createAddress(address);
    notifyListeners();
    return true;
  }

  Future<bool> setDropdown(DropdownOption dropdown) async {
    _dropdown = dropdown;
    AddressModel address = _addresses.firstWhere(
      (adr) => adr.id.toString() == dropdown.value,
    );
    await DBProvider.db.createAddress(address);
    notifyListeners();
    return true;
  }

  List<DropdownOption> get addressItems => _addressItems;

  setAddressItems(List<AddressModel> addresses) {
    _addressItems.clear();
    for (var address in addresses) {
      _addressItems.add(
        DropdownOption(name: address.alias, value: address.id.toString()),
      );
    }
    notifyListeners();
  }

  initAddress() async {
    AddressModel? address = await DBProvider.db.loadAddress();
    if (address != null) {
      _dropdown = DropdownOption(
        name: address.alias,
        value: address.id.toString(),
      );
      notifyListeners();
    }
  }

  loadAddress() async {
    inAsyncCall = true;
    final addresses = await addressService.getAdress();
    _addresses.clear();
    addresses.add(
      AddressModel(
        alias: S.current.lNewAddress,
        location: Location(x: klatitudeMap, y: klongitudeMap),
      ),
    );
    _addresses.addAll(addresses);
    setAddressItems(addresses);
    inAsyncCall = false;
    notifyListeners();
  }
}
