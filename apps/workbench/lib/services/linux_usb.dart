import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The udev rule that lets a normal user open the DCA75 on Linux. Must match
/// `packaging/linux/60-dca75.rules` (a test pins this).
const udevRule =
    'SUBSYSTEM=="usb", ATTR{idVendor}=="04d8", ATTR{idProduct}=="f8ca", '
    'MODE="0660", TAG+="uaccess"';

/// One command that installs [udevRule] and reloads udev, with no file to
/// download first. Shown in the access-denied banner and in Settings.
const udevInstallCommand =
    "echo '$udevRule' | sudo tee /etc/udev/rules.d/60-dca75.rules >/dev/null"
    ' && sudo udevadm control --reload && sudo udevadm trigger';

/// Copies [text] and confirms with a snack bar.
Future<void> copyToClipboard(BuildContext context, String text) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
      .showSnackBar(const SnackBar(content: Text('Copied to the clipboard')));
}
