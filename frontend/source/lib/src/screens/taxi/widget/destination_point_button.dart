import 'package:flutter/material.dart';
import 'package:planck/constants/constants.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/common/map_helper.dart';
import 'package:planck/src/provider/preferences_provider.dart';
import 'package:planck/src/screens/taxi/taxi_controller.dart';
import 'package:planck/src/widgets/primary_button.dart';

class DestinationPointButton extends StatelessWidget {
  const DestinationPointButton({
    super.key,
    required this.prefs,
    required this.taxiController,
  }) ;

  final TaxiController taxiController;
  final PreferencesProvider prefs;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: PrimaryButton(
          icon: Icons.assistant_photo_outlined,
          text: S.of(context).bSetDestinationPoint,
          onPressed: () async {
            if (taxiController.initMove == true) return;
            FocusScope.of(context).requestFocus(FocusNode());

            double travelDistance = MapHelper().calculateDistance(
                taxiController.taxi.from.location.x,
                taxiController.taxi.from.location.y,
                taxiController.address.location.x,
                taxiController.address.location.y);
            if (travelDistance <= kMinimumTravelDistance) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    backgroundColor: kErrorColor,
                    content: Text(
                      S
                          .of(context)
                          .mMinimumTravelDistance(kMinimumTravelDistance),
                    )),
              );
              return;
            }
            taxiController
                .addMarkertDetinationLocation(taxiController.address.location);
            taxiController.establishedDetinationLocation = true;

            Future.delayed(
              const Duration(milliseconds: 100),
              () => taxiController.centerMap(),
            );
          },
        ),
      ),
    );
  }
}
