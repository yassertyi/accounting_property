import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

Future<void> loadAppSettings() async {
  try {
    final box = await Hive.openBox('app_settings');
    final savedThemeIndex =
        box.get('themeMode', defaultValue: ThemeMode.system.index) as int;
    themeNotifier.value = ThemeMode.values[savedThemeIndex];
  } catch (e) {
    debugPrint("Error loading theme settings: $e");
  }
}

Future<void> saveThemeMode(ThemeMode mode) async {
  try {
    final box = await Hive.openBox('app_settings');
    await box.put('themeMode', mode.index);
    themeNotifier.value = mode;
  } catch (e) {
    debugPrint("Error saving theme mode: $e");
  }
}
