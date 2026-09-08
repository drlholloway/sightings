import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  Settings copyWith({
    bool? autoConnect,
    bool? unitButtonAsDraft,
    String? themeMode,
    int? digits,
    bool? dca55Auto,
    bool? leakAuto,
    bool? demoMode,
  }) => Settings(
    autoConnect: autoConnect ?? this.autoConnect,
    unitButtonAsDraft: unitButtonAsDraft ?? this.unitButtonAsDraft,
    themeMode: themeMode ?? this.themeMode,
    digits: digits ?? this.digits,
    dca55Auto: dca55Auto ?? this.dca55Auto,
    leakAuto: leakAuto ?? this.leakAuto,
    demoMode: demoMode ?? this.demoMode,
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
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, Settings>(
  (ref) => SettingsNotifier(),
);
