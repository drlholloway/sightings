import 'model.dart';

/// Built-in circuit profiles. Values are the commonly quoted builder targets;
/// each profile cites where its numbers come from and every number can be
/// edited in the app. Currents are amps, voltages volts, hFE dimensionless.
///
/// Gain rules use the profile's [CircuitProfile.hfeKey]: germanium lore is
/// based on low-current testers that subtract leakage (the DCA55 tests at
/// 2.5 mA), so germanium profiles read `hfe_dca55` when it has been measured
/// and fall back to the DCA75's `hfe`.
const List<CircuitProfile> defaultCircuits = [
  CircuitProfile(
    id: 'fuzz_face_ge',
    name: 'Fuzz Face (germanium)',
    family: 'Fuzz',
    source:
        'R.G. Keen, "The Technology of the Fuzz Face" (geofex.com); common builder practice',
    notes:
        'Q2 should have noticeably more gain than Q1; keep leakage low on both.',
    positions: [
      CircuitPosition(
        id: 'q1',
        label: 'Q1',
        role: 'Input transistor',
        kind: PartKind.bjt,
        polarity: Polarity.pnp,
        material: PartMaterial.germanium,
        rules: [
          Rule(key: 'hfe', min: 70, max: 85),
          Rule(key: 'ic_leak', max: 100e-6)
        ],
      ),
      CircuitPosition(
        id: 'q2',
        label: 'Q2',
        role: 'Output transistor',
        kind: PartKind.bjt,
        polarity: Polarity.pnp,
        material: PartMaterial.germanium,
        rules: [
          Rule(key: 'hfe', min: 120, max: 140),
          Rule(key: 'ic_leak', max: 100e-6)
        ],
      ),
    ],
  ),
  CircuitProfile(
    id: 'fuzz_face_si',
    name: 'Fuzz Face (silicon)',
    family: 'Fuzz',
    hfeKey: 'hfe',
    source: 'BC108/BC109/BC183 era values; common builder practice',
    positions: [
      CircuitPosition(
        id: 'q1',
        label: 'Q1',
        role: 'Input transistor',
        kind: PartKind.bjt,
        polarity: Polarity.npn,
        material: PartMaterial.silicon,
        rules: [Rule(key: 'hfe', min: 250, max: 350)],
      ),
      CircuitPosition(
        id: 'q2',
        label: 'Q2',
        role: 'Output transistor',
        kind: PartKind.bjt,
        polarity: Polarity.npn,
        material: PartMaterial.silicon,
        rules: [Rule(key: 'hfe', min: 300, max: 450)],
      ),
    ],
  ),
  CircuitProfile(
    id: 'tone_bender_mk2',
    name: 'Tone Bender MkII',
    family: 'Fuzz',
    source:
        'Common builder practice (OC75/OC81D era); D*A*M and Fuzz Central write-ups',
    notes: 'Q3 is the one that matters most: highest gain, lowest leakage.',
    positions: [
      CircuitPosition(
        id: 'q1',
        label: 'Q1',
        role: 'Input stage',
        kind: PartKind.bjt,
        polarity: Polarity.pnp,
        material: PartMaterial.germanium,
        rules: [
          Rule(key: 'hfe', min: 70, max: 100),
          Rule(key: 'ic_leak', max: 200e-6)
        ],
      ),
      CircuitPosition(
        id: 'q2',
        label: 'Q2',
        role: 'Second stage',
        kind: PartKind.bjt,
        polarity: Polarity.pnp,
        material: PartMaterial.germanium,
        rules: [
          Rule(key: 'hfe', min: 70, max: 100),
          Rule(key: 'ic_leak', max: 200e-6)
        ],
      ),
      CircuitPosition(
        id: 'q3',
        label: 'Q3',
        role: 'Fuzz stage',
        kind: PartKind.bjt,
        polarity: Polarity.pnp,
        material: PartMaterial.germanium,
        rules: [
          Rule(key: 'hfe', min: 100, max: 130),
          Rule(key: 'ic_leak', max: 150e-6)
        ],
      ),
    ],
  ),
  CircuitProfile(
    id: 'rangemaster',
    name: 'Rangemaster',
    family: 'Boost',
    source: 'OC44 originals; common builder practice',
    positions: [
      CircuitPosition(
        id: 'q1',
        label: 'Q1',
        role: 'Treble booster',
        kind: PartKind.bjt,
        polarity: Polarity.pnp,
        material: PartMaterial.germanium,
        rules: [
          Rule(key: 'hfe', min: 75, max: 100),
          Rule(key: 'ic_leak', max: 100e-6)
        ],
      ),
    ],
  ),
  CircuitProfile(
    id: 'big_muff_si',
    name: 'Big Muff Pi (silicon)',
    family: 'Fuzz',
    hfeKey: 'hfe',
    source: '2N5088/2N5089 era Big Muff builds',
    positions: [
      CircuitPosition(
        id: 'q1',
        label: 'Q1–Q4',
        role: 'Any of the four gain stages',
        kind: PartKind.bjt,
        polarity: Polarity.npn,
        material: PartMaterial.silicon,
        rules: [Rule(key: 'hfe', min: 400, max: 600)],
      ),
    ],
  ),
  CircuitProfile(
    id: 'clipping_si',
    name: 'Clipping diodes (silicon)',
    family: 'Clipping',
    source: '1N4148 / 1N914 clippers (RAT, Tube Screamer, Klon hard clip)',
    notes: 'Pairs should match within about 10–20 mV of Vf.',
    positions: [
      CircuitPosition(
        id: 'd',
        label: 'D1/D2',
        role: 'Silicon clipper',
        kind: PartKind.diode,
        material: PartMaterial.silicon,
        rules: [Rule(key: 'vf', min: 0.55, max: 0.75)],
      ),
    ],
  ),
  CircuitProfile(
    id: 'clipping_ge',
    name: 'Clipping diodes (germanium)',
    family: 'Clipping',
    source: '1N34A / D9B / OA90 clippers (Klon, Rat variants)',
    notes:
        'Low leakage keeps the clipping symmetric; pairs should match within 10–20 mV.',
    positions: [
      CircuitPosition(
        id: 'd',
        label: 'D1/D2',
        role: 'Germanium clipper',
        kind: PartKind.diode,
        material: PartMaterial.germanium,
        rules: [
          Rule(key: 'vf', min: 0.2, max: 0.5),
          Rule(key: 'leak_ir_5v', max: 20e-6)
        ],
      ),
    ],
  ),
  CircuitProfile(
    id: 'clipping_led',
    name: 'Clipping diodes (LED)',
    family: 'Clipping',
    source: 'Red/green LED clippers (Distortion+, Marshall Guv\'nor)',
    positions: [
      CircuitPosition(
        id: 'd',
        label: 'D1/D2',
        role: 'LED clipper',
        kind: PartKind.diode,
        material: PartMaterial.led,
        rules: [Rule(key: 'vf', min: 1.5, max: 2.2)],
      ),
    ],
  ),
];

CircuitProfile? defaultCircuit(String id) =>
    defaultCircuits.where((c) => c.id == id).firstOrNull;
