import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:delivery_app/constants/code_error_constant.dart';
import 'package:delivery_app/src/models/balance_model.dart';
import 'package:delivery_app/src/models/user_model.dart';
import 'package:delivery_app/src/provider/preferences_provider.dart';
import 'package:delivery_app/src/services/auth_service.dart';
import 'package:delivery_app/src/services/balance_service.dart';

class ProfileController with ChangeNotifier {
  final AuthService authService;
  final prefs = PreferencesProvider();

  String _fullName = '';
  String _email = '';
  String _password = '';
  String _phone = '';
  String olpPhone = '';
  bool _inAsyncCall = false;

  bool _disposed = false;
  bool _changed = false;
  bool balanceAvailable = false;
  bool get hasChanges => _changed;
  void markChanged() {
    if (!_changed) {
      _changed = true;
      notifyListeners();
    }
  }

  ProfileController({
    AuthService? auth,
    BalanceService? balances,
    bool loadOnCreate = true,
  }) : authService = auth ?? AuthService(),
       balanceService = balances ?? BalanceService() {
    _fullName = prefs.user.fullName;
    _email = prefs.user.email;
    olpPhone = prefs.user.phone;
    _phone = olpPhone;

    if (loadOnCreate) loadBalance();
  }

  BalanceModel _balance = BalanceModel();

  BalanceModel get balance => _balance;

  set balance(BalanceModel balance) {
    _balance = balance;
    balanceAvailable = true;
    notifyListeners();
  }

  final BalanceService balanceService;

  loadBalance() async {
    BalanceModel? balanceResponse = await balanceService.getBalance();
    if (balanceResponse == null) return;
    balance = balanceResponse;
  }

  String get email => _email;

  set email(String email) {
    _email = email;
    notifyListeners();
  }

  String get fullName => _fullName;

  set fullName(String fullName) {
    _fullName = fullName;
    notifyListeners();
  }

  String get password => _password;

  set password(String password) {
    _password = password;
    notifyListeners();
  }

  String get phone => _phone;

  set phone(String phone) {
    _phone = phone;
    notifyListeners();
  }

  bool get inAsyncCall => _inAsyncCall;

  set inAsyncCall(bool asyncCall) {
    _inAsyncCall = asyncCall;
    notifyListeners();
  }

  Future<bool> logOut() async {
    return await authService.logOut();
  }

  Future<int> update() async {
    inAsyncCall = true;
    Map<String, dynamic>? decodedResp = await authService.update(
      email,
      fullName,
      phone,
    );
    inAsyncCall = false;

    if (decodedResp == null) {
      return CodeError.unknown;
    }
    if (decodedResp.containsKey('user')) {
      prefs.user = UserModel.fromJson(decodedResp['user']);
      _changed = false;
      olpPhone = prefs.user.phone;
      _phone = olpPhone;
      notifyListeners();
      return CodeError.none;
    } else if (decodedResp.containsKey('codeError')) {
      return decodedResp['codeError'];
    }
    return CodeError.unknown;
  }

  Future<bool> updatePasswor() async {
    inAsyncCall = true;
    bool isUpdated = await authService.updatePasswor(password);
    inAsyncCall = false;
    return isUpdated;
  }

  Future<int> changeImage(String image) async {
    Map<String, dynamic>? decodedResp = await authService.changeImage(image);
    inAsyncCall = false;

    if (decodedResp == null) {
      return CodeError.unknown;
    }
    if (decodedResp.containsKey('user')) {
      prefs.user = UserModel.fromJson(decodedResp['user']);
      return CodeError.none;
    } else if (decodedResp.containsKey('codeError')) {
      return decodedResp['codeError'];
    }
    return CodeError.unknown;
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
