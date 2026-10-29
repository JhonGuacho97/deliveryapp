import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:delivery_app/constants/preparation_status.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/screens/manager/requests/requests_controller.dart';
import 'package:delivery_app/src/screens/manager/requests/widget/list_requests.dart';
import 'package:delivery_app/src/widgets/empty_state.dart';
import 'package:provider/provider.dart';

class ContentRequests extends StatelessWidget {
  const ContentRequests({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RequestsController>();
    final s = S.of(context);
    final theme = Theme.of(context);
    final stages = {
      PreparationStatus.pending: s.newOrders,
      PreparationStatus.preparing: s.preparingOrders,
      PreparationStatus.ready: s.readyOrders,
      PreparationStatus.dispatched: s.dispatchedOrders,
    };
    return RefreshIndicator(
      onRefresh: () => controller.loadRequests(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (controller.inAsyncCall)
            const SliverToBoxAdapter(
              child: LinearProgressIndicator(minHeight: 2),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.kitchenSubtitle, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 20),
                  if (controller.showHistory)
                    OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today_outlined),
                      label: Text(
                        DateFormat.yMMMd(
                          Localizations.localeOf(context).toString(),
                        ).format(controller.selectedDay),
                      ),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: controller.selectedDay,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) controller.selectedDay = date;
                      },
                    )
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: stages.entries
                            .map(
                              (entry) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(
                                    '${entry.value} · ${controller.count(entry.key)}',
                                  ),
                                  selected: controller.stage == entry.key,
                                  showCheckmark: false,
                                  onSelected: (_) =>
                                      controller.stage = entry.key,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (controller.hasError)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.wifi_off_outlined,
                title: s.kitchenErrorTitle,
                message: s.catalogErrorMessage,
                actionLabel: s.retry,
                onAction: () => controller.loadRequests(),
              ),
            )
          else if (controller.visibleRequests.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: controller.inAsyncCall
                  ? const Center(child: CircularProgressIndicator())
                  : EmptyState(
                      icon: Icons.task_alt_rounded,
                      title: s.kitchenEmptyTitle,
                      message: s.kitchenEmptyMessage,
                    ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.builder(
                itemCount: controller.visibleRequests.length,
                itemBuilder: (_, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: RestaurantOrderCard(
                    key: ValueKey(controller.visibleRequests[index].id),
                    request: controller.visibleRequests[index],
                  ),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: SizedBox(height: 24 + MediaQuery.paddingOf(context).bottom),
          ),
        ],
      ),
    );
  }
}
