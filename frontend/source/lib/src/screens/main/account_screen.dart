import 'package:flutter/material.dart';
import 'package:planck/constants/types_constant.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/provider/preferences_provider.dart';
import 'package:planck/src/screens/about/about_screen.dart';
import 'package:planck/src/screens/addresses/addresses_screen.dart';
import 'package:planck/src/screens/admin/credit/credit_screen.dart';
import 'package:planck/src/screens/login/login_screen.dart';
import 'package:planck/src/screens/manager/company/company_screen.dart';
import 'package:planck/src/screens/manager/enrollment/enrollment_screen.dart';
import 'package:planck/src/screens/notification/notification_screen.dart';
import 'package:planck/src/screens/profile/profile_screen.dart';
import 'package:planck/src/widgets/empty_state.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final pref = PreferencesProvider();
    final s = S.of(context);
    final theme = Theme.of(context);
    void open(Widget screen) =>
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    Widget tile(IconData icon, String label, Widget screen) => ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => open(screen),
    );
    return ListView(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        if (!pref.isAuth)
          EmptyState(
            icon: Icons.person_outline_rounded,
            title: s.accountGuestTitle,
            message: s.accountGuestMessage,
            actionLabel: s.bSignin,
            onAction: () => open(const LoginScreen()),
          )
        else ...[
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
                child: const Icon(Icons.person_outline_rounded, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pref.user.fullName,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(pref.user.email, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                tile(
                  Icons.manage_accounts_outlined,
                  s.editProfile,
                  ProfileScreen(),
                ),
                tile(
                  Icons.location_on_outlined,
                  s.tAddresses,
                  AddressesScreen(),
                ),
                tile(
                  Icons.notifications_none_rounded,
                  s.tNotifications,
                  const NotificacionPage(),
                ),
                if (pref.user.roles.contains(TypesRol.admin))
                  tile(
                    Icons.account_balance_wallet_outlined,
                    s.tTopUpBalance,
                    CreditScreen(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(s.accountBusiness, style: theme.textTheme.titleSmall),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                tile(Icons.storefront_outlined, s.tStores, CompanyScreen()),
                tile(
                  Icons.add_business_outlined,
                  s.tRegisterStore,
                  EnrollmentScreen(),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        tile(Icons.info_outline_rounded, s.tAbout, AboutScreen()),
      ],
    );
  }
}
