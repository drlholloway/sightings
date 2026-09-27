import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:workbench/services/linux_usb.dart';

void main() {
  test('in-app udev rule matches the shipped rules file', () {
    final lines = File('../../packaging/linux/60-dca75.rules')
        .readAsLinesSync()
        .where((l) => l.trim().isNotEmpty && !l.startsWith('#'))
        .toList();
    expect(lines, [udevRule]);
  });

  test('install command writes the rule and reloads udev', () {
    expect(udevInstallCommand, contains("echo '$udevRule'"));
    expect(udevInstallCommand, contains('/etc/udev/rules.d/60-dca75.rules'));
    expect(udevInstallCommand, contains('udevadm control --reload'));
    expect(udevInstallCommand, contains('udevadm trigger'));
  });
}
