import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  const Settings({
    this.autoConnect = true,
    this.unitButtonAsDraft = true,
    this.themeMode = 'system',
    this.digits = 3,
  });
  final bool autoConnect;
  final bool unitButtonAsDraft;
  final String themeMode; // system | light | dark
  final int digits;

  Settings copyWith({
    bool? autoConnect,
    bool? unitButtonAsDraft,
    String? themeMode,
    int? digits,
  }) => Settings(
    autoConnect: autoConnect ?? this.autoConnect,
    unitButtonAsDraft: unitButtonAsDraft ?? this.unitButtonAsDraft,
    themeMode: themeMode ?? this.themeMode,
    digits: digits ?? this.digits,
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
    );
  }

  Future<void> update(Settings s) async {
    state = s;
    final p = _prefs ?? await SharedPreferences.getInstance();
    await p.setBool('autoConnect', s.autoConnect);
    await p.setBool('unitButtonAsDraft', s.unitButtonAsDraft);
    await p.setString('themeMode', s.themeMode);
    await p.setInt('digits', s.digits);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, Settings>(
  (ref) => SettingsNotifier(),
);
