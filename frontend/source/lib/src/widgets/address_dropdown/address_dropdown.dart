import 'dart:async';

import 'package:drop_down_list/drop_down_list.dart';
import 'package:delivery_app/src/models/dropdown_option.dart';
import 'package:flutter/material.dart';
import 'package:delivery_app/constants/constants.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/models/address_model.dart';
import 'package:delivery_app/src/provider/db_provider.dart';
import 'package:delivery_app/src/screens/address/address_screen.dart';
import 'package:delivery_app/src/screens/cart_summary/cart_summary_controller.dart';
import 'package:delivery_app/src/screens/main/tab1_controller.dart';
import 'package:delivery_app/src/widgets/address_dropdown/address_dropdown_controller.dart';
import 'package:provider/provider.dart';

class AddressDropdown extends StatelessWidget {
  final bool isScreenMain;

  const AddressDropdown({super.key, required this.isScreenMain});
  final int milliseconds = 210;

  @override
  Widget build(BuildContext context) {
    final addressDropdownController = Provider.of<AddressDropdownController>(
      context,
    );
    return isScreenMain
        ? _buttonTab1(context, addressDropdownController)
        : _buttonCartSumary(context, addressDropdownController);
  }

  TextButton _buttonTab1(
    BuildContext context,
    AddressDropdownController addressDropdownController,
  ) {
    goToAdrresScreen() {
      Timer(Duration(milliseconds: milliseconds), () {
        AddressModel address = AddressModel(
          location: Location(x: klatitudeMap, y: klongitudeMap),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddressScreen(address: address),
          ),
        );
      });
    }

    return TextButton(
      onPressed: () async {
        if (addressDropdownController.inAsyncCall) return;

        final tab1Controller = Provider.of<Tab1Controller>(
          context,
          listen: false,
        );
        if (addressDropdownController.addressItems.length >= 2) {
          onTextFieldTap(context, addressDropdownController, goToAdrresScreen);
        } else {
          final navigator = Navigator.of(context);
          tab1Controller.inAsyncCall = true;
          AddressModel? address = await DBProvider.db.loadAddress();
          if (address == null) {
            address = AddressModel(
              location: Location(x: klatitudeMap, y: klongitudeMap),
            );
            await DBProvider.db.createAddress(address);
          }
          tab1Controller.inAsyncCall = false;
          navigator.push(
            MaterialPageRoute(
              builder: (context) => AddressScreen(address: address!),
            ),
          );
        }
      },
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        alignment: Alignment.centerLeft,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).deliverTo,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  addressDropdownController.dropdown.name,
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: kDefaultPadding * .5),
              const Icon(Icons.expand_more_rounded),
            ],
          ),
          Visibility(
            visible: addressDropdownController.inAsyncCall,
            child: const LinearProgressIndicator(),
          ),
        ],
      ),
    );
  }

  GestureDetector _buttonCartSumary(
    BuildContext context,
    AddressDropdownController addressDropdownController,
  ) {
    goToAdrresScreen() {
      final cartSummaryController = Provider.of<CartSummaryController>(
        context,
        listen: false,
      );

      Timer(Duration(milliseconds: milliseconds), () {
        if (cartSummaryController.isSumaryTaxi) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).popUntil((route) => route.isFirst);
          AddressModel address = AddressModel(
            location: Location(x: klatitudeMap, y: klongitudeMap),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddressScreen(address: address),
            ),
          );
        }
      });
    }

    return GestureDetector(
      onTap: () {
        if (addressDropdownController.inAsyncCall) return;
        onTextFieldTap(context, addressDropdownController, goToAdrresScreen);
      },
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(kDefaultPadding),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.place_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: kDefaultPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).deliverTo,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(addressDropdownController.dropdown.name),
                    ],
                  ),
                ),
                const Icon(Icons.expand_more_rounded),
                // const Icon(Icons.map_outlined, color: kPrimaryColor),
              ],
            ),
            Visibility(
              visible: addressDropdownController.inAsyncCall,
              child: const LinearProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }

  onTextFieldTap(
    BuildContext context,
    AddressDropdownController addressDropdownController,
    Function goToAdrresScreen,
  ) {
    final cartSummaryController = Provider.of<CartSummaryController>(
      context,
      listen: false,
    );
    final tab1Controller = Provider.of<Tab1Controller>(context, listen: false);
    DropDownState(
      dropDown: DropDown<String>(
        bottomSheetTitle: Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: Row(
            children: [
              const Icon(Icons.place_outlined, color: kPrimaryColor),
              const SizedBox(width: kDefaultPadding),
              Text(
                S.of(context).lDeliveryAddress,
                style: const TextStyle(fontSize: 17),
              ),
            ],
          ),
        ),
        data: addressDropdownController.addressItems,
        onSelected: (List<dynamic> selectedList) async {
          for (var item in selectedList) {
            if (item is DropdownOption) {
              if (item.value == '0') {
                goToAdrresScreen();
                return;
              } else {
                await addressDropdownController.setDropdown(item);
                if (!isScreenMain) {
                  cartSummaryController.load();
                }
                tab1Controller.load();
              }
              return;
            }
          }
        },
        enableMultipleSelection: false,
      ),
    ).showModal(context);
  }
}
