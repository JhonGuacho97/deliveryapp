import 'package:flutter/material.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/screens/login/login_controller.dart';
import 'package:provider/provider.dart';

class TabsButton extends StatelessWidget {
  const TabsButton({super.key, required this.isPageSignin});
  final bool isPageSignin;
  @override
  Widget build(BuildContext context) {
    final selected = isPageSignin ? 0 : 1, theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          for (var i = 0; i < 2; i++)
            Expanded(
              child: Semantics(
                selected: selected == i,
                child: TextButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    context.read<LoginController>().currentScreen = i;
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: selected == i
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                    backgroundColor: selected == i
                        ? theme.colorScheme.surface
                        : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    i == 0 ? S.of(context).bSignin : S.of(context).bSignup,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
