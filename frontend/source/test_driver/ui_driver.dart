import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() => integrationDriver(
  onScreenshot: (name, bytes, [args]) async {
    await Directory('.tools/ui-review').create(recursive: true);
    await File('.tools/ui-review/$name.png').writeAsBytes(bytes);
    return true;
  },
);
