import 'package:flutter/material.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/screens/admin/credit/credit_controller.dart';
import 'package:planck/src/screens/admin/credit/widget/amount_input.dart';
import 'package:planck/src/screens/admin/credit/widget/phone_input.dart';
import 'package:planck/src/screens/admin/credit/widget/top_up_balance_button.dart';
import 'package:planck/src/widgets/forms/form_page.dart';
import 'package:provider/provider.dart';

class CreditScreen extends StatelessWidget {
  CreditScreen({super.key});
  final _form = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => CreditController(),
    child: Consumer<CreditController>(
      builder: (context, c, _) => FormPage(
        title: S.of(context).tTopUpBalance,
        formKey: _form,
        busy: c.inAsyncCall,
        footer: TopUpBalanceButton(c, formKey: _form),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [PhoneInput(c), const SizedBox(height: 22), AmountInput(c)],
        ),
      ),
    ),
  );
}
