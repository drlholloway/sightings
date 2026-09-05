import 'dart:typed_data';

import 'constants.dart';

/// Thrown when code attempts something the safety policy forbids
/// (forbidden opcode, EEPROM write arm). Never catch and continue.
class ProtocolPolicyError extends Error {
  ProtocolPolicyError(this.message);
  final String message;
  @override
  String toString() => 'ProtocolPolicyError: $message';
}

/// Thrown when a response cannot be parsed or does not match the request.
class ProtocolFormatException implements Exception {
  ProtocolFormatException(this.message);
  final String message;
  @override
  String toString() => 'ProtocolFormatException: $message';
}

/// A 64-byte command frame. Byte 0 is the opcode; everything else is zero
/// until a builder fills it in. All multi-byte values are little-endian.
class Frame {
  Frame(Opcode opcode) : _bytes = Uint8List(frameLength) {
    _bytes[0] = opcode.code;
    _data = ByteData.sublistView(_bytes);
  }

  /// Construct from a raw opcode number. Exists so tests (and only tests)
  /// can prove that forbidden opcodes are rejected.
  Frame.rawOpcode(int opcode) : _bytes = Uint8List(frameLength) {
    if (forbiddenOpcodes.contains(opcode)) {
      throw ProtocolPolicyError(
          'opcode 0x${opcode.toRadixString(16)} is blocked by policy');
    }
    _bytes[0] = opcode;
    _data = ByteData.sublistView(_bytes);
  }

  final Uint8List _bytes;
  late final ByteData _data;

  int get opcode => _bytes[0];

  /// Validated bytes ready for the wire. Throws if the frame carries the
  /// EEPROM write-arm status. Transports must call this, not access the
  /// buffer directly.
  Uint8List get bytes {
    validate();
    return _bytes;
  }

  /// Unvalidated view, for logging/tests only.
  Uint8List get rawBytes => _bytes;

  void validate() {
    if (forbiddenOpcodes.contains(_bytes[0])) {
      throw ProtocolPolicyError('forbidden opcode');
    }
    if (_bytes[1] == writeArmStatus) {
      throw ProtocolPolicyError('EEPROM write arm (0x5C) blocked by policy');
    }
  }

  void setU8(int offset, int v) => _data.setUint8(offset, v & 0xFF);
  void setU16(int offset, int v) =>
      _data.setUint16(offset, v & 0xFFFF, Endian.little);
  void setF32(int offset, double v) =>
      _data.setFloat32(offset, v, Endian.little);

  int u8(int offset) => _data.getUint8(offset);
  int u16(int offset) => _data.getUint16(offset, Endian.little);
  double f32(int offset) => _data.getFloat32(offset, Endian.little);

  String hex() => hexDump(_bytes);
}

/// A 64-byte response frame received from the unit.
class Response {
  Response(Uint8List bytes)
      : bytes = bytes.length == frameLength
            ? bytes
            : throw ProtocolFormatException(
                'response must be $frameLength bytes, got ${bytes.length}') {
    _data = ByteData.sublistView(this.bytes);
  }

  /// Build a response from a hex string (whitespace ignored). For tests and
  /// golden fixtures.
  factory Response.fromHex(String hex) {
    final clean = hex.replaceAll(RegExp(r'\s+'), '');
    if (clean.length != frameLength * 2) {
      throw ProtocolFormatException(
          'hex must encode $frameLength bytes, got ${clean.length ~/ 2}');
    }
    final out = Uint8List(frameLength);
    for (var i = 0; i < frameLength; i++) {
      out[i] = int.parse(clean.substring(2 * i, 2 * i + 2), radix: 16);
    }
    return Response(out);
  }

  final Uint8List bytes;
  late final ByteData _data;

  int get opcode => bytes[0];

  int u8(int offset) => _data.getUint8(offset);
  int u16(int offset) => _data.getUint16(offset, Endian.little);
  double f32(int offset) => _data.getFloat32(offset, Endian.little);

  /// `n` consecutive little-endian floats starting at `start`.
  List<double> f32List(int start, int n) =>
      List<double>.generate(n, (i) => f32(start + 4 * i), growable: false);

  String hex() => hexDump(bytes);
}

/// 16 bytes per line, lower-case, space separated — same layout as the
/// reference client's "raw" panel.
String hexDump(Uint8List b) {
  final sb = StringBuffer();
  for (var i = 0; i < b.length; i++) {
    sb.write(b[i].toRadixString(16).padLeft(2, '0'));
    sb.write(i % 16 == 15 ? '\n' : ' ');
  }
  return sb.toString().trimRight();
}
