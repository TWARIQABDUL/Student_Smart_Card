import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // 👈 Using Secure Storage
import '../models/user_model.dart';

class ThemeManager with ChangeNotifier {
  // Create storage instance
  final _storage = const FlutterSecureStorage();

  // --- DEFAULT THEME (Tech University Blue) ---
  Color _primaryColor = const Color(0xFF3D5CFF);
  Color _secondaryColor = const Color(0xFF2B45B5);
  Color _backgroundColor = const Color(0xFF0F111A);
  Color _cardTextColor = Colors.white;

  // Getters
  Color get primaryColor => _primaryColor;
  Color get secondaryColor => _secondaryColor;
  Color get backgroundColor => _backgroundColor;
  Color get cardTextColor => _cardTextColor;

  // Storage Keys
  static const String KEY_PRIMARY = 'theme_primary';
  static const String KEY_SECONDARY = 'theme_secondary';
  static const String KEY_BACKGROUND = 'theme_background';
  static const String KEY_CARD_TEXT = 'theme_card_text';

  // 🔄 1. LOAD THEME (Call this in main.dart)
  Future<void> loadTheme() async {
    // Read strings from secure storage
    String? pColor = await _storage.read(key: KEY_PRIMARY);
    String? sColor = await _storage.read(key: KEY_SECONDARY);
    String? bColor = await _storage.read(key: KEY_BACKGROUND);
    String? tColor = await _storage.read(key: KEY_CARD_TEXT);

    // If data exists, parse it back to Color objects
    if (pColor != null && sColor != null && bColor != null && tColor != null) {
      _primaryColor = Color(int.parse(pColor));
      _secondaryColor = Color(int.parse(sColor));
      _backgroundColor = Color(int.parse(bColor));
      _cardTextColor = Color(int.parse(tColor));
      notifyListeners(); // Update UI
    }
  }

  // 💾 2. SAVE THEME (Call this after Login)
  Future<void> updateThemeFromUser(User user) async {
    if (user.campus != null) {
      // Update State immediately
      _primaryColor = _hexToColor(user.campus!.primaryColor);
      _secondaryColor = _hexToColor(user.campus!.secondaryColor);
      _backgroundColor = _hexToColor(user.campus!.backgroundColor);
      _cardTextColor = _hexToColor(user.campus!.cardTextColor);
      notifyListeners();

      // Save to Secure Storage (Convert int value to String)
      await _storage.write(key: KEY_PRIMARY, value: _primaryColor.value.toString());
      await _storage.write(key: KEY_SECONDARY, value: _secondaryColor.value.toString());
      await _storage.write(key: KEY_BACKGROUND, value: _backgroundColor.value.toString());
      await _storage.write(key: KEY_CARD_TEXT, value: _cardTextColor.value.toString());
    }
  }

  // 🗑️ 3. RESET THEME (Call this on Logout)
  Future<void> resetTheme() async {
    // Revert to Default
    _primaryColor = const Color(0xFF3D5CFF);
    _secondaryColor = const Color(0xFF2B45B5);
    _backgroundColor = const Color(0xFF0F111A);
    _cardTextColor = Colors.white;
    notifyListeners();

    // Clear Storage
    await _storage.delete(key: KEY_PRIMARY);
    await _storage.delete(key: KEY_SECONDARY);
    await _storage.delete(key: KEY_BACKGROUND);
    await _storage.delete(key: KEY_CARD_TEXT);
  }

  // Helper: Hex String (#FFFFFF) -> Color
  Color _hexToColor(String hexCode) {
    final buffer = StringBuffer();
    if (hexCode.length == 6 || hexCode.length == 7) buffer.write('ff');
    buffer.write(hexCode.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}