import 'package:dca75_transport/dca75_transport.dart';

import 'demo_unit.dart';

/// A [FakeTransport] backed by a [DemoUnit], for running the app without a
/// DCA75 (store reviewers, screenshots, trying the app out).
class DemoTransport extends FakeTransport {
  DemoTransport(
      {DemoUnit? unit, super.latency = const Duration(milliseconds: 1)})
      : unit = unit ?? DemoUnit(),
        super(
          devices: const [
            DcaDeviceInfo(
                id: 'demo',
                productName: 'DCA Pro (demo)',
                serialNumber: 'DEMO01'),
          ],
        ) {
    handler = this.unit.handle;
  }

  final DemoUnit unit;
}
