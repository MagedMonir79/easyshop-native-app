import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesManager {
  static List<Map<String, dynamic>> favorites = [];

  // تحميل المفضلة من الجهاز
  static Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('favorites');

    if (data != null) {
      List decoded = jsonDecode(data);
      favorites = decoded.cast<Map<String, dynamic>>();
    }
  }

  // حفظ المفضلة في الجهاز
  static Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('favorites', jsonEncode(favorites));
  }

  // إضافة / إزالة من المفضلة
  static Future<void> toggleFavorite(Map<String, dynamic> product) async {
    final index = favorites.indexWhere((item) => item['id'] == product['id']);

    if (index >= 0) {
      favorites.removeAt(index);
    } else {
      favorites.add(product);
    }

    await saveFavorites(); // مهم جداً
  }

  // هل المنتج مفضل؟
  static bool isFavorite(int productId) {
    return favorites.any((item) => item['id'] == productId);
  }

  // ترجع كل المنتجات المفضلة
  static List<Map<String, dynamic>> getFavorites() {
    return favorites;
  }

  // تفريغ المفضلة (اختياري)
  static Future<void> clearFavorites() async {
    favorites.clear();
    await saveFavorites();
  }
}
