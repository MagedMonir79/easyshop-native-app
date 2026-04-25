import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // ✅ إضافة جديدة

import 'product_details_screen.dart';
import 'cart_screen.dart';
import '../features/auth/view/login_screen.dart';
import '../features/auth/provider/auth_provider.dart';
import '../features/user/provider/user_provider.dart';

class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({super.key});

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  final String baseUrl = "https://www.easyshop-eg.com";
  final String consumerKey = "ck_938738261839e9dda4bc1b97834838f196a96d79";
  final String consumerSecret = "cs_8e6a23f3c51e84597cd6c7148e8ad7f303ce506c";

  List products = [];

  // ✅ إضافة SecureStorage
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? storedUserName; // ✅ اسم مخزن fallback

  @override
  void initState() {
    super.initState();
    fetchProducts();
    _loadStoredUserName(); // ✅ تحميل الاسم المخزن
  }

  Future<void> _loadStoredUserName() async {
    final name = await _storage.read(key: "user_name");

    if (mounted) {
      setState(() {
        storedUserName = name;
      });
    }

    print("🟢 STORED NAME FROM SCREEN: $name");
  }

  Future<void> fetchProducts() async {
    final url = Uri.parse(
      "$baseUrl/wp-json/wc/v3/products?consumer_key=$consumerKey&consumer_secret=$consumerSecret",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        products = json.decode(response.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = ref.watch(userProvider);

    print("🟢 AUTH STATE: ${authState.isAuthenticated}");
    print("🟢 USER STATE: ${user?.name}");

    // ✅ تحديد الاسم النهائي المعروض
    String displayName = "Guest";

    if (authState.isAuthenticated) {
      if (user != null && user.name != "User") {
        displayName = user.name;
      } else if (storedUserName != null && storedUserName!.isNotEmpty) {
        displayName = storedUserName!;
      } else {
        displayName = "User";
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("EasyShop"),
            Text(
              "$displayName 👤",
              style: TextStyle(
                fontSize: 12,
                color: authState.isAuthenticated ? Colors.green : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.person,
              color: authState.isAuthenticated ? Colors.green : Colors.grey,
            ),
            onPressed: () {
              if (!authState.isAuthenticated) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Welcome $displayName ✅")),
                );
              }
            },
          ),

          if (authState.isAuthenticated)
            TextButton(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                setState(() {
                  storedUserName = null;
                });
              },
              child: const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
        ],
      ),

      body: products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsScreen(
                          product: product,
                          key: ValueKey(product['id']), // 🔥 ده الحل
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.network(
                              product['images'].isNotEmpty
                                  ? product['images'][0]['src']
                                  : "",
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(child: Icon(Icons.image));
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            product['name'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "${product['price']} EGP",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
