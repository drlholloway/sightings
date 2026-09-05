@TestOn('mac-os || linux')
library;

import 'package:dca75_transport/dca75_transport.dart';
import 'package:test/test.dart';

void main() {
  test('libusb loads and enumerates (no DCA75 required)', () async {
    final t = LibusbTransport();
    try {
      final devs = await t.listDevices();
      // Any result is fine; we only require that the worker came up.
      expect(devs, isA<List<DcaDeviceInfo>>());
      for (final d in devs) {
        expect(d.isDca75, isTrue);
      }
    } finally {
      await t.dispose();
    }
  }, skip: !const bool.fromEnvironment('DCA75_HAS_LIBUSB', defaultValue: true));

  test('open on a missing id fails with noDevice', () async {
    final t = LibusbTransport();
    try {
      await expectLater(
          t.open(const DcaDeviceInfo(id: '999:999')),
          throwsA(isA<TransportException>()
              .having((e) => e.kind, 'kind', TransportErrorKind.noDevice)));
      expect(t.isOpen, isFalse);
    } finally {
      await t.dispose();
    }
  });
}
