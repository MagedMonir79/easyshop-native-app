import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/api_client.dart';

class UserService {
  final String baseUrl = "https://www.easyshop-eg.com";

  late final ApiClient _apiClient;

  // ✅ إضافة SecureStorage لقراءة التوكن عند الحاجة
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  UserService() {
    _apiClient = ApiClient(
      baseUrl: "$baseUrl/wp-json",
    );
  }

  /// 👤 Get Current Logged In User
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {

      /// 🔹 المحاولة الأولى (WordPress Core)
      final http.Response response =
          await _apiClient.get("/wp/v2/users/me");

      print("👤 USER STATUS: ${response.statusCode}");
      print("👤 USER BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      }

      /// 🔥 لو 403 أو فشل — نجرب WooCommerce endpoint
      print("⚠️ Trying WooCommerce endpoint...");

      final http.Response wcResponse =
          await _apiClient.get("/wc/v3/customers/me");

      print("🟢 WC USER STATUS: ${wcResponse.statusCode}");
      print("🟢 WC USER BODY: ${wcResponse.body}");

      if (wcResponse.statusCode == 200) {
        final data = jsonDecode(wcResponse.body);

        return {
          "id": data["id"],
          "name":
              "${data["first_name"] ?? ""} ${data["last_name"] ?? ""}".trim(),
          "email": data["email"],
          "roles": ["customer"]
        };
      }

      /// 🔥 آخر حل: استخراج البيانات من JWT نفسه
      print("⚠️ Trying to decode JWT token...");

      final token = await _storage.read(key: "token");

      if (token != null) {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = utf8.decode(
            base64Url.decode(base64Url.normalize(parts[1])),
          );

          final decoded = jsonDecode(payload);

          print("🟡 DECODED JWT: $decoded");

          final dynamic userId =
              decoded["data"]?["user"]?["id"];

          /// 🔥 لو معندناش اسم — نجيب الاسم من endpoint مباشر
          if (userId != null) {
            try {
              final http.Response publicUserResponse =
                  await http.get(
                Uri.parse(
                    "$baseUrl/wp-json/wp/v2/users/$userId"),
              );

              print(
                  "🟣 PUBLIC USER STATUS: ${publicUserResponse.statusCode}");
              print(
                  "🟣 PUBLIC USER BODY: ${publicUserResponse.body}");

              if (publicUserResponse.statusCode == 200) {
                final publicData =
                    jsonDecode(publicUserResponse.body);

                return {
                  "id": userId,
                  "name": publicData["name"] ??
                      publicData["slug"] ??
                      "User",
                  "email": publicData["email"] ?? "",
                  "roles": ["customer"]
                };
              }
            } catch (_) {}
          }

          /// 🔁 fallback النهائي
          return {
            "id": userId,
            "name":
                decoded["data"]?["user"]?["display_name"] ??
                decoded["data"]?["user"]?["nicename"] ??
                "User",
            "email":
                decoded["data"]?["user"]?["email"] ?? "",
            "roles": ["customer"]
          };
        }
      }

      print("❌ FAILED TO FETCH USER FROM ALL METHODS");
      return null;

    } catch (e) {
      print("🔥 USER FETCH ERROR: $e");
      return null;
    }
  }
}