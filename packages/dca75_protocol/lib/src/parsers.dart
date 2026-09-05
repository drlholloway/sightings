import 'constants.dart';
import 'frame.dart';

/// Identity and state returned by STATE.
class StateInfo {
  const StateInfo({
    required this.stateCode,
    required this.hardwareRev,
    required this.firmwareRev,
    required this.serial,
    required this.rMt2,
  });

  final int stateCode;
  DeviceState? get state => DeviceState.fromCode(stateCode);

  /// Four hex digits, e.g. `00a5`.
  final String hardwareRev;
  final String firmwareRev;

  /// Six characters, one per u16 at [7..18].
  final String serial;

  /// Calibrated MT2 sense resistor (ohms) if the unit reported a sane value.
  final double? rMt2;

  @override
  String toString() =>
      'StateInfo(state=$stateCode hw=$hardwareRev fw=$firmwareRev sn=$serial rMt2=$rMt2)';
}

StateInfo parseState(Response r) {
  _expect(r, Opcode.state);
  final sb = StringBuffer();
  for (var i = 0; i < 6; i++) {
    sb.writeCharCode(r.u16(7 + 2 * i));
  }
  final rm = r.f32(19);
  return StateInfo(
    stateCode: r.u8(2),
    hardwareRev: r.u16(3).toRadixString(16).padLeft(4, '0'),
    firmwareRev: r.u16(5).toRadixString(16).padLeft(4, '0'),
    serial: sb.toString(),
    rMt2: (rm > 0 && rm < 1e5) ? rm : null,
  );
}

/// Calibration resistors (ohms) from a read-only CAL.
class Calibration {
  const Calibration({
    required this.r1k0,
    required this.r8k2,
    required this.r68k,
    required this.r470k,
    required this.rMt2,
  });
  final double r1k0, r8k2, r68k, r470k, rMt2;

  @override
  String toString() =>
      'Calibration(1k0=$r1k0 8k2=$r8k2 68k=$r68k 470k=$r470k rMt2=$rMt2)';
}

Calibration parseCal(Response r) {
  _expect(r, Opcode.cal);
  return Calibration(
    r1k0: r.f32(2),
    r8k2: r.f32(6),
    r68k: r.f32(10),
    r470k: r.f32(14),
    rMt2: r.f32(18),
  );
}

/// The always-present block of an ADCS response ([25..56]).
class AdcAlways {
  const AdcAlways({
    required this.setGate,
    required this.gate,
    required this.setMt1,
    required this.setMt2,
    required this.mt2,
    required this.red,
    required this.green,
    required this.blue,
  });
  final double setGate, gate, setMt1, setMt2, mt2, red, green, blue;
}

/// The direct-rail block of an ADCS response ([5..24]), present only when
/// the request's `direct` mask was non-zero.
class AdcRails {
  const AdcRails({
    required this.batt,
    required this.bTest,
    required this.v12,
    required this.prereg,
    required this.vRef,
  });
  final double batt, bTest, v12, prereg, vRef;

  @override
  String toString() =>
      'AdcRails(batt=$batt bTest=$bTest v12=$v12 prereg=$prereg vRef=$vRef)';
}

class AdcSnapshot {
  const AdcSnapshot({required this.always, this.rails});
  final AdcAlways always;
  final AdcRails? rails;
}

/// Parse ADCS. Pass `direct: true` when the request asked for the rails so
/// the [5..24] block is decoded; otherwise those bytes are ignored.
AdcSnapshot parseAdcs(Response r, {required bool direct}) {
  _expect(r, Opcode.adcs);
  return AdcSnapshot(
    always: AdcAlways(
      setGate: r.f32(25),
      gate: r.f32(29),
      setMt1: r.f32(33),
      setMt2: r.f32(37),
      mt2: r.f32(41),
      red: r.f32(45),
      green: r.f32(49),
      blue: r.f32(53),
    ),
    rails: direct
        ? AdcRails(
            batt: r.f32(5),
            bTest: r.f32(9),
            v12: r.f32(13),
            prereg: r.f32(17),
            vRef: r.f32(21),
          )
        : null,
  );
}

/// BOOSTED: byte [1] non-zero when the boost converter has reached target.
bool parseBoosted(Response r) {
  _expect(r, Opcode.boosted);
  return r.u8(1) != 0;
}

/// RGATE response: calibrated resistor value (ohms) at f32 [3]; null if the
/// unit returned a non-positive value.
double? parseRGate(Response r) {
  _expect(r, Opcode.rGate);
  final v = r.f32(3);
  return v > 0 ? v : null;
}

/// CCGATE READ status byte (frame[9]).
int ccStatus(Response r) {
  _expect(r, Opcode.ccGate);
  return r.u8(9);
}

/// CVGATE READ status byte (frame[10]).
int cvStatus(Response r) {
  _expect(r, Opcode.cvGate);
  return r.u8(10);
}

bool cxDone(int status) => (status & cxStatusDoneMask) != 0;
bool cxFault(int status) => (status & cxStatusFaultMask) != 0;

void _expect(Response r, Opcode op) {
  if (r.opcode != op.code) {
    throw ProtocolFormatException(
        'expected opcode 0x${op.code.toRadixString(16)}, got 0x${r.opcode.toRadixString(16)}');
  }
}
