import 'package:flutter/material.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/screens/recover/recover_controller.dart';
import 'package:planck/src/screens/recover/widget/email_input.dart';
import 'package:planck/src/screens/recover/widget/recover_button.dart';
import 'package:planck/src/widgets/forms/form_page.dart';
import 'package:provider/provider.dart';

class RecoverScreen extends StatelessWidget {
  RecoverScreen({super.key});
  final _form = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => RecoverController(),
    child: Consumer<RecoverController>(
      builder: (context, c, _) => FormPage(
        title: S.of(context).bRecoverAccount,
        formKey: _form,
        busy: c.inAsyncCall,
        footer: RecoverButton(c, formKey: _form),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Image.asset('assets/screen/recover.png', height: 160),
            ),
            const SizedBox(height: 28),
            EmailInput(c),
          ],
        ),
      ),
    ),
  );
}
