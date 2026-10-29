import 'package:flutter/material.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/models/store_company_model.dart';
import 'package:delivery_app/src/screens/manager/hours/hours_controller.dart';
import 'package:delivery_app/src/screens/manager/hours/widget/hours_card.dart';
import 'package:delivery_app/src/services/store_manager_service.dart';
import 'package:delivery_app/src/widgets/empty_state.dart';
import 'package:provider/provider.dart';

class HoursScreen extends StatelessWidget {
  const HoursScreen({super.key, required this.storeCompany, this.service});
  final StoreCompanyModel storeCompany;
  final StoreManagerService? service;
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => HoursController(storeCompany, service: service),
    child: Consumer<HoursController>(
      builder: (context, controller, _) => Scaffold(
        appBar: AppBar(title: Text(S.of(context).manageHours)),
        body: RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                storeCompany.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              if (controller.inAsyncCall)
                const LinearProgressIndicator(minHeight: 2),
              if (controller.hasError ||
                  (!controller.inAsyncCall && controller.hours.isEmpty))
                EmptyState(
                  icon: Icons.schedule_rounded,
                  title: controller.hasError
                      ? S.of(context).catalogErrorTitle
                      : S.of(context).manageHours,
                  message: controller.hasError
                      ? S.of(context).catalogErrorMessage
                      : S.of(context).hoursEmpty,
                  actionLabel: controller.hasError ? S.of(context).retry : null,
                  onAction: controller.hasError ? controller.load : null,
                ),
              for (final hour in controller.hours)
                HoursCard(controller, hour: hour),
            ],
          ),
        ),
      ),
    ),
  );
}
