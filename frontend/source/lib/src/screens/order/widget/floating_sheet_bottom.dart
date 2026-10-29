import 'package:flutter/material.dart';
import 'package:planck/constants/constants.dart';
import 'package:planck/constants/status_constant.dart';
import 'package:planck/constants/types_constant.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/models/chat_model.dart';
import 'package:planck/src/screens/chat/chat_screen.dart';
import 'package:planck/src/screens/main/tab2_controller.dart';
import 'package:planck/src/screens/order/order_controller.dart';
import 'package:planck/src/screens/order/widget/info_product.dart';
import 'package:planck/src/screens/order/widget/order_progress.dart';
import 'package:planck/src/widgets/avatar_image.dart';
import 'package:planck/src/widgets/sheet_chat_icon.dart';
import 'package:provider/provider.dart';

class FloatingSheetBottom extends StatelessWidget {
  final OrderController orderController;

  const FloatingSheetBottom({super.key, required this.orderController});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.3,
      maxChildSize: 1,
      snap: true,
      snapSizes: const [0.7, 1],
      builder: (context, scrollController) => Container(
        padding: const EdgeInsets.only(top: 0, right: 10, left: 10, bottom: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Center(
                child: SizedBox(width: 60, child: Divider(thickness: 5)),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  SizedBox(
                    width: 80,
                    child:
                        orderController.order.status >= StatusOrder.assigned &&
                            orderController.order.status <= StatusOrder.taken
                        ? IconChat(orderController)
                        : Container(),
                  ),
                  SizedBox(
                    height: 70,
                    child: ClipOval(
                      child: AvatarImage(
                        image: orderController.order.store.company.image,
                      ),
                    ),
                  ),
                  const SizedBox(width: 80),
                ],
              ),
              const SizedBox(height: 20),
              OrderProgress(
                status: orderController.order.status,
                preparationStatus: orderController.order.preparationStatus,
                preparationMinutes: orderController.order.preparationMinutes,
                companyType: orderController.order.store.company.type,
              ),
              const Divider(),
              Row(
                children: <Widget>[
                  Icon(
                    orderController.order.payment == TypesPayment.money
                        ? Icons.credit_score_outlined
                        : Icons.payments_outlined,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: kDefaultPadding * 0.5),
                  Flexible(
                    child: Text(
                      orderController.order.payment == TypesPayment.money
                          ? S.of(context).lPayMoney
                          : S.of(context).lPayCash,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Expanded(child: Container()),
                  Expanded(child: Container()),
                  Flexible(
                    child: Text(
                      '${S.of(context).lTotal} ${orderController.order.total.toStringAsFixed(kCoinDecimals)} $kCoin',
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              const SizedBox(height: 10),
              InfoProduct(order: orderController.order),
            ],
          ),
        ),
      ),
    );
  }
}

class IconChat extends StatelessWidget {
  const IconChat(this.orderController, {super.key});

  final OrderController orderController;

  @override
  Widget build(BuildContext context) {
    return SheetChatIcon(
      notifications: orderController.order.notificationsClient,
      goToChatScreen: _goToChatScreen,
    );
  }

  _goToChatScreen(BuildContext context) {
    orderController.cleanNotificationsClient();
    Provider.of<Tab2Controller>(
      context,
      listen: false,
    ).cleanNotificationsClient(orderController.order.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatModel: ChatModel(
            orderId: orderController.order.id,
            toUser: ToUser.fromJson(
              orderController.order.deliveryman!.toJson(),
            ),
            label: S.of(context).lDeliveryman,
            imageCompany: orderController.order.store.company.image,
          ),
          myRol: TypesRol.client,
        ),
      ),
    );
  }
}
