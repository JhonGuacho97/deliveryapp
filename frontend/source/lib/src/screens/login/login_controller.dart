import 'package:flutter/material.dart';

class LoginController with ChangeNotifier {
  int _currentScreen = 0;

  int get currentScreen => _currentScreen;

  set currentScreen(int current) {
    if (current < 0 || current > 1 || current == _currentScreen) return;
    _currentScreen = current;
    notifyListeners();
  }
}
