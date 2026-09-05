import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:test/test.dart';

void main() {
  group('Frame', () {
    test('is 64 bytes with opcode at [0]', () {
      final f = Frame(Opcode.ccGate);
      expect(f.bytes.length, frameLength);
      expect(f.bytes[0], 0x94);
    });

    test('writes little-endian floats and u16', () {
      final f = Frame(Opcode.ccGate)
        ..setF32(3, 1.5)
        ..setU16(7, 200);
      expect(f.f32(3), closeTo(1.5, 1e-6));
      expect(f.bytes[7], 200);
      expect(f.bytes[8], 0);
      // 1.5f = 0x3FC00000 -> LE bytes 00 00 C0 3F
      expect(f.bytes.sublist(3, 7), [0x00, 0x00, 0xC0, 0x3F]);
    });

    test('BOOTL and LOCK cannot be constructed', () {
      expect(() => Frame.rawOpcode(0x88), throwsA(isA<ProtocolPolicyError>()));
      expect(() => Frame.rawOpcode(0x87), throwsA(isA<ProtocolPolicyError>()));
      expect(Opcode.fromCode(0x88), isNull);
      expect(Opcode.fromCode(0x87), isNull);
    });

    test('EEPROM write arm (0x5C at [1]) is rejected for every opcode', () {
      for (final op in Opcode.values) {
        final f = Frame(op)..setU8(1, writeArmStatus);
        expect(() => f.bytes, throwsA(isA<ProtocolPolicyError>()),
            reason: op.name);
        expect(f.validate, throwsA(isA<ProtocolPolicyError>()));
      }
    });

    test('TEST sub-commands 1 and 2 are not mistaken for write arm', () {
      expect(buildTestInitiate().bytes[1], 1);
      expect(buildTestRead().bytes[1], 2);
    });
  });

  group('Response', () {
    test('rejects wrong length', () {
      expect(() => Response.fromHex('00 01'),
          throwsA(isA<ProtocolFormatException>()));
    });

    test('hex round trip', () {
      final r = synthHex();
      expect(Response.fromHex(r.hex()).bytes, r.bytes);
    });
  });
}

Response synthHex() {
  final f = Frame(Opcode.state)..setU8(2, 2);
  return Response(f.rawBytes);
}
