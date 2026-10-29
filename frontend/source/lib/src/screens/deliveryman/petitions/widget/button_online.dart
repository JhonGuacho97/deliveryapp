import 'package:flutter/material.dart';
import 'package:delivery_app/constants/constants.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/screens/deliveryman/petitions/petitions_controller.dart';

class ButtonOnline extends StatelessWidget {
  const ButtonOnline({
    super.key,
    required this.petitionsController,
  }) ;

  final PetitionsController petitionsController;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0))),
      label: Text(
        S.of(context).bOnline,
        style: const TextStyle(color: kPrimaryColor),
      ),
      icon: const Icon(
        Icons.broadcast_on_home_outlined,
        color: kPrimaryColor,
        size: 28,
      ),
      onPressed: () {
        petitionsController.startOffline();
      },
    );
  }
}
