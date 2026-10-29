import 'package:flutter/material.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/models/request_model.dart';
import 'package:planck/src/screens/manager/requests/requests_controller.dart';
import 'package:planck/src/screens/manager/requests/widget/list_requests.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class RequestScreen extends StatelessWidget {
  const RequestScreen(this.request, {super.key});
  final RequestModel request;
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RequestsController>();
    final current =
        controller.requests
            .where((value) => value.id == request.id)
            .firstOrNull ??
        request;
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).orderNumber(current.id))),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshOne(current),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            RestaurantOrderCard(request: current, detail: true),
            const SizedBox(height: 16),
            if (current.user.phone.isNotEmpty && current.user.phone != 's/n')
              OutlinedButton.icon(
                icon: const Icon(Icons.call_outlined),
                label: Text(current.user.phone),
                onPressed: () =>
                    launchUrl(Uri(scheme: 'tel', path: current.user.phone)),
              ),
            OutlinedButton.icon(
              icon: const Icon(Icons.location_on_outlined),
              label: Text(S.of(context).viewLocation),
              onPressed: () => launchUrl(
                Uri.https('www.google.com', '/maps/search/', {
                  'api': '1',
                  'query': '${current.location.x},${current.location.y}',
                }),
                mode: LaunchMode.externalApplication,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
