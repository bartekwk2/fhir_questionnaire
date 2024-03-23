import 'dart:async';
import 'dart:convert';

import 'package:example/file_utils.dart';
import 'package:example/picker_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fhir/r4.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crypto/crypto.dart';

class AttachmentUtils {
  static Future<Attachment?> _onPicked(
      {required List<String> filesPath, required String contentType}) async {
    final filePath = filesPath.firstOrNull;
    if (filePath == null || filePath.isEmpty) return null;
    final bytes = await FileUtils.readBytesFromFile(filePath: filePath);
    FileUtils.deleteFilePath(filePath);
    if (bytes == null || bytes.isEmpty) return null;
    final size = bytes.length;
    final data = base64Encode(bytes);
    final dataBase64AsBytes = utf8.encode(data);
    final sha1Result = sha1.convert(dataBase64AsBytes);
    final hash = base64Encode(sha1Result.bytes);

    return Attachment(
      data: FhirBase64Binary(data),
      hash: FhirBase64Binary(hash),
      size: FhirUnsignedInt(size),
      contentType: FhirCode(contentType),
      creation: FhirDateTime(DateTime.now()),
    );
  }

  static Future<Attachment?> pickAttachment(BuildContext context) {
    return showModalBottomSheet<Attachment?>(
        context: context,
        enableDrag: true,
        useSafeArea: true,
        isDismissible: true,
        clipBehavior: Clip.hardEdge,
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take photo'),
                  onTap: () async {
                    final result = await _onPicked(
                        filesPath: await (PickerUtils.handlePickerResponse(
                            PickerUtils.takeFromCamera(
                                cameraDevice: CameraDevice.front),
                            context: context,
                            closeBottomSheetAutomatically: false)),
                        contentType: 'image/jpeg');
                    if (context.mounted) {
                      Navigator.pop(context, result);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.image),
                  title: const Text('Pick from gallery'),
                  onTap: () async {
                    final result = await _onPicked(
                        filesPath: await (PickerUtils.handlePickerResponse(
                            PickerUtils.pickFromGallery(multiple: false),
                            context: context,
                            closeBottomSheetAutomatically: false)),
                        contentType: 'image/jpeg');
                    if (context.mounted) {
                      Navigator.pop(context, result);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.image),
                  title: const Text('Pick PDF'),
                  onTap: () async {
                    final result = await _onPicked(
                        filesPath: await (PickerUtils.handlePickerResponse(
                            PickerUtils.pickFromGalleryEnhanced(
                                multiple: false,
                                type: FileType.custom,
                                allowedExtensions: ['pdf']),
                            context: context,
                            closeBottomSheetAutomatically: false)),
                        contentType: 'application/pdf');
                    if (context.mounted) {
                      Navigator.pop(context, result);
                    }
                  },
                ),
              ],
            ),
          );
        }).whenComplete(() {});
  }
}
