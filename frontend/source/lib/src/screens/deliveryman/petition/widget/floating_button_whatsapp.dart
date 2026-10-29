import 'package:flutter/material.dart';
import 'package:planck/constants/constants.dart';
import 'package:planck/constants/status_constant.dart';
import 'package:planck/src/common/launch.dart';
import 'package:planck/src/models/petition_model.dart';
import 'package:planck/src/widgets/circular_button.dart';

class FloatingButtonWhatsapp extends StatelessWidget {
  const FloatingButtonWhatsapp({
    super.key,
    required this.petition,
  }) ;

  final PetitionModel petition;

  @override
  Widget build(BuildContext context) {
    return petition.status == StatusOrder.assigned
        ? Positioned(
            top: 120,
            right: kDefaultPadding,
            child: CircularButton(
              icon: const Icon(Icons.whatshot_outlined,
                  color: kPrimaryColor, size: 40),
              onPressed: () {
                sendWhatsapp(petition.store.contact,
                    '${petition.user.fullName}\n${petition.products.join('\n')}');
              },
            ),
          )
        : Container();
  }
}
