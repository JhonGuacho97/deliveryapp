import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:delivery_app/constants/constants.dart';
import 'package:delivery_app/constants/preparation_status.dart';
import 'package:delivery_app/src/common/status_label.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/models/request_model.dart';
import 'package:delivery_app/src/screens/manager/request/request_screen.dart';
import 'package:delivery_app/src/screens/manager/requests/requests_controller.dart';
import 'package:provider/provider.dart';

class ListRequests extends StatelessWidget {
  const ListRequests(this.requests, {super.key});
  final List<RequestModel> requests;
  @override
  Widget build(BuildContext context) => ListView.builder(
    itemCount: requests.length,
    itemBuilder: (_, index) => RestaurantOrderCard(request: requests[index]),
  );
}

class RestaurantOrderCard extends StatefulWidget {
  const RestaurantOrderCard({
    super.key,
    required this.request,
    this.detail = false,
  });
  final RequestModel request;
  final bool detail;
  @override
  State<RestaurantOrderCard> createState() => _RestaurantOrderCardState();
}

class _RestaurantOrderCardState extends State<RestaurantOrderCard> {
  int minutes = 25;
  Future<void> _action(bool accepting) async {
    final controller = context.read<RequestsController>();
    final messenger = ScaffoldMessenger.of(context);
    final s = S.of(context);
    final success = accepting
        ? await controller.accept(widget.request.id, minutes)
        : await controller.ready(widget.request.id);
    if (!messenger.mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (accepting ? s.orderAccepted : s.orderReady)
              : controller.actionErrorCode == 409 ||
                    controller.actionErrorCode == 404
              ? s.kitchenConflict
              : s.kitchenActionError,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final controller = context.watch<RequestsController>();
    final theme = Theme.of(context);
    final s = S.of(context);
    final stage = RequestsController.stageOf(request);
    final label = stage == PreparationStatus.dispatched
        ? statusOrderLabel(request.status, request.store.company.type)
        : stage == PreparationStatus.preparing
        ? s.preparingOrders
        : stage == PreparationStatus.ready
        ? s.readyOrders
        : s.newOrders;
    final editable =
        RequestsController.editable(request) && !controller.showHistory;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 12,
              runSpacing: 8,
              children: [
                Text(
                  s.orderNumber(request.id),
                  style: theme.textTheme.titleMedium,
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: Text(
                      label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${request.store.name} · ${DateFormat.Hm().format(request.createdAt.toLocal())}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 18),
            for (final product in request.products) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '${product.number} × ${product.name}',
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${product.total.toStringAsFixed(kCoinDecimals)} $kCoin',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              if (product.note.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.edit_note_rounded, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            product.note,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),
            ],
            if (widget.detail) ...[
              const Divider(),
              Text(request.user.fullName, style: theme.textTheme.titleSmall),
              const SizedBox(height: 6),
              Text(request.address, style: theme.textTheme.bodySmall),
              const SizedBox(height: 12),
              Text(
                '${s.lTotal} · ${request.total.toStringAsFixed(kCoinDecimals)} $kCoin',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
            ],
            if (editable && stage == PreparationStatus.pending) ...[
              const SizedBox(height: 8),
              Text(s.preparationTime, style: theme.textTheme.bodySmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [15, 25, 35]
                    .map(
                      (value) => ChoiceChip(
                        label: Text(s.preparationMinutesLabel(value)),
                        selected: minutes == value,
                        showCheckmark: false,
                        onSelected: controller.isBusy(request.id)
                            ? null
                            : (_) => setState(() => minutes = value),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              FilledButton(
                key: ValueKey('accept-${request.id}'),
                onPressed: controller.isBusy(request.id)
                    ? null
                    : () => _action(true),
                child: Text(s.acceptOrder),
              ),
            ] else if (editable && stage == PreparationStatus.preparing) ...[
              if (request.preparationMinutes != null)
                Text(
                  s.kitchenPrepEstimate(request.preparationMinutes!),
                  style: theme.textTheme.bodySmall,
                ),
              const SizedBox(height: 16),
              FilledButton(
                key: ValueKey('ready-${request.id}'),
                onPressed: controller.isBusy(request.id)
                    ? null
                    : () => _action(false),
                child: Text(s.markReady),
              ),
            ] else if (stage == PreparationStatus.ready)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(s.orderReady, style: theme.textTheme.bodySmall),
              ),
            if (controller.isBusy(request.id))
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: LinearProgressIndicator(minHeight: 2),
              ),
            if (!widget.detail)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RequestScreen(request)),
                  ),
                  child: Text(s.orderDetails),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
