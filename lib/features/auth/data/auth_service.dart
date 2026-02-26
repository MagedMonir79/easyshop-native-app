import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();

  final String baseUrl = "https://www.easyshop-eg.com";

  Future<String?> login(String email, String password) async {
    try {
      print("🚀 LOGIN FUNCTION CALLED");
      print("📧 Email: $email");
      print("🔐 Password Length: ${password.length}");

      final response = await http.post(
        Uri.parse("$baseUrl/wp-json/jwt-auth/v1/token"),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "username": email,
          "password": password,
        },
      );

      print("🔵 LOGIN STATUS: ${response.statusCode}");
      print("🔵 LOGIN BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print("🟢 Parsed JSON: $data");

        if (data.containsKey('token') &&
            data['token'] != null &&
            data['token'].toString().isNotEmpty) {

          final token = data['token'];

          print("🟢 TOKEN FOUND");
          print("🟢 TOKEN LENGTH: ${token.length}");

          await _storage.write(
            key: "token",
            value: token,
          );

          print("✅ TOKEN SAVED SUCCESSFULLY");

          return token;
        } else {
          print("❌ TOKEN NOT FOUND IN RESPONSE");
        }
      } else {
        print("❌ LOGIN FAILED - STATUS NOT 200");
      }

      return null;

    } catch (e) {
      print("🔥 LOGIN ERROR: $e");
      return null;
    }
  }

  Future<String?> getToken() async {
    final token = await _storage.read(key: "token");
    print("🟡 STORED TOKEN: $token");
    return token;
  }

  Future<void> logout() async {
    await _storage.delete(key: "token");
    print("🚪 LOGOUT DONE");
  }
}