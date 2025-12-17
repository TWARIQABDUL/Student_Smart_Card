import 'package:flutter/services.dart';
import '../models/user_model.dart';

class SmartCardService {
  // Must match the channel name in MainActivity.java
  static const platform = MethodChannel('com.example.student_card_app/nfc');

  // --- 1. CHECK NFC STATUS ---
  // Returns: 0=Ready, 1=Disabled (in Settings), 2=Not Supported (No Hardware)
  Future<int> checkNfcStatus() async {
    try {
      final int status = await platform.invokeMethod('checkNfcStatus');
      return status;
    } on PlatformException {
      return 2; // Assume missing if error
    }
  }

  // --- 2. ACTIVATE CARD ---
  Future<String> activateCard(User user) async {
    try {
      final String result = await platform.invokeMethod('activateCard', {
        'nfcToken': user.nfcToken,
        'name': user.name,
        'email': user.email,
        'role': user.role,
        'balance': user.walletBalance,
        'validUntil': '2029-12-31',
        'isActive': user.isActive,
      });
      return result;
    } on PlatformException catch (e) {
      return "Failed: '${e.message}'.";
    }
  }

  // --- 3. DEACTIVATE CARD ---
  Future<void> deactivateCard() async {
    try {
      await platform.invokeMethod('deactivateCard');
    } on PlatformException catch (_) {}
  }
}