import 'package:flutter/foundation.dart';
import 'package:delivery_app/constants/constants.dart';
import 'package:delivery_app/src/models/user_model.dart';
import 'package:delivery_app/src/provider/db_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class PreferencesProvider {
  static PreferencesProvider? _instance;

  PreferencesProvider._internal();

  factory PreferencesProvider() {
    _instance ??= PreferencesProvider._internal();
    return _instance!;
  }

  init() async {
    try {
      _instance!.preferences = await SharedPreferences.getInstance();
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }
  }

  SharedPreferences? preferences;

  set user(UserModel user) {
    if (preferences == null) return;
    preferences!.setInt('userId', user.id);
    preferences!.setString('email', user.email);
    preferences!.setString('image', user.image);
    preferences!.setString('fullName', user.fullName);
    preferences!.setString('phone', user.phone);
    preferences!.setStringList('roles', user.roles);
  }

  UserModel get user {
    return UserModel(
      id: preferences?.getInt('userId') ?? 0,
      email:
          preferences?.getString('email') ??
          'guest@${kNameApp.toLowerCase()}.com',
      fullName: preferences?.getString('fullName') ?? 'Guest $kNameApp',
      phone: preferences?.getString('phone') ?? 's/n',
      image: preferences?.getString('image') ?? kImageDeliveryManDefault,
      addresses: [],
      roles: preferences?.getStringList('roles') ?? [],
      token: preferences?.getString('token') ?? '',
    );
  }

  Future<void> clean({DBProvider? database}) async {
    token = '';
    user = UserModel(
      id: 0,
      email: 'guest@${kNameApp.toLowerCase()}.com',
      fullName: 'Guest $kNameApp',
      phone: 's/n',
      image: kImageDeliveryManDefault,
      roles: [],
      token: '',
      addresses: [],
    );
    isOnline = false;
    await (database ?? DBProvider.db).deleteAddress();
  }

  bool get isGuest {
    if (preferences == null) return true;
    if (preferences!.getInt('userId') == null) return true;
    return preferences!.getInt('userId')! <= 0;
  }

  bool get isAuth {
    if (preferences == null) return false;
    return preferences!.getInt('userId') != null &&
        preferences!.getInt('userId')! > 0 &&
        token.isNotEmpty;
  }

  String get token {
    if (preferences == null) return '';
    return preferences!.getString('token') ?? '';
  }

  set token(String? value) {
    preferences?.setString('token', value ?? '');
  }

  String? get tokenPush {
    if (preferences == null) return null;
    return preferences!.getString('tokenPush');
  }

  set tokenPush(String? value) {
    if (value == null) {
      preferences?.remove('tokenPush');
    } else {
      preferences?.setString('tokenPush', value);
    }
  }

  bool get isOnline {
    if (preferences == null) return false;
    return preferences!.getBool('isOnline') ?? false;
  }

  set isOnline(bool value) {
    if (preferences != null) preferences!.setBool('isOnline', value);
  }

  String get idDevice {
    final existing = preferences?.getString('uuid');
    if (existing != null) return existing;
    if (preferences == null)
      throw StateError(
        'Initialize preferences before requesting the device identifier',
      );
    final generated = const Uuid().v4();
    preferences!.setString('uuid', generated);
    return generated;
  }

  set idDevice(String value) {
    if (preferences != null) preferences!.setString('uuid', value);
  }

  String get locale {
    if (preferences == null) return 'es';
    return preferences!.getString('locale') ?? 'es';
  }

  set locale(String? value) {
    if (preferences != null) preferences!.setString('locale', value!);
  }
}
