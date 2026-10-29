import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/widgets/upload_file/upload_file_controller.dart';
import 'package:planck/src/widgets/forms/form_page.dart';
import 'package:provider/provider.dart';

class UploadFile extends StatelessWidget {
  UploadFile(this.onUnpload, {super.key});
  final Function onUnpload;
  final picker = ImagePicker();
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => UploadFileController(),
    child: Consumer<UploadFileController>(
      builder: (context, c, _) => AppFormDialog(
        title: S.of(context).editImage,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (c.getImage() != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.file(
                  c.getImage()!,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
            ],
            OutlinedButton(
              onPressed: () async {
                try {
                  final image = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (context.mounted && image != null)
                    c.image = File(image.path);
                } catch (_) {
                  if (context.mounted)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(S.of(context).errUnknown)),
                    );
                }
              },
              child: Text(S.of(context).bSelectPhoto),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).bCancel),
          ),
          FilledButton(
            onPressed: c.getImage() == null
                ? null
                : () {
                    Navigator.pop(context);
                    onUnpload(c.getImage()!);
                  },
            child: Text(S.of(context).bUpload),
          ),
        ],
      ),
    ),
  );
}
