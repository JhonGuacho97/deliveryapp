import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:delivery_app/constants/status_constant.dart';
import 'package:delivery_app/constants/types_constant.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/models/petition_model.dart';
import 'package:delivery_app/src/models/chat_model.dart';
import 'package:delivery_app/src/screens/chat/chat_screen.dart';
import 'package:delivery_app/src/screens/deliveryman/petitions/petitions_controller.dart';
import 'package:delivery_app/src/screens/deliveryman/petitions/courier_widgets.dart';

class PetitionScreen extends StatefulWidget {
  const PetitionScreen(this.petition, {super.key});
  final PetitionModel petition;
  @override
  State<PetitionScreen> createState() => _PetitionScreenState();
}

class _PetitionScreenState extends State<PetitionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted)
        context.read<PetitionsController>().refreshDelivery(widget.petition);
    });
  }

  Future<bool> _confirm(String title, String message, String action) async {
    final s = S.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(s.courierBack),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(action),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _open(Uri uri) async {
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
    } catch (_) {}
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).courierNetworkError)),
      );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<PetitionsController>(),
        s = S.of(context),
        theme = Theme.of(context);
    final p = c.current(widget.petition);
    final busy = c.busy(p.id), mine = p.isAssignedToMe;
    final active =
        mine && [StatusOrder.assigned, StatusOrder.taken].contains(p.status);
    final canCollect =
        p.preparationStatus == null || p.preparationStatus == 'ready';
    String? action, label;
    if (p.status == StatusOrder.started && !mine) {
      action = 'apply';
      label = s.courierAccept;
    }
    if (p.status == StatusOrder.assigned && mine) {
      action = 'collect';
      label = s.courierCollect;
    }
    if (p.status == StatusOrder.taken && mine) {
      action = 'deliver';
      label = s.courierDeliver;
    }
    final target = p.status == StatusOrder.taken ? p.location : p.start;
    return Scaffold(
      appBar: AppBar(
        title: Text('#${p.id}'),
        actions: [
          IconButton(
            tooltip: s.courierRefresh,
            onPressed: busy ? null : () => c.refreshDelivery(p),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await c.refreshDelivery(p);
          },
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              CourierError(c.error),
              Text(courierStatus(s, p), style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                courierMoney(mine ? p.deliverymanProfit : p.estimatedProfit),
                style: theme.textTheme.displaySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(s.courierGain, style: theme.textTheme.bodySmall),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CourierStop(
                        label: s.courierPickup,
                        title: p.store.name,
                        address: p.store.address,
                        icon: Icons.storefront_outlined,
                        distance: p.pickupDistanceMeters,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(),
                      ),
                      CourierStop(
                        label: s.courierDropoff,
                        title: p.user.fullName,
                        address: p.address,
                        icon: Icons.location_on_outlined,
                        distance: p.tripDistanceMeters,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(s.courierApprox, style: theme.textTheme.bodySmall),
              if (active) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => _open(
                    Uri.parse(
                      'https://www.google.com/maps/dir/?api=1&destination=${target.x},${target.y}',
                    ),
                  ),
                  icon: const Icon(Icons.near_me_outlined),
                  label: Text(s.courierRoute),
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    if (p.user.phone.toString().isNotEmpty)
                      TextButton.icon(
                        onPressed: () => _open(
                          Uri(scheme: 'tel', path: p.user.phone.toString()),
                        ),
                        icon: const Icon(Icons.call_outlined),
                        label: Text(s.courierCall + ' · ' + s.courierDropoff),
                      ),
                    if (p.store.contact.isNotEmpty)
                      TextButton.icon(
                        onPressed: () =>
                            _open(Uri(scheme: 'tel', path: p.store.contact)),
                        icon: const Icon(Icons.storefront_outlined),
                        label: Text(s.courierCall + ' · ' + s.courierPickup),
                      ),
                    TextButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            myRol: TypesRol.deliveryman,
                            chatModel: ChatModel(
                              orderId: p.id,
                              label: p.store.name,
                              imageCompany: p.store.company.image,
                              toUser: ToUser(
                                id: p.user.id,
                                fullName: p.user.fullName,
                                image: p.user.image,
                              ),
                            ),
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: Text(s.courierChat),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              Text(s.courierProducts, style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              for (final product in p.products)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    '${product.number} × ${product.name}' +
                        (product.note.isEmpty ? '' : ' · ${product.note}'),
                  ),
                ),
              if (p.note.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(p.note),
              ],
              const Divider(height: 32),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Text(
                    s.courierTotal + ': ' + courierMoney(p.total),
                    style: theme.textTheme.titleMedium,
                  ),
                  Chip(
                    label: Text(
                      p.payment == TypesPayment.cash
                          ? s.courierCash
                          : s.courierPaid,
                    ),
                  ),
                ],
              ),
              if (p.status == StatusOrder.assigned && !canCollect) ...[
                const SizedBox(height: 16),
                Text(s.courierPreparing),
              ],
              if (p.status == StatusOrder.assigned && mine)
                TextButton(
                  onPressed: busy
                      ? null
                      : () async {
                          if (await _confirm(
                            s.courierCancel,
                            s.courierCancelMessage,
                            s.courierCancel,
                          )) {
                            await c.act(p, 'cancel');
                          }
                        },
                  child: Text(s.courierCancel),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: action == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: FilledButton(
                  key: const ValueKey('courier-primary'),
                  onPressed: busy || (action == 'collect' && !canCollect)
                      ? null
                      : () async {
                          if (action == 'deliver' &&
                              !await _confirm(
                                s.courierConfirmTitle,
                                (p.payment == TypesPayment.cash
                                        ? s.courierConfirmCash
                                        : s.courierConfirmPaid) +
                                    '\n\n' +
                                    s.courierTotal +
                                    ': ' +
                                    courierMoney(p.total),
                                label!,
                              ))
                            return;
                          await c.act(p, action!);
                        },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: busy
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(label!),
                  ),
                ),
              ),
            ),
    );
  }
}
