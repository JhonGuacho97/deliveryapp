import 'package:flutter/material.dart';
import 'package:delivery_app/constants/constants.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/common/launch.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context), theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.tAbout)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 24),
          Icon(
            Icons.local_mall_outlined,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            kNameApp,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(s.welcomeDescription, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(
            kVersionn,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 32),
          if (kPrivacyUrl.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: Text(s.privacyPolicy),
              onTap: () => goToUrl(kPrivacyUrl),
            ),
          if (kTermsUrl.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(s.termsOfService),
              onTap: () => goToUrl(kTermsUrl),
            ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(s.softwareLicenses),
            onTap: () => showLicensePage(
              context: context,
              applicationName: kNameApp,
              applicationVersion: kVersionn,
            ),
          ),
        ],
      ),
    );
  }
}
