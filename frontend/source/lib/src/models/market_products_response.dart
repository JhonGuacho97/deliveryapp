import 'package:delivery_app/src/models/group_model.dart';
import 'package:delivery_app/src/models/product_model.dart';

class MarketProductsResponse {
  MarketProductsResponse({
    required this.groups,
    required this.products,
    this.hasError = false,
  });

  List<GroupModel> groups;
  List<ProductModel> products;
  final bool hasError;

  factory MarketProductsResponse.fromJson(Map<String, dynamic> json) =>
      MarketProductsResponse(
        groups: List<GroupModel>.from(
          json["groups"].map((x) => GroupModel.fromJson(x)),
        ),
        products: List<ProductModel>.from(
          json["products"].map((x) => ProductModel.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "groups": List<dynamic>.from(groups.map((x) => x.toJson())),
    "products": List<dynamic>.from(products.map((x) => x.toJson())),
  };
}
