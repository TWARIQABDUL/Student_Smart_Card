package com.example.student_card_app; // ⚠️ Match your AndroidManifest

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

// Import your SDK Classes
import com.example.card_emulator.StudentCardManager;
import com.example.card_emulator.db.WalletEntity;

import java.util.HashMap;
import java.util.Map;

public class MainActivity extends FlutterActivity {
    // ⚠️ MUST MATCH Flutter: static const platform = MethodChannel(...)"
    private static final String CHANNEL = "com.example.student_card_app/nfc";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            switch (call.method) {

                                // --- 1. ACTIVATE CARD (SECURE) ---
                                case "activateCard":
                                    String token = call.argument("nfcToken");
                                    String name = call.argument("name");
                                    String email = call.argument("email");
                                    String role = call.argument("role");
                                    Double balance = call.argument("balance");
                                    String validUntil = call.argument("validUntil");
                                    Boolean isActive = call.argument("isActive");

                                    if (token != null) {
                                        // A. Start NFC Logic & Check Security
                                        int status = StudentCardManager.activateCard(this, token);

                                        // B. Handle Result Codes
                                        if (status == StudentCardManager.STATUS_SUCCESS) {
                                            // ✅ Success: Save Data for Offline Mode
                                            StudentCardManager.saveUserData(
                                                    this,
                                                    token,
                                                    name,
                                                    email,
                                                    role,
                                                    balance != null ? balance : 0.0,
                                                    validUntil,
                                                    isActive != null ? isActive : true
                                            );
                                            result.success("Card Activated");

                                        } else if (status == StudentCardManager.STATUS_DEVICE_ROOTED) {
                                            // 🚨 Rooted Device Detected
                                            result.error("SEC_ERROR", "Device is Rooted. Access Denied.", null);

                                        } else if (status == StudentCardManager.STATUS_APP_TAMPERED) {
                                            // 🚨 Modified APK Detected
                                            result.error("SEC_ERROR", "App has been modified. Re-install from official source.", null);

                                        } else {
                                            // ⚠️ Unknown Error
                                            result.error("ERR_UNKNOWN", "Activation failed. Code: " + status, null);
                                        }
                                    } else {
                                        result.error("ERROR", "Token is null", null);
                                    }
                                    break;

                                // --- 2. DEACTIVATE CARD ---
                                case "deactivateCard":
                                    StudentCardManager.deactivateCard();
                                    result.success("Card Deactivated");
                                    break;

                                // --- 3. GET OFFLINE USER DATA ---
                                case "getCachedUser":
                                    String t = call.argument("nfcToken");
                                    StudentCardManager.getCachedUser(this, t, new StudentCardManager.UserCallback() {
                                        @Override
                                        public void onUserLoaded(WalletEntity user) {
                                            if (user != null) {
                                                // Map Native Object to Flutter Map
                                                Map<String, Object> userData = new HashMap<>();
                                                userData.put("nfcToken", user.studentToken);
                                                userData.put("name", user.name);
                                                userData.put("balance", user.balance);
                                                userData.put("role", user.role);
                                                result.success(userData);
                                            } else {
                                                result.error("NOT_FOUND", "No user cache found", null);
                                            }
                                        }

                                        @Override
                                        public void onError(String msg) {
                                            result.error("DB_ERROR", msg, null);
                                        }
                                    });
                                    break;

                                // --- 4. CHECK NFC HARDWARE ---
                                case "checkNfcStatus":
                                    result.success(StudentCardManager.getNfcStatus(this));
                                    break;

                                default:
                                    result.notImplemented();
                                    break;
                            }
                        }
                );
    }
}