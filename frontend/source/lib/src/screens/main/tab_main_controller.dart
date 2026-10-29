import 'package:flutter/material.dart';
import 'package:planck/constants/code_error_constant.dart';
import 'package:planck/src/services/auth_service.dart';

class TabManController with ChangeNotifier {
  final AuthService authService = AuthService();

  int _currentScreen = 0;

  int get currentScreen => _currentScreen;

  set currentScreen(int current) {
    if (current < 0 || current > 2 || current == _currentScreen) return;
    _currentScreen = current;

    notifyListeners();
  }

  Future<int> checkSession() async {
    Map<String, dynamic>? decodedResp = await authService.check();
    if (decodedResp == null) {
      return CodeError.unknown;
    }
    if (decodedResp.containsKey('user')) {
      return CodeError.none;
    } else if (decodedResp.containsKey('codeError')) {
      return decodedResp['codeError'];
    }
    return CodeError.unauthorized;
  }
}
