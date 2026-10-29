import 'package:flutter/material.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/constants/status_constant.dart';
import 'package:delivery_app/constants/types_constant.dart';
import 'package:delivery_app/src/models/petition_model.dart';

String courierMoney(double? value) =>
    value == null ? '—' : '\$' + value.toStringAsFixed(2);
String courierDistance(double? meters) => meters == null
    ? '—'
    : meters < 1000
    ? '${meters.round()} m'
    : '${(meters / 1000).toStringAsFixed(1)} km';
String courierStatus(S s, PetitionModel p) {
  if (p.status == StatusOrder.cancelled) return s.courierCancelled;
  if (p.status >= StatusOrder.delivered) return s.courierDone;
  if (p.status == StatusOrder.taken) return s.courierOnWay;
  if (p.preparationStatus == 'preparing') return s.courierPreparing;
  if (p.preparationStatus == 'ready') return s.courierReady;
  return s.courierHeading;
}

String courierError(S s, String code) => switch (code) {
  'gps' => s.courierGpsError,
  'balance' => s.courierBalanceError,
  'changed' => s.courierChangedError,
  'session' => s.courierSessionError,
  _ => s.courierNetworkError,
};

class CourierError extends StatelessWidget {
  const CourierError(this.code, {super.key});
  final String? code;
  @override
  Widget build(BuildContext context) => code == null
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Semantics(
            liveRegion: true,
            child: Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  courierError(S.of(context), code!),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ),
          ),
        );
}

class CourierStop extends StatelessWidget {
  const CourierStop({
    super.key,
    required this.label,
    required this.title,
    required this.address,
    required this.icon,
    this.distance,
  });
  final String label, title, address;
  final IconData icon;
  final double? distance;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Icon(icon, color: theme.colorScheme.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label +
                    (distance == null ? '' : ' · ' + courierDistance(distance)),
                style: theme.textTheme.labelMedium,
              ),
              const SizedBox(height: 4),
              Text(title, style: theme.textTheme.titleSmall),
              const SizedBox(height: 3),
              Text(address, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class CourierCard extends StatelessWidget {
  const CourierCard(this.petition, {super.key, required this.onTap});
  final PetitionModel petition;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final s = S.of(context), p = petition;
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('delivery-${p.id}'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '#${p.id} · ' +
                          (p.payment == TypesPayment.cash
                              ? s.courierCash
                              : s.courierPaid),
                      style: theme.textTheme.labelLarge,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                courierMoney(
                  p.isAssignedToMe ? p.deliverymanProfit : p.estimatedProfit,
                ),
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(s.courierGain, style: theme.textTheme.bodySmall),
              const SizedBox(height: 20),
              CourierStop(
                label: s.courierPickup,
                title: p.store.name,
                address: p.store.address,
                icon: Icons.storefront_outlined,
                distance: p.pickupDistanceMeters,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(height: 1),
              ),
              CourierStop(
                label: s.courierDropoff,
                title: p.user.fullName,
                address: p.address,
                icon: Icons.location_on_outlined,
                distance: p.tripDistanceMeters,
              ),
              const SizedBox(height: 16),
              Text(
                courierStatus(s, p),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
