// Protocol constants for the DCA75. Values are taken verbatim from the
// reference client; do not "tidy" them.

/// USB identity of the DCA Pro (Microchip vendor ID).
const int usbVendorId = 0x04D8;
const int usbProductId = 0xF8CA;

/// Every command and response is exactly this long.
const int frameLength = 64;

/// Opcodes the application is allowed to send. `LOCK` (0x87) and `BOOTL`
/// (0x88) are deliberately absent: they cannot be expressed with this enum.
enum Opcode {
  serial(0x82),
  adcs(0x83),
  cal(0x84),
  test(0x85),
  state(0x86),
  message(0x89),
  boost(0x8A),
  boosted(0x8B),
  boostOff(0x8C),
  leadsSafe(0x8D),
  rGate(0x8E),
  volts(0x8F),
  allVolts(0x90),
  matrixRgb(0x91),
  matrixPlus(0x92),
  mode(0x93),
  ccGate(0x94),
  cvGate(0x95),
  cntrst(0x96),
  bridgeGate(0x97);

  const Opcode(this.code);
  final int code;

  static Opcode? fromCode(int code) {
    for (final o in values) {
      if (o.code == code) return o;
    }
    return null;
  }
}

/// Opcodes that must never reach the wire.
const int opcodeLock = 0x87;
const int opcodeBootloader = 0x88;
const Set<int> forbiddenOpcodes = {opcodeLock, opcodeBootloader};

/// Status byte (frame[1]) that arms an EEPROM write on CAL / SERIAL.
/// Rejected for every opcode.
const int writeArmStatus = 0x5C;

enum DeviceMode {
  none(0),
  display(1),
  analogLocal(2),
  analogUsb(3);

  const DeviceMode(this.code);
  final int code;
}

enum DeviceState {
  idle(0),
  testing(1),
  tested(2),
  ack(128),
  testedAck(130);

  const DeviceState(this.code);
  final int code;

  static DeviceState? fromCode(int code) {
    for (final s in values) {
      if (s.code == code) return s;
    }
    return null;
  }
}

enum Dac {
  mt1(0),
  mt2(1),
  gate(2);

  const Dac(this.code);
  final int code;
}

enum Drive {
  none(0),
  mt1(1),
  mt2(2),
  gate(3);

  const Drive(this.code);
  final int code;
}

enum Lead {
  none(0),
  red(1),
  green(2),
  blue(3);

  const Lead(this.code);
  final int code;

  String get label => switch (this) {
        Lead.none => 'None',
        Lead.red => 'Red',
        Lead.green => 'Green',
        Lead.blue => 'Blue',
      };

  static Lead fromLabel(String s) {
    switch (s.trim().toLowerCase()) {
      case 'red':
      case 'r':
        return Lead.red;
      case 'green':
      case 'g':
        return Lead.green;
      case 'blue':
      case 'b':
        return Lead.blue;
      default:
        return Lead.none;
    }
  }
}

/// Gate resistor selection index (RGATE opcode).
enum RGateIdx {
  r1k0(1),
  r8k2(2),
  r68k(3),
  r470k(4);

  const RGateIdx(this.code);
  final int code;
}

/// Constant-current / constant-voltage gate controller modes.
enum CxMode {
  off(0),
  on(1),
  read(3),
  resetAcq(4),
  oneShot(5),
  oneShotBurst(6);

  const CxMode(this.code);
  final int code;
}

/// Bit masks on the CC/CV READ status byte.
const int cxStatusDoneMask =
    0x4C; // any of these bits: acquisition finished (ok or not)
const int cxStatusFaultMask = 0x48; // any of these bits: aborted / fault

enum ComponentType {
  none(0, 'None'),
  bjt(1, 'BJT'),
  mosfet(2, 'MOSFET'),
  igbt(3, 'IGBT'),
  scr(4, 'SCR'),
  triac(5, 'TRIAC'),
  diode(6, 'Diode'),
  short(7, 'Short'),
  jfet(8, 'JFET'),
  vreg(9, 'V-Reg'),
  lowBattery(10, 'Low battery'),
  usbVoltageFail(11, 'USB voltage fail');

  const ComponentType(this.code, this.typeName);
  final int code;
  final String typeName;

  static ComponentType fromCode(int code) {
    for (final t in values) {
      if (t.code == code) return t;
    }
    return ComponentType.none;
  }

  /// Result types that describe a real component (not a status message).
  bool get isComponent => code >= 1 && code <= 9;
}

/// BJT flag bits (frame[4] when type == 1).
const int bjtFlagDigital = 2;
const int bjtFlagCeDiode = 4;
const int bjtFlagDarlington = 8;
const int bjtFlagNpn = 16;
const int bjtFlagGermanium = 32;
const int bjtFlagSilicon = 64;

/// MOSFET / IGBT flag bits.
const int fetFlagNChannel = 2;
const int fetFlagDepletion = 4;
const int fetFlagBodyDiode = 8;
const int fetFlagGateProtected = 16;

/// JFET flag bits.
const int jfetFlagSymmetric = 2;
const int jfetFlagNChannel = 4;
const int jfetFlagNormallyOff = 8;

/// Diode kinds (frame[5] for the first junction).
const List<String> diodeKindNames = [
  '',
  'PN junction',
  'LED',
  'dual LED',
  'Zener',
  'other',
];
const int diodeKindZener = 4;

/// Short-circuit lead mask bits (frame[3] when type == 7).
const int shortMaskRed = 1;
const int shortMaskGreen = 2;
const int shortMaskBlue = 4;

/// Constants used by the sweep algorithms.
const double maxBoostVolts = 15.0;
const double sweepCurrentLimitMa = 12.0;
const double dacLsbVolts = 0.0033341474;
const double icZeroFloorFactor = 0.0009155832231044769;
