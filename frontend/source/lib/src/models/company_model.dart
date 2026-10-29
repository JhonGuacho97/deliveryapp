import 'package:planck/src/models/request_model.dart';
import 'package:planck/constants/types_constant.dart';

class CompanyModel {
  CompanyModel({
    required this.id,
    required this.storeId,
    required this.isOpen,
    required this.name,
    required this.address,
    required this.contact,
    required this.image,
    required this.open,
    required this.close,
    required this.categoryId,
    required this.type,
    required this.location,
  });

  int id;
  int storeId;
  bool isOpen;
  String name;
  String address;
  String contact;
  String image;
  String open;
  String close;
  int categoryId;
  int type;
  Location location;

  factory CompanyModel.fromJson(Map<String, dynamic> json) => CompanyModel(
        id: json["id"],
        storeId: json["storeId"],
        isOpen: json["isOpen"],
        name: json["name"],
        address: json["address"],
        contact: json["contact"],
        image: json["image"],
        open: json["open"],
        close: json["close"],
        categoryId: json["categoryId"],
        type: json["type"] ?? TypesCompany.store,
        location: Location.fromJson(json["location"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "storeId": storeId,
        "isOpen": isOpen,
        "name": name,
        "address": address,
        "contact": contact,
        "image": image,
        "open": open,
        "close": close,
        "categoryId": categoryId,
        "type": type,
        "location": location.toJson()
      };

  @override
  String toString() {
    return 'Company: $id Name: $name';
  }
}
