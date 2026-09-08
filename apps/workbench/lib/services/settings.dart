import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  const Settings({
    this.autoConnect = true,
    this.unitButtonAsDraft = true,
    this.themeMode = 'system',
    this.digits = 3,
    this.dca55Auto = true,
    this.leakAuto = true,
    this.demoMode = false,
    this.pedalBuilder = false,
    this.activeCircuits = const {},
    this.circuitOverridesJson = '{}',
  });
  final bool autoConnect;
  final bool unitButtonAsDraft;
  final String themeMode; // system | light | dark
  final int digits;

  /// After every saved BJT identify, also measure at the DCA55's conditions.
  final bool dca55Auto;

  /// After every saved diode identify, also measure reverse leakage at 5 V and 10 V.
  final bool leakAuto;

  /// Run against a simulated DCA75 (no hardware needed).
  final bool demoMode;

  /// Pedal Builder: circuit profiles, the Circuits tab and the fit card.
  final bool pedalBuilder;

  /// Ids of circuits that are active (evaluated on readings). Empty means
  /// "all built-in circuits" until the user changes something.
  final Set<String> activeCircuits;

  /// JSON map of circuit id → edited profile JSON.
  final String circuitOverridesJson;

  Settings copyWith({
    bool? autoConnect,
    bool? unitButtonAsDraft,
    String? themeMode,
    int? digits,
    bool? dca55Auto,
    bool? leakAuto,
    bool? demoMode,
    bool? pedalBuilder,
    Set<String>? activeCircuits,
    String? circuitOverridesJson,
  }) => Settings(
    autoConnect: autoConnect ?? this.autoConnect,
    unitButtonAsDraft: unitButtonAsDraft ?? this.unitButtonAsDraft,
    themeMode: themeMode ?? this.themeMode,
    digits: digits ?? this.digits,
    dca55Auto: dca55Auto ?? this.dca55Auto,
    leakAuto: leakAuto ?? this.leakAuto,
    demoMode: demoMode ?? this.demoMode,
    pedalBuilder: pedalBuilder ?? this.pedalBuilder,
    activeCircuits: activeCircuits ?? this.activeCircuits,
    circuitOverridesJson: circuitOverridesJson ?? this.circuitOverridesJson,
  );
}

class SettingsNotifier extends StateNotifier<Settings> {
  SettingsNotifier() : super(const Settings()) {
    _load();
  }

  SharedPreferences? _prefs;

  Future<void> _load() async {
    _prefs = await SharedPreferences.getInstance();
    final p = _prefs!;
    state = Settings(
      autoConnect: p.getBool('autoConnect') ?? true,
      unitButtonAsDraft: p.getBool('unitButtonAsDraft') ?? true,
      themeMode: p.getString('themeMode') ?? 'system',
      digits: p.getInt('digits') ?? 3,
      dca55Auto: p.getBool('dca55Auto') ?? true,
      leakAuto: p.getBool('leakAuto') ?? true,
      demoMode: p.getBool('demoMode') ?? false,
      pedalBuilder: p.getBool('pedalBuilder') ?? false,
      activeCircuits: (p.getStringList('activeCircuits') ?? const []).toSet(),
      circuitOverridesJson: p.getString('circuitOverridesJson') ?? '{}',
    );
  }

  Future<void> update(Settings s) async {
    state = s;
    final p = _prefs ?? await SharedPreferences.getInstance();
    await p.setBool('autoConnect', s.autoConnect);
    await p.setBool('unitButtonAsDraft', s.unitButtonAsDraft);
    await p.setString('themeMode', s.themeMode);
    await p.setInt('digits', s.digits);
    await p.setBool('dca55Auto', s.dca55Auto);
    await p.setBool('leakAuto', s.leakAuto);
    await p.setBool('demoMode', s.demoMode);
    await p.setBool('pedalBuilder', s.pedalBuilder);
    await p.setStringList('activeCircuits', s.activeCircuits.toList());
    await p.setString('circuitOverridesJson', s.circuitOverridesJson);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, Settings>(
  (ref) => SettingsNotifier(),
);
