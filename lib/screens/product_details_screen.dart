import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../features/cart/provider/cart_provider.dart';
import '../widgets/product_image_slider.dart';
import '../widgets/product_variation_selector.dart';
import 'product_details/product_details_logic.dart';
import 'product_details/product_details_helpers.dart';
import 'product_details/product_details_ui.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final dynamic product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      ProductDetailsScreenState();
}

class ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  final _storage = const FlutterSecureStorage();
  late PageController controller;
  int currentIndex = 0;
  bool showFullDescription = false;
  bool isFav = false;
  Future<void> checkWishlist() async {
    final savedUserId = await _storage.read(key: "user_id");

    if (savedUserId == null) return;

    final response = await http.get(
      Uri.parse(
        "https://easyshop-eg.com/wp-json/easyshop/v1/wishlist/list?user_id=$savedUserId",
      ),
    );

    final data = jsonDecode(response.body);

    if (data["status"] == "success") {
      List wishlist = data["wishlist"];

      int productId = (productData ?? widget.product)["id"];

      if (wishlist.contains(productId)) {
        setState(() {
          isFav = true;
        });
      }
    }
  }

  Future<void> fetchProductDetails() async {
    final url = Uri.parse(
      "$baseUrl/wp-json/wc/v3/products/${(productData ?? widget.product)['id']}?consumer_key=$consumerKey&consumer_secret=$consumerSecret",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        productData = json.decode(response.body);
      });
    }
  }

  int quantity = 1;
  String? selectedColor;
  String? selectedSize;
  Map<String, dynamic>? selectedVariation;
  Map<String, dynamic>? productData;
  String? selectedPrice;
  String? selectedImage;
  int stockQuantity = 0;

  final String baseUrl = "https://www.easyshop-eg.com";
  final String consumerKey = "ck_938738261839e9dda4bc1b97834838f196a96d79";
  final String consumerSecret = "cs_8e6a23f3c51e84597cd6c7148e8ad7f303ce506c";

  List variations = [];
  List<String> colors = [];
  List<String> sizes = [];
  bool isLoadingVariations = false;

  List images = [];

  @override
  void initState() {
    super.initState();
    checkWishlist();
    fetchProductDetails();
    controller = PageController();
    fetchVariations();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = productData ?? widget.product;
    print("FULL PRODUCT DATA:");
    print(product);

    images = product['images'] ?? [];

    double price = double.tryParse(product['price']?.toString() ?? "0") ?? 0;

    double regularPrice =
        double.tryParse(product['regular_price']?.toString() ?? "0") ?? 0;

    bool isOnSale = regularPrice > price;

    double discountPercentage = isOnSale && regularPrice != 0
        ? ((regularPrice - price) / regularPrice) * 100
        : 0;

    double rating = double.tryParse(product['average_rating'] ?? "0") ?? 0;

    int ratingCount = int.tryParse(product['rating_count'].toString()) ?? 0;

    String shortDescription =
        product['short_description']?.toString().replaceAll(
          RegExp(r'<[^>]*>'),
          '',
        ) ??
        "";

    String fullDescription =
        product['description']?.toString().replaceAll(RegExp(r'<[^>]*>'), '') ??
        "";

    String vendorName = product['vendor_name'] ?? "Official Store";

    String? vendorLogo = product['vendor_logo'];

    bool inStock = selectedVariation != null
        ? (selectedVariation!['stock_status'] ?? "instock") == "instock"
        : (product['stock_status'] ?? "instock") == "instock";

    int stockQty = selectedVariation != null
        ? int.tryParse(
                selectedVariation!['stock_quantity']?.toString() ?? "0",
              ) ??
              0
        : int.tryParse(product['stock_quantity']?.toString() ?? "0") ?? 0;

    String shippingDays = product['shipping_days'] ?? "";
    String returnDays = product['return_days'] ?? "";
    List paymentMethods = product['allowed_payment_methods'] ?? [];

    bool hasShipping = shippingDays.isNotEmpty;
    bool hasReturn = returnDays.isNotEmpty;
    bool hasPayment = paymentMethods.isNotEmpty;
    bool isVariable = product['type'] == 'variable';

    bool manageStock = product['manage_stock'] == true;

    bool hasStock = manageStock ? stockQty > 0 : inStock;

    bool isExternal =
        product['external_url'] != null &&
        product['external_url'].toString().isNotEmpty;

    bool canBuy = isExternal
        ? true
        : hasStock &&
              (isVariable
                  ? (variations.isNotEmpty &&
                        selectedColor != null &&
                        selectedSize != null &&
                        selectedVariation != null)
                  : true);
    return Scaffold(
      appBar: AppBar(title: Text(product['name'])),
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchProductDetails();
          await fetchVariations();
        },

        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            buildImageSlider(),
            buildProductInfo(
              rating,
              price,
              ratingCount,
              vendorName,
              vendorLogo,
              regularPrice,
              isOnSale,
            ),
            const SizedBox(height: 10),
            ProductVariationSelector(
              colors: colors,
              sizes: sizes,
              isLoadingVariations: isLoadingVariations,
              selectedColor: selectedColor,
              selectedSize: selectedSize,

              isColorAvailable: isColorAvailable,
              isSizeAvailable: isSizeAvailable,

              onColorSelected: (color) {
                setState(() {
                  selectedColor = color;
                  selectedSize = null;
                  quantity = 1;
                });

                updateSelectedVariation();
              },

              onSizeSelected: (size) {
                setState(() {
                  selectedSize = size;
                  quantity = 1;
                });

                updateSelectedVariation();
              },
            ),
            buildBottomSection(
              shortDescription,
              fullDescription,
              hasShipping,
              hasReturn,
              hasPayment,
              shippingDays,
              returnDays,
              paymentMethods,
              stockQty,
              inStock,
              canBuy,
            ),
          ],
        ),
      ),
    );
  }
}
