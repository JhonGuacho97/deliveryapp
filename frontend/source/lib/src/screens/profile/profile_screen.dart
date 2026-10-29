import 'package:flutter/material.dart';
import 'package:delivery_app/constants/constants.dart';
import 'package:delivery_app/constants/types_constant.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/bloc/location_bloc.dart';
import 'package:delivery_app/src/common/file_helper.dart';
import 'package:delivery_app/src/provider/preferences_provider.dart';
import 'package:delivery_app/src/screens/profile/profile_controller.dart';
import 'package:delivery_app/src/screens/profile/widget/amount_input.dart';
import 'package:delivery_app/src/screens/profile/widget/balance_input.dart';
import 'package:delivery_app/src/screens/profile/widget/change_password_button.dart';
import 'package:delivery_app/src/screens/profile/widget/email_input.dart';
import 'package:delivery_app/src/screens/profile/widget/name_input.dart';
import 'package:delivery_app/src/screens/profile/widget/phone_input.dart';
import 'package:delivery_app/src/screens/profile/widget/save_button.dart';
import 'package:delivery_app/src/screens/welcome/welcome_screen.dart';
import 'package:delivery_app/src/widgets/confirmation_dialog.dart';
import 'package:delivery_app/src/widgets/forms/form_page.dart';
import 'package:delivery_app/src/widgets/money_input.dart';
import 'package:delivery_app/src/widgets/upload_file/upload_file.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.controller});
  final ProfileController? controller;
  @override
  Widget build(BuildContext context) => controller == null
      ? ChangeNotifierProvider(
          create: (_) => ProfileController(),
          child: const _ProfileForm(),
        )
      : ChangeNotifierProvider.value(
          value: controller!,
          child: const _ProfileForm(),
        );
}

class _ProfileForm extends StatefulWidget {
  const _ProfileForm();
  @override
  State<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<_ProfileForm> {
  final _form = GlobalKey<FormState>();
  final _prefs = PreferencesProvider();
  Future<void> _editImage(ProfileController controller) async {
    await showDialog(
      context: context,
      builder: (_) => UploadFile((image) async {
        controller.inAsyncCall = true;
        final url = await uploadFile(
          image,
          'user/${_prefs.user.id}',
          '${_prefs.user.id}-${DateTime.now().millisecondsSinceEpoch}',
          kTargetWidthUser,
        );
        if (url.isNotEmpty)
          await controller.changeImage(url);
        else
          controller.inAsyncCall = false;
        if (mounted && url.isEmpty)
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(S.of(context).errUnknown)));
      }),
    );
  }

  Future<void> _logout(ProfileController controller) async {
    final navigator = Navigator.of(context),
        messenger = ScaffoldMessenger.of(context),
        s = S.of(context);
    if (!await controller.logOut() && !_prefs.isGuest) {
      messenger.showSnackBar(SnackBar(content: Text(s.errUnknown)));
      return;
    }
    if (_prefs.user.roles.contains(TypesRol.deliveryman))
      await LocationBloc().stop();
    await _prefs.clean();
    if (mounted)
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (_) => false,
      );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProfileController>(),
        s = S.of(context),
        theme = Theme.of(context),
        user = _prefs.user;
    final initials = user.fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((n) => n.isNotEmpty)
        .take(2)
        .map((n) => n[0])
        .join()
        .toUpperCase();
    final image = user.image;
    final hasImage =
        image.isNotEmpty &&
        image != kImageClientDefault &&
        image != kImageDeliveryManDefault;
    final placeholder = Text(initials, style: theme.textTheme.titleLarge);
    return FormPage(
      title: s.editProfile,
      formKey: _form,
      busy: controller.inAsyncCall,
      onChanged: controller.markChanged,
      actions: [
        IconButton(
          tooltip: s.signOut,
          onPressed: () => showDialog(
            context: context,
            builder: (_) => ConfirmationDialog(
              s.mDLogoutSession,
              labelOk: s.signOut,
              iconOk: const Icon(Icons.logout_rounded),
              onPressedOk: () => _logout(controller),
            ),
          ),
          icon: const Icon(Icons.logout_rounded, size: 22),
        ),
      ],
      footer: ProfileButton(controller, formKey: _form),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Center(
            child: CircleAvatar(
              radius: 46,
              backgroundColor: theme.colorScheme.surfaceContainerLow,
              child: hasImage
                  ? ClipOval(
                      child: Image.network(
                        image,
                        width: 92,
                        height: 92,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => placeholder,
                      ),
                    )
                  : placeholder,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton(
              onPressed: kExternalServicesEnabled
                  ? () => _editImage(controller)
                  : null,
              child: Text(s.editImage),
            ),
          ),
          const SizedBox(height: 32),
          NameInput(controller),
          const SizedBox(height: 22),
          EmailInput(controller),
          const SizedBox(height: 22),
          PhoneInput(controller),
          const SizedBox(height: 28),
          if (controller.balanceAvailable) ...[
            if (user.roles.contains(TypesRol.deliveryman)) ...[
              BalanceInput(controller.balance.balance),
              const SizedBox(height: 12),
              AmountInput(controller.balance.amount),
            ] else
              MoneyInput(controller.balance.money),
            const SizedBox(height: 20),
          ],
          ChangePasswordButton(controller),
        ],
      ),
    );
  }
}
