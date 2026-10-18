import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// Hands an exported file to the user: the share sheet on Android, a save
/// dialog everywhere else. share_plus cannot share files on Linux, and the
/// save dialog goes through the desktop portal, so it also works in Flatpak.
Future<void> exportFile(
  BuildContext context, {
  required Uint8List bytes,
  required String name,
  required String mimeType,
  String? subject,
}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  try {
    if (Platform.isAndroid) {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(bytes, mimeType: mimeType, name: name)],
          subject: subject,
        ),
      );
      return;
    }
    final saved = await FilePicker.saveFile(
      dialogTitle: 'Save $name',
      fileName: name,
      bytes: bytes,
      mimeType: mimeType,
    );
    if (saved == null) return;
    final shown = saved.scheme == 'file' ? saved.toFilePath() : '$saved';
    messenger?.showSnackBar(SnackBar(content: Text('Saved to $shown')));
  } catch (e) {
    messenger?.showSnackBar(SnackBar(content: Text('Export failed: $e')));
  }
}
