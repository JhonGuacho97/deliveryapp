import 'package:flutter/foundation.dart';
import 'package:planck/src/services/google_identity_gateway.dart';
import 'package:planck/src/models/user_model.dart';
import 'package:planck/src/provider/db_provider.dart';
import 'package:planck/src/provider/preferences_provider.dart';
import 'package:planck/src/services/auth_service.dart';

class GoogleButtonController extends ChangeNotifier {
  GoogleButtonController({
    GoogleIdentityGateway? gateway,
    AuthService? authService,
    PreferencesProvider? preferences,
    DBProvider? database,
  }) : _gateway = gateway ?? GoogleIdentityGateway.instance,
       authService = authService ?? AuthService(),
       prefs = preferences ?? PreferencesProvider(),
       _database = database ?? DBProvider.db;
  final GoogleIdentityGateway _gateway;
  final AuthService authService;
  final PreferencesProvider prefs;
  final DBProvider _database;

  Future<UserModel?> sigInGoogle() async {
    GoogleIdentity? identity;
    try {
      identity = await _gateway.signIn();
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      return null;
    }

    if (identity == null) {
      return null;
    }

    Map<String, dynamic>? decodedResp = await authService.google(
      identity.id,
      identity.fullName,
      identity.email,
      identity.image,
    );

    if (decodedResp == null) {
      return null;
    }
    if (decodedResp.containsKey('user')) {
      UserModel user = UserModel.fromJson(decodedResp['user']);
      if (user.addresses.isNotEmpty) {
        await _database.createAddress(user.addresses.first);
      }
      prefs.user = user;
      prefs.token = user.token;
      return user;
    }
    return null;
  }
}
