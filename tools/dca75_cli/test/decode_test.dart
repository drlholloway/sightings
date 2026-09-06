import 'dart:io';

import 'package:dca75_cli/dca75_cli.dart' as cli;
import 'package:test/test.dart';

// The 2N5088 golden frame (see packages/dca75_protocol/test/golden).
const frame = '85 02 01 04 51 0e 31 a1 3b fa d2 44 3f 0a 62 34 '
    '3f 98 0e a0 40 7f 1d 80 3f 87 00 ca 43 78 ec 9f '
    '40 c0 25 bb 3c 5f 3a a0 40 f1 55 80 3f 00 00 00 '
    '00 40 ed 74 42 03 00 00 00 00 00 00 00 00 00 00';

void main() {
  tearDown(() => exitCode = 0);

  test('decode prints the identify result', () async {
    final out = StringBuffer();
    await IOOverrides.runZoned(
      () => cli.main(['decode', ...frame.split(' ')]),
      stdout: () => _CapturingStdout(out),
    );
    expect(exitCode, 0);
    expect(out.toString(), contains('NPN BJT'));
    expect(out.toString(), contains('hFE (gain)'));
    expect(out.toString(), contains('404.0'));
    expect(out.toString(), contains('E=Green  B=Red  C=Blue'));
  });

  test('decode without a frame is a usage error', () async {
    await IOOverrides.runZoned(
      () => cli.main(['decode']),
      stderr: () => _CapturingStdout(StringBuffer()),
    );
    expect(exitCode, 64);
  });
}

/// Minimal stdout stand-in that collects text.
class _CapturingStdout implements Stdout {
  _CapturingStdout(this.buffer);
  final StringBuffer buffer;

  @override
  void write(Object? object) => buffer.write(object);
  @override
  void writeln([Object? object = '']) => buffer.writeln(object);
  @override
  void writeAll(Iterable<dynamic> objects, [String separator = '']) =>
      buffer.writeAll(objects, separator);
  @override
  void writeCharCode(int charCode) => buffer.writeCharCode(charCode);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
