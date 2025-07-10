import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SettingsController {
  final Box _settingsBox;

  SettingsController(this._settingsBox);

  ThemeMode get themeMode => ThemeMode.values[
      _settingsBox.get('themeMode', defaultValue: ThemeMode.system.index)];

  Future<void> updateThemeMode(ThemeMode mode) async {
    await _settingsBox.put('themeMode', mode.index);
  }

  bool get backupEnabled => _settingsBox.get('backupEnabled', defaultValue: false);

  Future<void> updateBackupEnabled(bool value) async {
    await _settingsBox.put('backupEnabled', value);
  }

  bool get notificationsEnabled =>
      _settingsBox.get('notificationsEnabled', defaultValue: true);

  Future<void> updateNotificationsEnabled(bool value) async {
    await _settingsBox.put('notificationsEnabled', value);
  }

  bool get biometricAuthEnabled =>
      _settingsBox.get('biometricAuthEnabled', defaultValue: false);

  Future<void> updateBiometricAuthEnabled(bool value) async {
    await _settingsBox.put('biometricAuthEnabled', value);
  }
}