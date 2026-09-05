import 'constants.dart';

/// Lead colour assigned to each of the three terminal drivers for a
/// configuration 1..6. Configs 7..12 use the same leads with P polarity.
class LeadMap {
  const LeadMap({required this.mt1, required this.mt2, required this.gate});
  final Lead mt1, mt2, gate;
}

const Map<int, LeadMap> cfgLeads = {
  1: LeadMap(mt1: Lead.red, mt2: Lead.green, gate: Lead.blue),
  2: LeadMap(mt1: Lead.red, mt2: Lead.blue, gate: Lead.green),
  3: LeadMap(mt1: Lead.green, mt2: Lead.red, gate: Lead.blue),
  4: LeadMap(mt1: Lead.green, mt2: Lead.blue, gate: Lead.red),
  5: LeadMap(mt1: Lead.blue, mt2: Lead.red, gate: Lead.green),
  6: LeadMap(mt1: Lead.blue, mt2: Lead.green, gate: Lead.red),
};

/// Reduce a 1..12 configuration to its 1..6 lead configuration.
int baseConfig(int cfg) => cfg > 6 ? cfg - 6 : cfg;

/// Whether a configuration is P-polarity (PNP / P-channel).
bool isPConfig(int cfg) => cfg > 6;

/// (plus, minus) lead pairs for the Vce and Vbe differences, per config 1..12.
/// Copied verbatim from DetermineVce / DetermineVbe.
const Map<int, (Lead, Lead)> vceTab = {
  1: (Lead.green, Lead.red),
  2: (Lead.blue, Lead.red),
  3: (Lead.red, Lead.green),
  4: (Lead.blue, Lead.green),
  5: (Lead.red, Lead.blue),
  6: (Lead.green, Lead.blue),
  7: (Lead.red, Lead.green),
  8: (Lead.red, Lead.blue),
  9: (Lead.green, Lead.red),
  10: (Lead.green, Lead.blue),
  11: (Lead.blue, Lead.red),
  12: (Lead.blue, Lead.green),
};

const Map<int, (Lead, Lead)> vbeTab = {
  1: (Lead.blue, Lead.red),
  2: (Lead.green, Lead.red),
  3: (Lead.blue, Lead.green),
  4: (Lead.red, Lead.green),
  5: (Lead.green, Lead.blue),
  6: (Lead.red, Lead.blue),
  7: (Lead.red, Lead.blue),
  8: (Lead.red, Lead.green),
  9: (Lead.green, Lead.blue),
  10: (Lead.green, Lead.red),
  11: (Lead.blue, Lead.green),
  12: (Lead.blue, Lead.red),
};

/// A terminal label attached to a lead colour, e.g. ("B", green).
class PinAssignment {
  const PinAssignment({required this.lead, required this.terminal});
  final Lead lead;
  final String terminal;

  @override
  bool operator ==(Object other) =>
      other is PinAssignment &&
      other.lead == lead &&
      other.terminal == terminal;
  @override
  int get hashCode => Object.hash(lead, terminal);
  @override
  String toString() => '$terminal=${lead.label}';
}

/// Pinout for a three-terminal device. `terms` is `[MT1, MT2, GATE]`
/// terminal labels; the returned order is MT1, GATE, MT2 (as the reference
/// client displays it: e.g. E, B, C).
List<PinAssignment>? pinsFor(int cfg, List<String> terms) {
  final m = cfgLeads[baseConfig(cfg)];
  if (m == null) return null;
  return [
    PinAssignment(lead: m.mt1, terminal: terms[0]),
    PinAssignment(lead: m.gate, terminal: terms[2]),
    PinAssignment(lead: m.mt2, terminal: terms[1]),
  ];
}

/// Diode pinout: anode on the GATE lead, cathode on the MT1 lead.
List<PinAssignment>? diodePins(int cfg) {
  final m = cfgLeads[baseConfig(cfg)];
  if (m == null) return null;
  return [
    PinAssignment(lead: m.gate, terminal: 'A'),
    PinAssignment(lead: m.mt1, terminal: 'K'),
  ];
}

/// Port of `Test.ConfigFrom12G([cathode, anode, NONE])`: which 1..6
/// configuration routes MT1 to `cathode` and MT2 to `anode`.
int configFrom12G(Lead cathode, Lead anode) {
  final rgb = [cathode, anode, Lead.none];
  if (rgb[0] == Lead.red) {
    return (rgb[1] == Lead.green || rgb[2] == Lead.blue) ? 1 : 2;
  }
  if (rgb[0] == Lead.green) {
    return (rgb[1] != Lead.red && rgb[2] != Lead.blue) ? 4 : 3;
  }
  if (rgb[0] == Lead.blue) {
    return (rgb[1] != Lead.red && rgb[2] != Lead.green) ? 6 : 5;
  }
  if (rgb[1] == Lead.red) return (rgb[2] != Lead.green) ? 3 : 5;
  if (rgb[1] == Lead.green) return (rgb[2] != Lead.red) ? 1 : 6;
  if (rgb[1] == Lead.blue) return (rgb[2] != Lead.red) ? 2 : 4;
  return 0;
}

/// `ConfigReverse_M1_M2` on CONFIG_RGB: swap MT1 and MT2 for a config 1..6.
const Map<int, int> revM1M2 = {1: 3, 2: 5, 3: 1, 4: 6, 5: 2, 6: 4};
