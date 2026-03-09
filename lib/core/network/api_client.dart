import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final String baseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiClient({required this.baseUrl});

  /// 🔐 تجهيز الهيدر وإضافة التوكن لو موجود
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: "token");

    final headers = {'Content-Type': 'application/json'};

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// 📥 GET Request
  Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl$endpoint');

    return await http.get(uri, headers: headers);
  }

  /// 📤 POST Request
  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl$endpoint');

    return await http.post(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  /// 🗑 DELETE Request
  Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl$endpoint');

    return await http.delete(uri, headers: headers);
  }

  /// ✏ PUT Request
  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl$endpoint');

    return await http.put(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }
}
