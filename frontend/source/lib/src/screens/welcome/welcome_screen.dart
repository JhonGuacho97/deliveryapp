import 'package:flutter/material.dart';
import 'package:planck/constants/constants.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/common/launch.dart';
import 'package:planck/src/models/address_model.dart';
import 'package:planck/src/screens/address/address_screen.dart';
import 'package:planck/src/screens/login/login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context),
        theme = Theme.of(context),
        colors = theme.colorScheme;
    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 560,
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: colors.primaryContainer,
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: Icon(
                            Icons.local_mall_outlined,
                            size: 36,
                            color: colors.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        s.welcomeTitle,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        s.welcomeDescription,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _Feature(
                        Icons.storefront_outlined,
                        s.welcomeDiscover,
                        s.welcomeDiscoverMessage,
                      ),
                      const SizedBox(height: 20),
                      _Feature(
                        Icons.delivery_dining_outlined,
                        s.welcomeDelivery,
                        s.welcomeDeliveryMessage,
                      ),
                      const SizedBox(height: 20),
                      _Feature(
                        Icons.route_outlined,
                        s.welcomeTracking,
                        s.welcomeTrackingMessage,
                      ),
                      const SizedBox(height: 36),
                      FilledButton(
                        key: const ValueKey('welcome-explore'),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AddressScreen(
                              address: AddressModel(
                                location: Location(
                                  x: klatitudeMap,
                                  y: klongitudeMap,
                                ),
                              ),
                            ),
                          ),
                        ),
                        child: Text(
                          s.welcomeExplore,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        key: const ValueKey('welcome-access'),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        ),
                        child: Text(
                          s.welcomeAccess,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (kPrivacyUrl.isNotEmpty || kTermsUrl.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          children: [
                            if (kPrivacyUrl.isNotEmpty)
                              TextButton(
                                onPressed: () => goToUrl(kPrivacyUrl),
                                child: Text(s.privacyPolicy),
                              ),
                            if (kTermsUrl.isNotEmpty)
                              TextButton(
                                onPressed: () => goToUrl(kTermsUrl),
                                child: Text(s.termsOfService),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature(this.icon, this.title, this.message);
  final IconData icon;
  final String title, message;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, color: theme.colorScheme.primary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(height: 1.45),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
