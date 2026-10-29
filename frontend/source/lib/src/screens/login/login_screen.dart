import 'package:flutter/material.dart';
import 'package:planck/src/screens/login/login_controller.dart';
import 'package:planck/src/screens/login/signin_screen.dart';
import 'package:planck/src/screens/login/signup_screen.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginController(),
      child: const _Screens(),
    );
  }
}

class _Screens extends StatefulWidget {
  const _Screens();

  @override
  State<_Screens> createState() => _ScreensState();
}

class _ScreensState extends State<_Screens> {
  final _pages = [SigninScreen(), SignupScreen()];

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: context.watch<LoginController>().currentScreen,
      children: _pages,
    );
  }
}
