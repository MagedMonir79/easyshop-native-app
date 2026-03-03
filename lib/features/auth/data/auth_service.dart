import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_client.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // 🔹 رابط الموقع الأساسي
  final String baseUrl = "https://www.easyshop-eg.com";

  late final ApiClient _apiClient;

  AuthService() {
    _apiClient = ApiClient(
      baseUrl: "$baseUrl/wp-json",
    );
  }

  /// 🔐 LOGIN
  Future<String?> login(String email, String password) async {
    try {
      print("🚀 LOGIN FUNCTION CALLED");
      print("📧 Email: $email");
      print("🔐 Password Length: ${password.length}");

      final uri = Uri.parse(
        "$baseUrl/wp-json/jwt-auth/v1/token",
      );

      final response = await http.post(
        uri,
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

        if (data.containsKey('token') &&
            data['token'] != null &&
            data['token'].toString().isNotEmpty) {

          final token = data['token'];

          await _storage.write(
            key: "token",
            value: token,
          );

          print("✅ TOKEN SAVED SUCCESSFULLY");

          if (data.containsKey("user_display_name")) {
            await _storage.write(
              key: "user_name",
              value: data["user_display_name"].toString(),
            );
            print("🟢 USER NAME SAVED: ${data["user_display_name"]}");
          }

          if (data.containsKey("user_email")) {
            await _storage.write(
              key: "user_email",
              value: data["user_email"].toString(),
            );
          }

          if (data.containsKey("user_nicename")) {
            await _storage.write(
              key: "user_nicename",
              value: data["user_nicename"].toString(),
            );
          }

          // ✅ محاولة جلب الاسم الحقيقي من validate
          try {
            print("🟡 Trying token validate endpoint...");

            final validateResponse = await http.post(
              Uri.parse(
                "$baseUrl/wp-json/jwt-auth/v1/token/validate",
              ),
              headers: {
                "Authorization": "Bearer $token",
              },
            );

            print("🟡 VALIDATE STATUS: ${validateResponse.statusCode}");
            print("🟡 VALIDATE BODY: ${validateResponse.body}");

            if (validateResponse.statusCode == 200) {
              final validateData =
                  jsonDecode(validateResponse.body);

              if (validateData["data"]?["user"]?["display_name"] != null) {
                final realName =
                    validateData["data"]["user"]["display_name"];

                await _storage.write(
                  key: "user_name",
                  value: realName.toString(),
                );

                print("🟢 USER NAME SAVED FROM VALIDATE: $realName");
              }
            }
          } catch (e) {
            print("⚠️ VALIDATE ERROR: $e");
          }

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

  /// 🔎 GET STORED TOKEN
  Future<String?> getToken() async {
    final token = await _storage.read(key: "token");
    print("🟡 STORED TOKEN: $token");
    return token;
  }

  /// ✅ CHECK IF USER LOGGED IN
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// 🔐 GET AUTH HEADERS (مهم للـ Cart API)
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception("❌ No token found");
    }

    return {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };
  }

  /// 🔎 VALIDATE STORED TOKEN (للـ Auto Login)
  Future<bool> validateStoredToken() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse(
          "$baseUrl/wp-json/jwt-auth/v1/token/validate",
        ),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      print("🟡 STORED TOKEN VALIDATE STATUS: ${response.statusCode}");

      return response.statusCode == 200;

    } catch (e) {
      print("⚠️ STORED TOKEN VALIDATE ERROR: $e");
      return false;
    }
  }

  /// ✅ قراءة اسم المستخدم المخزن
  Future<String?> getStoredUserName() async {
    final name = await _storage.read(key: "user_name");
    print("🟢 STORED USER NAME: $name");
    return name;
  }

  /// 🚪 LOGOUT
  Future<void> logout() async {
    await clearAllAuthData();
    print("🚪 LOGOUT DONE");
  }

  /// 🧹 CLEAR ALL AUTH DATA (مهم جدًا لحل مشكلة السلة)
  Future<void> clearAllAuthData() async {
    await _storage.delete(key: "token");
    await _storage.delete(key: "user_name");
    await _storage.delete(key: "user_email");
    await _storage.delete(key: "user_nicename");

    print("🧹 ALL AUTH DATA CLEARED");
  }
}