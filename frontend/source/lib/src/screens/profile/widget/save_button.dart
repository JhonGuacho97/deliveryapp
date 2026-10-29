import 'package:flutter/material.dart';
import 'package:planck/constants/code_error_constant.dart';
import 'package:planck/constants/constants.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/screens/profile/profile_controller.dart';
import 'package:planck/src/widgets/primary_button.dart';

class ProfileButton extends StatelessWidget {
  const ProfileButton(
    this.profileController, {
    super.key,
    required GlobalKey<FormState> formKey,
  }) : _formKey = formKey;
  final ProfileController profileController;
  final GlobalKey<FormState> _formKey;

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      text: S.of(context).bSaveChanges,
      onPressed: !profileController.hasChanges || profileController.inAsyncCall
          ? null
          : () async {
              if (profileController.inAsyncCall) return;
              FocusScope.of(context).unfocus();
              if (!_formKey.currentState!.validate()) return;
              _formKey.currentState!.save();

              final s = S.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              if (profileController.phone.length <= 6) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    backgroundColor: kErrorColor,
                    content: Text(S.of(context).errPhoneNumberAgain),
                  ),
                );
                return;
              }

              final codeError = await profileController.update();
              String? error;

              switch (codeError) {
                case CodeError.none:
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      backgroundColor: kPrimaryColor,
                      duration: const Duration(milliseconds: 4500),
                      content: Text(s.mRChangesMadeCorrectly),
                    ),
                  );
                  break;
                case CodeError.unknown:
                  error = s.errUnknown;
                  break;
                case CodeError.emailUnique:
                  error = s.errEmailUnique(profileController.email);
                  break;
                case CodeError.phoneUnique:
                  error = s.errPhoneUnique(profileController.phone);
                  break;
                default:
              }

              if (error != null) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    backgroundColor: kErrorColor,
                    duration: const Duration(milliseconds: 4500),
                    content: Text(error),
                  ),
                );
              }
            },
    );
  }
}
