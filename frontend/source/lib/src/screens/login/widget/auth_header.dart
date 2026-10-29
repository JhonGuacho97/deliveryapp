import 'package:flutter/material.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/screens/login/widget/tabs_button.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.signin});
  final bool signin;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context),
        theme = Theme.of(context),
        colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (Navigator.of(context).canPop())
              const BackButton()
            else
              const SizedBox(width: 48),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                Icons.delivery_dining_rounded,
                size: 30,
                color: colors.onPrimaryContainer,
              ),
            ),
          ],
        ),
        SizedBox(height: signin ? 24 : 16),
        Text(
          signin ? s.authWelcome : s.authCreateTitle,
          style:
              (signin
                      ? theme.textTheme.headlineLarge
                      : theme.textTheme.headlineMedium)
                  ?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                    height: 1.15,
                  ),
        ),
        SizedBox(height: signin ? 12 : 8),
        Text(
          signin ? s.authWelcomeMessage : s.authCreateMessage,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        SizedBox(height: signin ? 28 : 20),
        TabsButton(isPageSignin: signin),
        SizedBox(height: signin ? 28 : 20),
      ],
    );
  }
}
