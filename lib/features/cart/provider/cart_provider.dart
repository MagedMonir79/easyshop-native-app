import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../auth/provider/auth_provider.dart';
import '../../auth/data/auth_service.dart';

final cartProvider =
    StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier(ref);
});

class CartState {
  final bool isLoading;
  final List<CartItem> items;
  final double total;
  final String? error;

  const CartState({
    required this.isLoading,
    required this.items,
    required this.total,
    this.error,
  });

  factory CartState.initial() {
    return const CartState(
      isLoading: false,
      items: [],
      total: 0.0,
    );
  }

  CartState copyWith({
    bool? isLoading,
    List<CartItem>? items,
    double? total,
    String? error,
  }) {
    return CartState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      total: total ?? this.total,
      error: error,
    );
  }
}

class CartItem {
  final int productId;
  final String name;
  final int quantity;
  final double price;
  final String image;

  CartItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.image,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId:
          int.tryParse(json['product_id'].toString()) ?? 0,
      name: json['name'] ?? '',
      quantity:
          int.tryParse(json['quantity'].toString()) ?? 0,
      price:
          double.tryParse(json['price'].toString()) ?? 0.0,
      image: json['image'] ?? '',
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  final Ref ref;

  CartNotifier(this.ref) : super(CartState.initial());

  String get baseUrl =>
      "https://www.easyshop-eg.com/wp-json/easyshop/v1";

  Future<Map<String, String>> _headers() async {
    final authService = ref.read(authServiceProvider);
    return await authService.getAuthHeaders();
  }

  /// 🟢 LOAD CART
  Future<void> loadCart() async {
    try {
      print("🟡 LOAD CART STARTED");

      state = state.copyWith(isLoading: true, error: null);

      final response = await http.get(
        Uri.parse("$baseUrl/cart"),
        headers: await _headers(),
      );

      print("🟢 STATUS CODE: ${response.statusCode}");
      print("🟢 RAW BODY: ${response.body}");

      if (response.statusCode == 200 &&
          response.body.isNotEmpty) {

        final data = jsonDecode(response.body);

        if (data['items'] == null) {
          print("⚠️ ITEMS NULL FROM SERVER");
          state = state.copyWith(
              isLoading: false,
              items: [],
              total: 0.0);
          return;
        }

        final List<CartItem> loadedItems =
            (data['items'] as List)
                .map((e) => CartItem.fromJson(e))
                .toList();

        final total =
            double.tryParse(data['total'].toString()) ??
                0.0;

        print(
            "🟢 ITEMS COUNT: ${loadedItems.length}");
        print("🟢 TOTAL: $total");

        state = state.copyWith(
          isLoading: false,
          items: loadedItems,
          total: total,
        );
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        state = state.copyWith(
          isLoading: false,
          error: "Failed to load cart",
        );
      }
    } catch (e) {
      print("❌ LOAD CART ERROR: $e");
      state = state.copyWith(
          isLoading: false,
          error: e.toString());
    }
  }

  /// ➕ ADD TO CART
  Future<void> addToCart(
      int productId, int quantity) async {
    try {
      print("🟡 ADDING PRODUCT: $productId");

      final response = await http.post(
        Uri.parse("$baseUrl/cart/add"),
        headers: await _headers(),
        body: jsonEncode({
          "product_id": productId,
          "quantity": quantity,
        }),
      );

      print("🟢 ADD RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        await loadCart();
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      }
    } catch (e) {
      print("❌ ADD ERROR: $e");
      state = state.copyWith(error: e.toString());
    }
  }

  /// 🔄 UPDATE QUANTITY
  Future<void> updateQuantity(
      int productId, int quantity) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/cart/update"),
        headers: await _headers(),
        body: jsonEncode({
          "product_id": productId,
          "quantity": quantity,
        }),
      );

      if (response.statusCode == 200) {
        await loadCart();
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// ❌ REMOVE ITEM
  Future<void> removeItem(int productId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/cart/remove"),
        headers: await _headers(),
        body: jsonEncode({
          "product_id": productId,
        }),
      );

      if (response.statusCode == 200) {
        await loadCart();
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 🧹 CLEAR LOCAL CART
  void clearCart() {
    print("🧹 LOCAL CART CLEARED");
    state = CartState.initial();
  }

  /// 🔐 لو التوكن بايظ
  void _handleUnauthorized() {
    ref.read(authProvider.notifier).logout();
  }
}