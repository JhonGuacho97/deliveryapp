import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as images;
import 'package:mocktail/mocktail.dart';
import 'package:planck/src/common/file_helper.dart';

class _Storage extends Mock implements FirebaseStorage {}

class _Reference extends Mock implements Reference {}

class _Snapshot extends Mock implements TaskSnapshot {}

class _Task extends Fake implements UploadTask {
  @override
  Future<TaskSnapshot> whenComplete(FutureOr<void> Function() action) async {
    await action();
    return _Snapshot();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(SettableMetadata());
    registerFallbackValue(File('fixture'));
  });
  late Directory directory;
  late File image;
  late _Reference reference;
  late _Storage storage;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'delivery-image-migration-',
    );
    image = await File('${directory.path}/original.png')
        .writeAsBytes(images.encodePng(images.Image(width: 12, height: 20)));
    reference = _Reference();
    storage = _Storage();
    when(() => storage.ref('fixtures')).thenReturn(reference);
    when(() => reference.child('image.jpg')).thenReturn(reference);
    when(() => reference.putData(any(), any())).thenAnswer((_) => _Task());
    when(() => reference.putFile(any())).thenAnswer((_) => _Task());
    when(() => reference.getDownloadURL()).thenAnswer(
      (_) async => 'https://example.test/image.jpg?alt=media&token=fixture-resource-token',
    );
  });
  tearDown(() async {
    expect(
      directory.absolute.path,
      startsWith(Directory.systemTemp.absolute.path),
    );
    await directory.delete(recursive: true);
  });

  test(
    'resizes and crops the upload and preserves its valid download URL',
    () async {
      final url = await uploadFile(
        image,
        'fixtures',
        'image.jpg',
        32,
        storage: storage,
      );
      expect(url, contains('token=fixture-resource-token'));
      final captured = verify(
        () => reference.putData(captureAny(), captureAny()),
      ).captured;
      final decoded = images.decodeJpg(captured.first as Uint8List)!;
      expect(decoded.width, 32);
      expect(decoded.height, 32);
      expect((captured.last as SettableMetadata).contentType, 'image/jpeg');
      expect(await directory.list().length, 1);
    },
  );

  test('invalid images fail before sending bytes', () async {
    await image.writeAsBytes([1, 2, 3]);
    expect(
      await uploadFile(image, 'fixtures', 'image.jpg', 32, storage: storage),
      '',
    );
    verifyNever(() => reference.putData(any(), any()));
  });

  test('storage permission failures return a controlled failure', () async {
    when(() => reference.putData(any(), any())).thenThrow(
      FirebaseException(plugin: 'firebase_storage', code: 'unauthorized'),
    );
    expect(
      await uploadFile(image, 'fixtures', 'image.jpg', 32, storage: storage),
      '',
    );
  });

  test('unprocessed files use the original upload path', () async {
    expect(
      await uploadFile(image, 'fixtures', 'image.jpg', 0, storage: storage),
      isNotEmpty,
    );
    verify(() => reference.putFile(image)).called(1);
  });
}
