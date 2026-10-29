import 'package:flutter/material.dart';
import 'package:delivery_app/constants/status_constant.dart';
import 'package:delivery_app/constants/preparation_status.dart';
import 'package:delivery_app/constants/types_constant.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/common/status_label.dart';

class OrderProgress extends StatelessWidget {
  const OrderProgress({
    super.key,
    required this.status,
    required this.companyType,
    this.preparationStatus,
    this.preparationMinutes,
  });
  final int status;
  final int companyType;
  final String? preparationStatus;
  final int? preparationMinutes;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    if (companyType != TypesCompany.store || status == StatusOrder.cancelled) {
      return Text(
        statusOrderLabel(status, companyType),
        style: theme.textTheme.titleSmall,
      );
    }
    final stages = [
      StatusOrder.started,
      StatusOrder.assigned,
      StatusOrder.taken,
      StatusOrder.delivered,
    ];
    final labels = [
      s.orderReceived,
      s.orderAssigned,
      s.orderOnTheWay,
      s.orderCompleted,
    ];
    final current = status == StatusOrder.qualified
        ? 3
        : stages.indexOf(status);
    if (current < 0) return Text(statusOrderLabel(status, companyType));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(s.orderProgress, style: theme.textTheme.titleSmall),
        if (preparationStatus != null && status < StatusOrder.taken) ...[
          const SizedBox(height: 12),
          Text(
            preparationStatus == PreparationStatus.pending
                ? s.kitchenPendingClient
                : preparationStatus == PreparationStatus.preparing
                ? s.kitchenPreparingClient
                : preparationStatus == PreparationStatus.ready
                ? s.kitchenReadyClient
                : s.legacyKitchen,
            style: theme.textTheme.bodySmall,
          ),
          if (preparationStatus == PreparationStatus.preparing &&
              preparationMinutes != null)
            Text(
              s.kitchenPrepEstimate(preparationMinutes!),
              style: theme.textTheme.bodySmall,
            ),
        ],
        const SizedBox(height: 12),
        for (var i = 0; i < stages.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Icon(
                  i <= current
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 20,
                  color: i <= current
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    labels[i],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: i == current
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: i == current
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
