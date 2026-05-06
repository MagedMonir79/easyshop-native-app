import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final storage = const FlutterSecureStorage();

  List wishlistProducts = [];
  bool isLoading = true;

  final String baseUrl = "https://www.easyshop-eg.com";
  final String consumerKey = "ck_938738261839e9dda4bc1b97834838f196a96d79";
  final String consumerSecret = "cs_8e6a23f3c51e84597cd6c7148e8ad7f303ce506c";

  @override
  void initState() {
    super.initState();
    fetchWishlist();
  }

  Future<void> fetchWishlist() async {
    final userId = await storage.read(key: "user_id");

    if (userId == null) return;

    final res = await http.get(
      Uri.parse("$baseUrl/wp-json/easyshop/v1/wishlist/list?user_id=$userId"),
    );

    final data = jsonDecode(res.body);

    if (data["status"] == "success") {
      List ids = data["wishlist"];

      if (ids.isEmpty) {
        setState(() {
          wishlistProducts = [];
          isLoading = false;
        });
        return;
      }

      // نجيب المنتجات من WooCommerce
      final productsRes = await http.get(
        Uri.parse(
          "$baseUrl/wp-json/wc/v3/products?include=${ids.join(",")}&consumer_key=$consumerKey&consumer_secret=$consumerSecret",
        ),
      );

      setState(() {
        wishlistProducts = jsonDecode(productsRes.body);
        isLoading = false;
      });
    }
  }

  Future<void> removeFromWishlist(int productId) async {
    final userId = await storage.read(key: "user_id");

    await http.post(
      Uri.parse("$baseUrl/wp-json/easyshop/v1/wishlist/toggle"),
      body: {"product_id": productId.toString(), "user_id": userId.toString()},
    );

    fetchWishlist(); // تحديث الصفحة
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Wishlist ❤️")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : wishlistProducts.isEmpty
          ? const Center(child: Text("No favorites yet 😢"))
          : ListView.builder(
              itemCount: wishlistProducts.length,
              itemBuilder: (context, index) {
                final product = wishlistProducts[index];

                return ListTile(
                  leading: Image.network(
                    product["images"][0]["src"],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(product["name"]),
                  subtitle: Text("${product["price"]} جنيه"),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      removeFromWishlist(product["id"]);
                    },
                  ),
                );
              },
            ),
    );
  }
}
