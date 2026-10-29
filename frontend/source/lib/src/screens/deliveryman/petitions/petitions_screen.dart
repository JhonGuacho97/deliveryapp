import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:planck/src/widgets/delivery_glass_scaffold.dart';
import 'package:provider/provider.dart';
import 'package:planck/constants/code_error_constant.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/provider/preferences_provider.dart';
import 'package:planck/src/screens/deliveryman/petitions/petitions_controller.dart';
import 'package:planck/src/screens/deliveryman/petitions/courier_widgets.dart';
import 'package:planck/src/screens/deliveryman/petition/petition_screen.dart';
import 'package:planck/src/screens/profile/profile_screen.dart';
import 'package:planck/src/screens/about/about_screen.dart';
import 'package:planck/src/screens/notification/notification_screen.dart';
import 'package:planck/src/screens/welcome/welcome_screen.dart';
import 'package:planck/src/widgets/empty_state.dart';

class PetitionsScreen extends StatefulWidget {
  const PetitionsScreen({super.key});
  @override
  State<PetitionsScreen> createState() => _PetitionsScreenState();
}

class _PetitionsScreenState extends State<PetitionsScreen>
    with WidgetsBindingObserver {
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _validate();
        context.read<PetitionsController>().loadPetitions();
        _startTimer();
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (!mounted) return;
      final c = context.read<PetitionsController>();
      if (c.currentScreen == 0)
        c.loadPetitions();
      else if (c.currentScreen == 1)
        c.loadEarnings();
    });
  }

  Future<void> _validate() async {
    final code = await context.read<PetitionsController>().checkSession();
    if (!mounted ||
        code != CodeError.unauthorized ||
        PreferencesProvider().isGuest)
      return;
    await context.read<PetitionsController>().stopTracking();
    await PreferencesProvider().clean();
    if (mounted)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (_) => false,
      );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _validate();
      context.read<PetitionsController>().loadPetitions();
      _startTimer();
    } else {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<PetitionsController>();
    final s = S.of(context);
    final titles = [s.courierDeliveries, s.courierEarnings, s.courierAccount];
    return DeliveryGlassScaffold(
      appBar: AppBar(
        title: Text(titles[c.currentScreen]),
        actions: [
          if (c.currentScreen < 2)
            IconButton(
              tooltip: s.courierRefresh,
              onPressed: c.inAsyncCall
                  ? null
                  : () => c.currentScreen == 0
                        ? c.loadPetitions()
                        : c.loadEarnings(),
              icon: const Icon(Icons.refresh_rounded),
            ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: switch (c.currentScreen) {
          0 => _Feed(c),
          1 => _Income(c),
          _ => const _Account(),
        },
      ),
      selectedIndex: c.currentScreen,
      onTabSelected: (i) => c.currentScreen = i,
      tabs: [
        GlassTab(
          icon: const Icon(Icons.route_outlined),
          activeIcon: const Icon(Icons.route_rounded),
          label: s.courierDeliveries,
        ),
        GlassTab(
          icon: const Icon(Icons.account_balance_wallet_outlined),
          activeIcon: const Icon(Icons.account_balance_wallet_rounded),
          label: s.courierEarnings,
        ),
        GlassTab(
          icon: const Icon(Icons.person_outline_rounded),
          activeIcon: const Icon(Icons.person_rounded),
          label: s.courierAccount,
        ),
      ],
    );
  }
}

void openCourierDelivery(BuildContext context, dynamic petition) =>
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PetitionScreen(petition)),
    );

