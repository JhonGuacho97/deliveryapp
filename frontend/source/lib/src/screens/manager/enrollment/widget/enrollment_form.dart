import 'package:flutter/material.dart';
import 'package:planck/constants/constants.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/common/file_helper.dart';
import 'package:planck/src/screens/manager/enrollment/enrollment_controller.dart';
import 'package:planck/src/screens/manager/enrollment/widget/address_input.dart';
import 'package:planck/src/screens/manager/enrollment/widget/contact_input.dart';
import 'package:planck/src/screens/manager/enrollment/widget/email_input.dart';
import 'package:planck/src/screens/manager/enrollment/widget/name_input.dart';
import 'package:planck/src/screens/manager/enrollment/widget/save_button.dart';
import 'package:planck/src/widgets/avatar_image.dart';
import 'package:planck/src/widgets/category_dropdown/category_dropdown.dart';
import 'package:planck/src/widgets/forms/form_page.dart';
import 'package:planck/src/widgets/upload_file/upload_file.dart';
import 'package:provider/provider.dart';

class EnrollmentForm extends StatelessWidget {
  EnrollmentForm({super.key});
  final _form = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final c = context.watch<EnrollmentController>(),
        s = S.of(context),
        theme = Theme.of(context);
    return FormPage(
      title: s.tRegisterStore,
      formKey: _form,
      busy: c.inAsyncCall,
      footer: SaveButton(formKey: _form, enrollmentController: c),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: 96,
                height: 96,
                child: c.enrollment.image.isEmpty
                    ? ColoredBox(
                        color: theme.colorScheme.surfaceContainerLow,
                        child: const Icon(Icons.storefront_outlined, size: 32),
                      )
                    : AvatarImage(width: 96, image: c.enrollment.image),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => UploadFile((image) async {
                  c.inAsyncCall = true;
                  final url = await uploadFile(
                    image,
                    'company',
                    '${DateTime.now().millisecondsSinceEpoch}',
                    kTargetWidthStore,
                  );
                  if (url.isNotEmpty) c.enrollment.image = url;
                  c.inAsyncCall = false;
                }),
              ),
              child: Text(s.bSelectPhoto),
            ),
          ),
          const SizedBox(height: 28),
          CategoryDropdown(c.category),
          const SizedBox(height: 22),
          NameInput(enrollmentController: c),
          const SizedBox(height: 22),
          ContactInput(enrollmentController: c),
          const SizedBox(height: 22),
          EmailInput(enrollmentController: c),
          const SizedBox(height: 22),
          AddressInput(enrollmentController: c),
        ],
      ),
    );
  }
}
