package com.example.student_card_app;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

// 1. Import your AAR Class
import com.example.card_emulator.StudentCardManager;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.student_card_app/nfc";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            switch (call.method) {
                                // --- CASE 1: CHECK STATUS (Calls AAR) ---
                                case "checkNfcStatus":
                                    // Pass 'this' (the Activity Context) to the AAR
                                    int status = StudentCardManager.getNfcStatus(this);
                                    result.success(status);
                                    break;

                                // --- CASE 2: ACTIVATE (Calls AAR) ---
                                case "startCardMode":
                                    String token = call.argument("token");
                                    if (token != null) {
                                        StudentCardManager.activateCard(token);
                                        result.success("Card Active");
                                    } else {
                                        result.error("ERROR", "Token is null", null);
                                    }
                                    break;

                                // --- CASE 3: DEACTIVATE (Calls AAR) ---
                                case "stopCardMode":
                                    StudentCardManager.deactivateCard();
                                    result.success("Card Stopped");
                                    break;

                                default:
                                    result.notImplemented();
                                    break;
                            }
                        }
                );
    }
}