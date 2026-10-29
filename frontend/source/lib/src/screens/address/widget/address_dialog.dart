import 'package:flutter/material.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/models/address_model.dart';
import 'package:planck/src/screens/address/address_controller.dart';
import 'package:planck/src/screens/address/widget/address_input.dart';
import 'package:planck/src/screens/address/widget/alias_input.dart';
import 'package:planck/src/screens/main/tab1_controller.dart';
import 'package:planck/src/widgets/address_dropdown/address_dropdown_controller.dart';
import 'package:planck/src/widgets/forms/form_page.dart';
import 'package:provider/provider.dart';

class AddressDialog extends StatelessWidget {
  AddressDialog(this.addressController, {super.key});
  final _form = GlobalKey<FormState>();
  final AddressController addressController;
  @override
  Widget build(BuildContext context) => AppFormDialog(
    title: S.of(context).tAddress,
    formKey: _form,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AliasInput(addressController: addressController),
        const SizedBox(height: 22),
        AddressInput(addressController: addressController),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(S.of(context).bCancel),
      ),
      FilledButton(
        onPressed: () async {
          if (!_form.currentState!.validate()) return;
          _form.currentState!.save();
          FocusScope.of(context).unfocus();
          final navigator = Navigator.of(context),
              catalog = context.read<Tab1Controller>(),
              addresses = context.read<AddressDropdownController>();
          navigator.pop();
          final AddressModel? address = await addressController.createAdrress();
          if (address == null) return;
          await addresses.loadAddress();
          await addresses.setDropdownByAddess(address);
          catalog.load();
          navigator.popUntil((route) => route.isFirst);
        },
        child: Text(S.of(context).bSaveChanges),
      ),
    ],
  );
}
