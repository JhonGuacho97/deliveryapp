import 'package:flutter/material.dart';
import 'package:planck/constants/constants.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/common/launch.dart';
import 'package:planck/src/models/petition_model.dart';

class ButtonClientDirection extends StatelessWidget {
  const ButtonClientDirection({
    super.key,
    required this.petition,
  }) ;

  final PetitionModel petition;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0))),
      label: Text(
        S.of(context).bRouteClient,
        style: const TextStyle(color: kPrimaryColor),
      ),
      icon: const Icon(
        Icons.person_pin_circle_outlined,
        color: kPrimaryColor,
        size: 33,
      ),
      onPressed: () {
        openMapDirections(petition.location.x, petition.location.y);
      },
    );
  }
}
