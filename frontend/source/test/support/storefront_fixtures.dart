import 'package:planck/src/models/company_model.dart';
import 'package:planck/src/models/fee_model.dart';
import 'package:planck/src/models/market_products_response.dart';
import 'package:planck/src/models/product_model.dart';
import 'package:planck/src/models/request_model.dart' show Location;
import 'package:planck/src/services/market_service.dart';

CompanyModel storefrontCompany({int id = 1, String? image}) => CompanyModel(
  id: id,
  storeId: id,
  isOpen: true,
  name: 'La Esquina · Pizzería Demo',
  address: 'Calle Bolívar y Mercadillo',
  contact: '0990000001',
  image: image ?? '',
  open: '10:00:00',
  close: '22:00:00',
  categoryId: 1,
  type: 10,
  location: Location(x: -4.0245, y: -79.199),
);

ProductModel storefrontDish(
  int id,
  String name,
  double price, {
  String image = '',
}) => ProductModel(
  id: id,
  companyId: 1,
  companyName: 'La Esquina · Pizzería Demo',
  name: name,
  description: 'Preparado al momento con ingredientes de la casa.',
  type: 1,
  price: price,
  image: image,
);

class StorefrontMarket extends MarketService {
  List<ProductModel> dishes = [
    storefrontDish(
      101,
      'Pizza margarita con mozzarella, tomate y albahaca',
      8.5,
    ),
    storefrontDish(102, 'Pizza pepperoni', 10),
    storefrontDish(103, 'Limonada de la casa', 2),
    storefrontDish(104, 'Pan de ajo', 3),
    storefrontDish(105, 'Pizza vegetariana', 9.5),
    storefrontDish(106, 'Pizza cuatro quesos', 11),
  ];
  int requests = 0;
  bool fail = false;
  @override
  Future<MarketProductsResponse> getProducts(int companyId, int groupId) async {
    requests++;
    return MarketProductsResponse(
      groups: [],
      products: fail ? [] : dishes,
      hasError: fail,
    );
  }

  @override
  Future<List<FeeModel>> deliveryCost(
    String companyId,
    double lat,
    double lng, {
    bool isSumaryTaxi = false,
    double fromLtTaxi = 0,
    double fromLgTaxi = 0,
  }) async => [];
}