class _Feed extends StatelessWidget {
  const _Feed(this.c);
  final PetitionsController c;
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: c.loadPetitions,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 10,
                        color: c.isOnline
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          c.isOnline ? s.courierOnline : s.courierOffline,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      if (c.availabilityBusy)
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Switch(
                          key: const ValueKey('courier-availability'),
                          value: c.isOnline,
                          onChanged: c.setAvailability,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    c.isOnline
                        ? s.courierOnlineHint
                        : c.active.isNotEmpty
                        ? s.courierOfflineActive
                        : s.courierOfflineHint,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          CourierError(c.error),
          if (c.inAsyncCall && c.petitions.isEmpty)
            const Center(child: CircularProgressIndicator())
          else ...[
            if (c.active.isNotEmpty) ...[
              Text(s.courierActive, style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              for (final p in c.active)
                CourierCard(p, onTap: () => openCourierDelivery(context, p)),
            ],
            if (c.offers.isNotEmpty) ...[
              Text(s.courierOffers, style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              for (final p in c.offers)
                CourierCard(p, onTap: () => openCourierDelivery(context, p)),
              Text(s.courierApprox, style: theme.textTheme.bodySmall),
            ],
            if (c.petitions.isEmpty)
              EmptyState(
                icon: Icons.delivery_dining_outlined,
                title: s.courierEmpty,
                message: c.isOnline ? s.courierEmptyHint : s.courierOfflineHint,
                actionLabel: s.courierRefresh,
                onAction: c.loadPetitions,
              ),
          ],
        ],
      ),
    );
  }
}

class _Income extends StatelessWidget {
  const _Income(this.c);
  final PetitionsController c;
  @override
  Widget build(BuildContext context) {
    final s = S.of(context), theme = Theme.of(context);
    final income = c.earnings;
    Widget metric(String label, String value, String? hint) => Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            Text(value, style: theme.textTheme.headlineMedium),
            if (hint != null) ...[
              const SizedBox(height: 8),
              Text(hint, style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
    return RefreshIndicator(
      onRefresh: c.loadEarnings,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          OutlinedButton.icon(
            key: const ValueKey('courier-day'),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: c.selectedDay,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null) c.selectedDay = date;
            },
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text(
              MaterialLocalizations.of(context).formatMediumDate(c.selectedDay),
            ),
          ),
          const SizedBox(height: 16),
          CourierError(c.error),
          if (income == null)
            Text(s.courierUnknown)
          else ...[
            metric(
              s.courierDayGain,
              courierMoney(income.earnings),
              '${income.completedCount} · ' + s.courierCompleted,
            ),
            metric(
              s.courierCredit,
              courierMoney(income.operatingBalance),
              s.courierCreditHint,
            ),
            metric(
              s.courierSettlement,
              courierMoney(income.settlementAmount),
              s.courierSettlementHint,
            ),
            if (income.unpricedCount > 0)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(s.courierUnpriced),
              ),
            const SizedBox(height: 16),
            for (final p in income.deliveries)
              CourierCard(p, onTap: () => openCourierDelivery(context, p)),
            if (income.deliveries.isEmpty)
              Text(s.courierIncomeEmpty, style: theme.textTheme.bodySmall),
          ],
          const SizedBox(height: 20),
          Text(s.courierIncomeHint, style: theme.textTheme.bodySmall),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(s.courierHistory),
            value: c.historyVisible,
            onChanged: (v) {
              c.historyVisible = v ?? false;
              c.loadEarnings();
            },
          ),
          if (c.historyVisible)
            for (final p in c.historyItems)
              CourierCard(p, onTap: () => openCourierDelivery(context, p)),
        ],
      ),
    );
  }
}

class _Account extends StatelessWidget {
  const _Account();
  @override
  Widget build(BuildContext context) {
    final s = S.of(context), theme = Theme.of(context);
    final user = PreferencesProvider().user;
    Widget tile(IconData icon, String label, Widget screen) => ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
    );
    return ListView(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        const SizedBox(height: 12),
        CircleAvatar(
          radius: 32,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: const Icon(Icons.delivery_dining_rounded, size: 32),
        ),
        const SizedBox(height: 20),
        Text(
          user.fullName,
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        Text(
          s.courierLabel,
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        Card(
          child: Column(
            children: [
              tile(
                Icons.manage_accounts_outlined,
                s.editProfile,
                ProfileScreen(),
              ),
              tile(
                Icons.notifications_none_rounded,
                s.tNotifications,
                const NotificacionPage(),
              ),
              tile(Icons.info_outline, s.tAbout, AboutScreen()),
            ],
          ),
        ),
      ],
    );
  }
}
