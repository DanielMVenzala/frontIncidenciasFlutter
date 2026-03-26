import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Provider para el modo claro/oscuro de la app.
/// La preferencia se persiste en FlutterSecureStorage para que
/// se mantenga entre sesiones. Se restaura en main.dart al arrancar.
class ThemeProvider extends ChangeNotifier {
  static const _key = 'dark_mode';
  final FlutterSecureStorage _storage;

  ThemeMode _themeMode = ThemeMode.light;

  ThemeProvider(this._storage);

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  /// Lee la preferencia guardada al iniciar la app
  Future<void> init() async {
    final value = await _storage.read(key: _key);
    _themeMode = value == 'true' ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// Alterna entre modo claro y oscuro, guardando la preferencia
  Future<void> toggle() async {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _storage.write(key: _key, value: isDark.toString());
    notifyListeners();
  }
}
