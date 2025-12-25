import 'dart:io'; // 🚀 Platform Checks
import 'dart:convert'; // 🚀 JSON Encoding
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // 🚀 Secure Storage
import '../models/user_model.dart';

class SmartCardService {
  // Must match the channel name in MainActivity.java
  static const platform = MethodChannel('com.example.student_card_app/nfc');

  // 🍏 iOS Secure Storage
  final _storage = const FlutterSecureStorage();
  static const String _iosStorageKey = "ios_secure_wallet_cache";

  // ⚠️ TEST FLAG: Set 'true' to simulate iOS behavior on Android.
  // Set 'false' for Production!
  static const bool isIosSimulation = false;

  // --- 1. CHECK NFC STATUS ---
  // Returns: 0=Ready, 1=Disabled, 2=Not Supported
  Future<int> checkNfcStatus() async {
    // 🛑 iOS / Simulation Check
    if (Platform.isIOS || isIosSimulation) {
      return 2; // Return "NFC_MISSING" so the UI hides the Tap button
    }

    // ✅ Android Native Call
    try {
      final int status = await platform.invokeMethod('checkNfcStatus');
      return status;
    } on PlatformException {
      return 2;
    }
  }

  // --- 2. ACTIVATE CARD (Login & Save) ---
  Future<String> activateCard(User user) async {
    // 🛑 iOS / Simulation Check
    if (Platform.isIOS || isIosSimulation) {
      // On iOS, "Activation" just means securely saving the user data for QR mode.
      await _saveToSecureStorage(user);
      return "Success";
    }

    // ✅ Android Native Call
    try {
      final String result = await platform.invokeMethod('activateCard', _userToMap(user));
      return result;
    } on PlatformException catch (e) {
      return "Failed: '${e.message}'.";
    }
  }

  // --- 3. DEACTIVATE CARD ---
  Future<void> deactivateCard() async {
    // 🛑 iOS / Simulation Check
    if (Platform.isIOS || isIosSimulation) {
      return; // Nothing to deactivate on iOS
    }

    // ✅ Android Native Call
    try {
      await platform.invokeMethod('deactivateCard');
    } on PlatformException catch (_) {}
  }

  // --- 4. 🚀 EXPLICIT SAVE (Hybrid) ---
  // Call this after login to ensure data is saved
  Future<void> saveUserData(User user) async {
    if (Platform.isIOS || isIosSimulation) {
      await _saveToSecureStorage(user);
    } else {
      // Android: Attempt to call the native save method (if exposed) or activate
      try {
        await platform.invokeMethod('activateCard', _userToMap(user));
      } catch (_) {}
    }
  }

  // --- 5. 🚀 GET CACHED USER (Hybrid) ---
  // Used for Offline Login / Auto-Login
  Future<User?> getCachedUser(String token) async {
    if (Platform.isIOS || isIosSimulation) {
      // 🍏 iOS: Read from Secure Storage (Keychain)
      String? jsonString = await _storage.read(key: _iosStorageKey);

      if (jsonString != null) {
        return User.fromJson(jsonDecode(jsonString));
      }
    } else {
      // 🤖 Android: Read from SDK (Room DB)
      try {
        final Map<dynamic, dynamic>? result =
        await platform.invokeMethod('getCachedUser', {"nfcToken": token});

        if (result != null) {
          return User.fromJson(Map<String, dynamic>.from(result));
        }
      } catch (e) {
        print("Android Cache Error: $e");
      }
    }
    return null;
  }

  // --- HELPER: Save to Secure Storage (iOS) ---
  Future<void> _saveToSecureStorage(User user) async {
    // Convert to JSON string and encrypt into Keychain
    await _storage.write(
        key: _iosStorageKey,
        value: jsonEncode(user.toJson())
    );
  }

  // --- HELPER: Convert User to Map (Android) ---
  Map<String, dynamic> _userToMap(User user) {
    return {
      'nfcToken': user.nfcToken,
      'name': user.name,
      'email': user.email,
      'role': user.role,
      'balance': user.walletBalance,
      'validUntil': '2029-12-31',
      'isActive': user.isActive,
    };
  }
}