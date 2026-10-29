import 'package:flutter/material.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/provider/preferences_provider.dart';
import 'package:planck/src/screens/manager/company/company_controller.dart';
import 'package:planck/src/screens/manager/company/widget/company_card.dart';
import 'package:provider/provider.dart';

class CompanyScreen extends StatelessWidget {
  CompanyScreen({super.key});

  final pref = PreferencesProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).tStores)),
      body: ChangeNotifierProvider<CompanyController>.value(
        value: CompanyController(),
        child: Consumer<CompanyController>(
          builder: (context, storeCompanyController, child) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Visibility(
                  visible: storeCompanyController.inAsyncCall,
                  child: const LinearProgressIndicator()),
              Expanded(
                child: ListView.builder(
                  itemCount: storeCompanyController.companies.length,
                  itemBuilder: (context, index) => CompanyCard(
                      storeCompanyController,
                      storeCompany: storeCompanyController.companies[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
