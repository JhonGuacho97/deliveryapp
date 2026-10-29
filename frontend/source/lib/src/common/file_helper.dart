import 'dart:async';
import 'dart:io' as io;
import 'dart:ui';

import 'package:image/image.dart' as img; // Añade esto en pubspec.yaml también
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:planck/constants/constants.dart';

toBytes(String path, int targetWidth, {required isLocal}) async {
  Uint8List bytes;
  if (isLocal) {
    final ByteData data = await rootBundle.load(path);
    bytes = data.buffer.asUint8List();
  } else {
    final file = await DefaultCacheManager().getSingleFile(path);
    bytes = await file.readAsBytes();
  }
  final codec = await instantiateImageCodec(bytes, targetWidth: targetWidth);
  final frameInfo = await codec.getNextFrame();
  final image = await frameInfo.image.toByteData(format: ImageByteFormat.png);

  final bitmap = BitmapDescriptor.bytes(image!.buffer.asUint8List());
  final icon = Completer<BitmapDescriptor>();
  icon.complete(bitmap);

  return await icon.future;
}

Future<String> uploadFile(
  io.File file,
  String folder,
  String name,
  int targetWidth, {
  firebase_storage.FirebaseStorage? storage,
}) async {
  if (!kExternalServicesEnabled && storage == null) return '';
  firebase_storage.Reference storageReference =
      (storage ?? firebase_storage.FirebaseStorage.instance)
          .ref(folder)
          .child(name);

  try {
    // Si targetWidth es mayor a 0, procesamos la imagen
    if (targetWidth > 0) {
      final originalBytes = await file.readAsBytes();
      final decoded = img.decodeImage(originalBytes);
      if (decoded == null) return '';

      // Hacemos crop a cuadrado (desde el centro)
      final minSide = decoded.width < decoded.height
          ? decoded.width
          : decoded.height;
      final offsetX = ((decoded.width - minSide) / 2).round();
      final offsetY = ((decoded.height - minSide) / 2).round();
      final cropped = img.copyCrop(
        decoded,
        x: offsetX,
        y: offsetY,
        width: minSide,
        height: minSide,
      );

      // Redimensionamos a targetWidth
      final resized = img.copyResize(
        cropped,
        width: targetWidth,
        height: targetWidth,
      );

      // Guardamos la imagen en formato JPG
      final compressedBytes = img.encodeJpg(resized, quality: 85);

      final firebase_storage.UploadTask uploadTask = storageReference.putData(
        Uint8List.fromList(compressedBytes),
        firebase_storage.SettableMetadata(contentType: 'image/jpeg'),
      );
      await uploadTask.whenComplete(() => null);
    } else {
      // Otros tipos de archivos, se suben tal como están
      final firebase_storage.UploadTask uploadTask = storageReference.putFile(
        file,
      );
      await uploadTask.whenComplete(() => null);
    }
    return await storageReference.getDownloadURL();
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
    return '';
  }
}
