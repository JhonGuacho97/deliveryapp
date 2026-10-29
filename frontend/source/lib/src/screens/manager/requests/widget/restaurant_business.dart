import 'package:flutter/material.dart';
import 'package:planck/src/widgets/forms/form_fields.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/screens/manager/company/company_controller.dart';
import 'package:planck/src/screens/manager/hours/hours_screen.dart';
import 'package:planck/src/widgets/empty_state.dart';
import 'package:provider/provider.dart';

class RestaurantStorePicker extends StatelessWidget {
  const RestaurantStorePicker({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CompanyController>();
    if (controller.companies.length < 2)
      return Text(
        controller.selected?.name ?? '',
        style: Theme.of(context).textTheme.titleMedium,
      );
    return FormFieldLabel(
      label: S.of(context).chooseStore,
      child: DropdownButtonFormField<int>(
        initialValue: controller.selected?.id,
        decoration: const InputDecoration(),
        isExpanded: true,
        items: controller.companies
            .map(
              (store) => DropdownMenuItem(
                value: store.id,
                child: Text(
                  store.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
        onChanged: (id) {
          if (id != null) controller.select(id);
        },
      ),
    );
  }
}

class RestaurantStoresState extends StatelessWidget {
  const RestaurantStoresState({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CompanyController>();
    final s = S.of(context);
    if (controller.inAsyncCall)
      return const Center(child: CircularProgressIndicator());
    return SingleChildScrollView(
      child: EmptyState(
        icon: controller.hasError
            ? Icons.wifi_off_outlined
            : Icons.storefront_outlined,
        title: controller.hasError ? s.catalogErrorTitle : s.managerStoresEmpty,
        message: controller.hasError
            ? s.catalogErrorMessage
            : s.managerStoresEmptyMessage,
        actionLabel: controller.hasError ? s.retry : null,
        onAction: controller.hasError ? controller.load : null,
      ),
    );
  }
}

class RestaurantBusiness extends StatelessWidget {
  const RestaurantBusiness({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CompanyController>();
    final store = controller.selected;
    final s = S.of(context);
    final theme = Theme.of(context);
    if (store == null || controller.hasError)
      return const RestaurantStoresState();
    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          const RestaurantStorePicker(),
          const SizedBox(height: 24),
          Text(s.businessDetails, style: theme.textTheme.titleSmall),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(store.address),
                ),
                ListTile(
                  leading: const Icon(Icons.call_outlined),
                  title: Text(store.contact),
                ),
                ListTile(
                  leading: const Icon(Icons.mail_outline_rounded),
                  title: Text(store.email),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            icon: const Icon(Icons.schedule_rounded),
            label: Text(s.manageHours),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HoursScreen(
                  storeCompany: store,
                  service: controller.service,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
