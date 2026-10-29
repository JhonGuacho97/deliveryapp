import 'package:flutter/material.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/models/hour_model.dart';
import 'package:planck/src/screens/manager/hours/hours_controller.dart';

class HoursCard extends StatelessWidget {
  const HoursCard(this.hoursController, {super.key, required this.hour});
  final HoursController hoursController;
  final HourModel hour;
  Future<void> _edit(BuildContext context, bool opening) async {
    final s = S.of(context);
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: opening ? hour.openHour : hour.closeHour,
        minute: opening ? hour.openMinute : hour.closeMinute,
      ),
      initialEntryMode: TimePickerEntryMode.input,
      helpText: opening ? s.editOpening : s.editClosing,
    );
    if (time == null) return;
    final draft = HourModel.fromJson(hour.toJson());
    final value =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
    if (opening)
      draft.open = value;
    else
      draft.close = value;
    final saved = await hoursController.updateHour(draft);
    if (context.mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(saved ? s.scheduleUpdated : s.kitchenActionError),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hour.date(context),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: hoursController.isBusy(hour.id)
                        ? null
                        : () => _edit(context, true),
                    child: Text(hour.open.substring(0, 5)),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Icon(Icons.arrow_forward_rounded, size: 18),
                  ),
                  OutlinedButton(
                    onPressed: hoursController.isBusy(hour.id)
                        ? null
                        : () => _edit(context, false),
                    child: Text(hour.close.substring(0, 5)),
                  ),
                ],
              ),
              if (hoursController.isBusy(hour.id))
                const LinearProgressIndicator(minHeight: 2),
            ],
          ),
        ),
      ),
    );
  }
}
