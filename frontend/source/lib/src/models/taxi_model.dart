import 'package:delivery_app/src/models/address_model.dart';

class TaxiModel {
  TaxiModel({
    required this.from,
    required this.to,
  });

  AddressModel from;
  AddressModel to;
}
