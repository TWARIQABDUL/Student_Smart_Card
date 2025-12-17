import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

class AuthService {
  // ⚠️ UPDATE: Ensure this matches your backend URL
  static const String baseUrl = 'https://student-smart-card-backend.onrender.com/api/v1';
  final _storage = const FlutterSecureStorage();

  // --- 1. LOGIN (UPDATED) ---
  Future<dynamic> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // 🚀 CHECK: Is it First Login?
        if (body['status'] == 'FORCE_CHANGE_PASSWORD') {
          return body; // Return the whole map so UI knows to redirect
        }

        // Normal Success
        await _storage.write(key: 'jwt_token', value: body['token']);
        return User.fromJson(body['user']);
      } else {
        return body['error'] ?? 'Login failed';
      }
    } catch (e) {
      return 'Connection error. Check your server.';
    }
  }

  // --- 2. CHANGE FIRST PASSWORD (NEW) ---
  Future<dynamic> changeFirstPassword(String email, String oldPassword, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/change-first-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Success! Save token and return User
        await _storage.write(key: 'jwt_token', value: body['token']);
        return User.fromJson(body['user']);
      } else {
        return body['error'] ?? 'Failed to update password';
      }
    } catch (e) {
      return 'Connection error';
    }
  }

  // ... keep resetPassword method ...
  Future<String?> resetPassword(String email, String newPassword) async {
    // (Your existing code here)
    return null;
  }
}