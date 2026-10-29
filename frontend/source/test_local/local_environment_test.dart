import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:planck/constants/constants.dart';
import 'package:planck/src/common/file_helper.dart';
import 'package:planck/src/provider/push_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'local notifications provider works without initializing a Firebase app',
    () async {
      expect(kExternalServicesEnabled, isFalse);
      final provider = PushProvider();
      await provider.getToken();
      await provider.dispose();
    },
  );
  test(
    'local image uploads fail gracefully before accessing Firebase',
    () async {
      expect(kExternalServicesEnabled, isFalse);
      expect(
        await uploadFile(
          File('unused-local-fixture'),
          'fixtures',
          'image.jpg',
          32,
        ),
        '',
      );
    },
  );
}
