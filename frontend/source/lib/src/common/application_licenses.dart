import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

void registerApplicationLicenses() {
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(const [
      'Delivery App - frontend base',
    ], await rootBundle.loadString('lib/LICENSE'));
    yield LicenseEntryWithLineBreaks(const [
      'Inter',
    ], await rootBundle.loadString('assets/fonts/OFL.txt'));
  });
}
