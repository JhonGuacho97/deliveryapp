import 'package:flutter/material.dart';
import 'package:delivery_app/generated/l10n.dart';

class NotificacionPage extends StatelessWidget {
  const NotificacionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context), theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.tNotifications)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.notifications_none_outlined,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(s.noNotifications, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
