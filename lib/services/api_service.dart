import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'https://student-smart-card-backend.onrender.com/api/v1';

  // 🚀 CRITICAL: Use the SAME options as AuthService!
  // If AuthService writes to 'encryptedSharedPreferences', we must read from there too.
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // --- GET MY LOGS ---
  Future<List<Map<String, dynamic>>> getMyHistory() async {
    try {
      // 1. Get the Saved JWT Token from SECURE STORAGE
      final String? token = await _storage.read(key: 'jwt_token');

      if (token == null) throw Exception("Not Logged In");

      // 2. Call the Backend
      final response = await http.get(
        Uri.parse('$baseUrl/student/history?limit=20'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      // 3. Parse Response
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception("Failed to load history");
      }
    } catch (e) {
      print("Error fetching history: $e");
      return [];
    }
  }
}