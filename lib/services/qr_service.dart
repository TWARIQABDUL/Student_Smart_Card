import 'dart:convert';
import 'package:crypto/crypto.dart';

class QrService {
  /// Generates: "STUDENT_ID:TIMESTAMP:SIGNATURE"
  static String generateDynamicToken(String studentId, String secret) {
    if (secret.isEmpty) return "INVALID_SECRET";

    // 1. Get current time in millis
    final int timestamp = DateTime.now().millisecondsSinceEpoch;

    // 2. Prepare data to sign
    String payload = "$studentId:$timestamp";

    // 3. Create HMAC-SHA256 Signature
    var key = utf8.encode(secret);
    var bytes = utf8.encode(payload);
    var hmac = Hmac(sha256, key);
    var digest = hmac.convert(bytes);

    // 4. FIX: Use base64Url (URL Safe) and remove Padding ('=')
    String signature = base64Url.encode(digest.bytes);

    // Java's .withoutPadding() removes '=', so we must too.
    if (signature.endsWith('=')) {
      signature = signature.replaceAll('=', '');
    }

    return "$payload:$signature";
  }
}