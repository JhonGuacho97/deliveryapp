import 'package:flutter/material.dart';
import 'package:planck/constants/constants.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/widgets/head_autocomplete/head_autocomplete_controller.dart';
import 'package:provider/provider.dart';

class HeadAutocomplete extends StatelessWidget {
  const HeadAutocomplete({
    super.key,
    required this.getController,
    required this.latitude,
    required this.longitude,
  });

  final Function getController;
  final double latitude;
  final double longitude;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HeadAutocompleteController>.value(
      value: HeadAutocompleteController(
        latitude: latitude,
        longitude: longitude,
        getController: getController,
      ),
      child: Consumer<HeadAutocompleteController>(
        builder: (context, headAutocompleteController, child) => Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.all(kDefaultPadding),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(kDefaultPadding * 0.75),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      onSubmitted: (_) =>
                          headAutocompleteController.autocomplete(''),
                      onChanged: (place) =>
                          headAutocompleteController.autocomplete(place),
                      maxLines: 1,
                      minLines: 1,
                      keyboardType: TextInputType.streetAddress,
                      decoration: InputDecoration(
                        icon: const Icon(
                          Icons.map_outlined,
                          color: kPrimaryColor,
                        ),
                        hintText: S.of(context).lSearch,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: headAutocompleteController.predictions.length,
                    itemBuilder: (context, index) => ListTile(
                      onTap: () async {
                        FocusScope.of(context).requestFocus(FocusNode());
                        final String placeId = headAutocompleteController
                            .predictions[index]
                            .placeId;
                        await headAutocompleteController.geocode(placeId);
                        headAutocompleteController.autocomplete('');
                      },
                      title: Text(
                        headAutocompleteController
                            .predictions[index]
                            .description,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
