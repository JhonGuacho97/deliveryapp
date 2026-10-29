import 'package:flutter/material.dart';
import 'package:delivery_app/constants/constants.dart';
import 'package:delivery_app/constants/preparation_status.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/screens/deliveryman/petition/petition_controller.dart';
import 'package:delivery_app/src/screens/deliveryman/petitions/petitions_controller.dart';
import 'package:delivery_app/src/widgets/circular_button.dart';
import 'package:delivery_app/src/widgets/confirmation_dialog.dart';
import 'package:provider/provider.dart';

class ButtonCollectFloatHead extends StatelessWidget {
  const ButtonCollectFloatHead({super.key, required this.petitionController});

  final PetitionController petitionController;

  @override
  Widget build(BuildContext context) {
    return CircularButton(
      icon: const Icon(
        Icons.delivery_dining_outlined,
        color: kPrimaryColor,
        size: 40,
      ),
      onPressed: () async {
        if (petitionController.petition.preparationStatus != null &&
            petitionController.petition.preparationStatus !=
                PreparationStatus.ready) {
          await petitionController.refreshPetition();
          if (!context.mounted) return;
          if (petitionController.petition.preparationStatus !=
              PreparationStatus.ready) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.of(context).waitingForKitchen)),
            );
            return;
          }
        }
        showDialog(
          context: context,
          builder: (context) => ConfirmationDialog(
            S.of(context).mDConfirmOrder,
            iconOk: const Icon(Icons.delivery_dining_outlined),
            labelOk: S.of(context).bDone,
            onPressedOk: () async {
              final petitionsController = Provider.of<PetitionsController>(
                context,
                listen: false,
              );
              final s = S.of(context);
              ScaffoldMessengerState scaffold = ScaffoldMessenger.of(context);
              final collected = await petitionController.collect();
              petitionsController.loadPetitions();
              scaffold.showSnackBar(
                SnackBar(
                  backgroundColor: kPrimaryColor,
                  content: Text(
                    collected ? s.mRConfirmOrde : s.kitchenActionError,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
