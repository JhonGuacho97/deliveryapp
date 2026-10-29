import 'package:flutter/material.dart';
import 'package:delivery_app/src/common/launch.dart';
import 'package:delivery_app/src/models/notification_model.dart';
import 'package:delivery_app/src/screens/notification/widget/info_notifications.dart';
import 'package:delivery_app/src/widgets/avatar_image.dart';

class ListNotifications extends StatelessWidget {
  final List<NotificationModel> notifications;

  const ListNotifications(this.notifications, {super.key}) ;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) => _Notification(notifications[index]),
    );
  }
}

class _Notification extends StatelessWidget {
  final NotificationModel notification;
  final double height = 150;

  const _Notification(this.notification);

  @override
  Widget build(BuildContext context) {
    final card = SizedBox(
      height: height,
      child: Card(
        elevation: 2.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Row(
          children: <Widget>[
            AvatarImage(image: notification.image),
            InfoNotifications(height: height, notification: notification),
          ],
        ),
      ),
    );
    return Stack(
      children: <Widget>[
        card,
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
                splashColor: Colors.blueAccent.withValues(alpha: 0.6),
                onTap: () {
                  goToUrl(notification.url);
                }),
          ),
        ),
      ],
    );
  }
}
