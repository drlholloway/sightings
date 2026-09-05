import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dca75_device/dca75_device.dart';
import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:dca75_transport/dca75_transport.dart';

Future<void> main(List<String> args) async {
  final runner =
      CommandRunner<void>('dca75_cli', 'DCA75 Workbench command-line tools')
        ..addCommand(DecodeCommand())
        ..addCommand(ProbeCommand())
        ..addCommand(IdentifyCommand())
        ..addCommand(ReplayCommand())
        ..addCommand(BenchCommand());
  try {
    await runner.run(args);
  } on UsageException catch (e) {
    stderr.writeln(e);
    exitCode = 64;
  } on NoDevice {
    exitCode = 1;
  }
}

class NoDevice implements Exception {}

void printResult(IdentifyResult r) {
  stdout.writeln(
      '${r.name}  (type ${r.typeCode}, config ${r.config}, flags 0x${r.flags.toRadixString(16)})');
  if (r.flagLabels.isNotEmpty) {
    stdout.writeln('flags: ${r.flagLabels.join(', ')}');
  }
  final pins = r.pins;
  if (pins != null) stdout.writeln('pins: ${pins.join('  ')}');
  for (final p in r.params) {
    stdout.writeln('  ${p.label.padRight(22)} ${p.display}');
  }
}

/// `decode <hex>` — print the decoded identify result for a 64-byte frame.
class DecodeCommand extends Command<void> {
  @override
  final name = 'decode';
  @override
  final description = 'Decode a 64-byte TEST result frame given as hex.';

  @override
  Future<void> run() async {
    final hex = argResults!.rest.join(' ');
    if (hex.trim().isEmpty) usageException('give the frame as hex bytes');
    final r = decodeResult(Response.fromHex(hex));
    printResult(r);
    stdout.writeln();
    stdout.writeln(r.rawHex);
  }
}

Future<T> withDevice<T>(
    Future<T> Function(DeviceController c, LibusbTransport t) body,
    {String? capture}) async {
  final t = LibusbTransport();
  final ctl = DeviceController(t, autoPoll: false);
  try {
    final devs = await t.listDevices();
    if (devs.isEmpty) {
      stderr.writeln('no DCA75 found');
      throw NoDevice();
    }
    for (final d in devs) {
      stdout.writeln(
          'found ${d.id} ${d.productName ?? ''} s/n ${d.serialNumber ?? '?'}'
          '${d.accessError != null ? '  ACCESS: ${d.accessError}' : ''}');
    }
    await ctl.connect(devs.first);
    final s = ctl.status;
    stdout.writeln('connected: ${s.identity}');
    stdout.writeln('cal: ${s.calibration}');
    stdout.writeln(
        'rails: batt ${s.rails?.batt.toStringAsFixed(2)} V, 12V ${s.rails?.v12.toStringAsFixed(2)} V, '
        'Vref ${s.rails?.vRef.toStringAsFixed(3)} V, R(MT2) ${s.rails?.rMt2.toStringAsFixed(1)} Ω');
    return await body(ctl, t);
  } finally {
    if (capture != null) {
      File(capture).writeAsStringSync(
          encodeCapture(t.log.entries, comment: 'dca75_cli'));
      stdout.writeln('capture written to $capture (${t.log.length} exchanges)');
    }
    await ctl.dispose();
  }
}

/// `probe` — connect, print identity / calibration / rails, disconnect.
class ProbeCommand extends Command<void> {
  @override
  final name = 'probe';
  @override
  final description =
      'Connect to the DCA75 and print identity, calibration and rails.';

  ProbeCommand() {
    argParser.addOption('capture',
        help: 'write all exchanges to this .dcalog file');
  }

  @override
  Future<void> run() =>
      withDevice((c, t) async {}, capture: argResults!['capture'] as String?);
}

/// `identify` — run a test and print the decoded result.
class IdentifyCommand extends Command<void> {
  @override
  final name = 'identify';
  @override
  final description =
      'Run an identify test and print the result (or wait for the unit button).';

  IdentifyCommand() {
    argParser
      ..addOption('capture', help: 'write all exchanges to this .dcalog file')
      ..addFlag('wait',
          help: 'wait for a unit-button press instead of starting the test',
          negatable: false)
      ..addOption('count',
          abbr: 'n', defaultsTo: '1', help: 'number of results to collect');
  }

  @override
  Future<void> run() => withDevice((c, t) async {
        final n = int.parse(argResults!['count'] as String);
        final wait = argResults!['wait'] as bool;
        var got = 0;
        final sub = c.identifyEvents.listen((e) {
          stdout.writeln('--- result ${++got} (${e.source.name}) ---');
          printResult(e.result);
          stdout.writeln(e.result.rawHex);
        });
        if (wait) {
          stdout.writeln('press the button on the unit…');
          while (got < n) {
            await c.pollOnce();
            await Future<void>.delayed(const Duration(milliseconds: 600));
          }
        } else {
          for (var i = 0; i < n; i++) {
            await c.identify();
          }
        }
        await sub.cancel();
      }, capture: argResults!['capture'] as String?);
}

/// `replay <file.dcalog>` — drive the controller against a recorded session.
class ReplayCommand extends Command<void> {
  @override
  final name = 'replay';
  @override
  final description =
      'Replay a .dcalog capture through the controller and print any identify results.';

  @override
  Future<void> run() async {
    final path = argResults!.rest.singleOrNull;
    if (path == null) usageException('give a .dcalog file');
    final t =
        ReplayTransport.fromText(File(path).readAsStringSync(), strict: false);
    final ctl = DeviceController(t, sleep: noSleep, autoPoll: false);
    ctl.identifyEvents.listen((e) {
      stdout.writeln('--- ${e.source.name} ---');
      printResult(e.result);
    });
    await ctl.connect();
    stdout.writeln('connected (replay): ${ctl.status.identity}');
    while (!t.exhausted) {
      final st = await ctl.client.getState(DeviceState.idle);
      if (t.exhausted) break;
      if (st.state == DeviceState.tested) {
        await ctl.pollOnce();
      } else {
        // skip an exchange we cannot reproduce through the controller
        final line = t.lines[t.position];
        await t.exchange(Frame.rawOpcode(line.out[0]));
      }
    }
    await ctl.dispose();
  }
}

/// `bench` — latency loop of STATE exchanges.
class BenchCommand extends Command<void> {
  @override
  final name = 'bench';
  @override
  final description =
      'Run N STATE exchanges and report latency and mismatches.';

  BenchCommand() {
    argParser.addOption('count', abbr: 'n', defaultsTo: '1000');
  }

  @override
  Future<void> run() => withDevice((c, t) async {
        final n = int.parse(argResults!['count'] as String);
        t.log.clear();
        final sw = Stopwatch()..start();
        for (var i = 0; i < n; i++) {
          await c.client.getState(DeviceState.idle);
        }
        sw.stop();
        final l = t.log.latency();
        final errors = t.log.entries.where((e) => !e.ok).length;
        stdout.writeln('$n exchanges in ${sw.elapsedMilliseconds} ms: '
            'p50 ${l.p50.inMicroseconds / 1000} ms, p95 ${l.p95.inMicroseconds / 1000} ms, '
            'max ${l.max.inMicroseconds / 1000} ms, errors/stale $errors');
      });
}
