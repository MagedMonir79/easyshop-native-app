import 'package:flutter/material.dart';
import '../product_details_screen.dart';
import '../../widgets/product_image_slider.dart';
import '../../features/cart/provider/cart_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../cart_screen.dart';

final FlutterSecureStorage _storage = FlutterSecureStorage();

extension ProductDetailsUI on ProductDetailsScreenState {
  Widget buildImageSlider() {
    final regularPrice =
        double.tryParse(
          (selectedVariation?['regular_price'] ??
                  widget.product['regular_price'] ??
                  "0")
              .toString(),
        ) ??
        0;

    final salePrice =
        double.tryParse(
          (selectedVariation?['sale_price'] ??
                  widget.product['sale_price'] ??
                  widget.product['price'] ??
                  "0")
              .toString(),
        ) ??
        0;
    return ProductImageSlider(
      key: ValueKey(widget.product['price']),
      images: images,
      controller: controller,
      currentIndex: currentIndex,
      selectedImage: selectedImage,
      isOnSale: salePrice < regularPrice,
      regularPrice: regularPrice,
      salePrice: salePrice,
      isFavorite: isFav,
      onFavoritePressed: () async {
        print("❤️ FINAL CLICK WORKING");

        setState(() {
          isFav = !isFav;
        });

        final productId = widget.product['id'];

        final savedUserId = await _storage.read(key: "user_id");

        print("USER ID: $savedUserId");

        if (savedUserId == null) {
          print("❌ USER NOT LOGGED IN");
          return;
        }

        final response = await http.post(
          Uri.parse(
            "https://easyshop-eg.com/wp-json/easyshop/v1/wishlist/toggle",
          ),
          headers: {"Content-Type": "application/x-www-form-urlencoded"},
          body: {
            "product_id": productId.toString(),
            "user_id": savedUserId.toString(),
          },
        );

        print("WISHLIST RESPONSE: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFav ? "Added to wishlist ❤️" : "Removed from wishlist",
            ),
            backgroundColor: isFav ? Colors.green : Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      onPageChanged: (int index) {
        setState(() {
          currentIndex = index;
        });
      },
      onThumbnailTap: (index) {
        controller.jumpToPage(index);

        setState(() {
          currentIndex = index;
          selectedImage = images[index]['src'];
        });

        String imageUrl = images[index]["src"];

        for (var v in variations) {
          String? colorValue;
          String? variationImage = v["image"]?["src"];

          for (var attr in v["attributes"]) {
            String name = attr["name"].toString().toLowerCase();

            if (name.contains("color")) {
              colorValue = attr["option"];
            }
          }

          if (variationImage == imageUrl && colorValue != null) {
            setState(() {
              selectedColor = colorValue;
            });

            break;
          }
        }
      },
    );
  }

  Widget buildProductInfo(
    double price,
    double rating,
    int ratingCount,
    String vendorName,
    String? vendorLogo,
    double regularPrice,
    bool isOnSale,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// NAME
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            widget.product['name'],
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),

        /// Vendor
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              if (vendorLogo != null)
                CircleAvatar(
                  radius: 14,
                  backgroundImage: NetworkImage(vendorLogo),
                ),
              if (vendorLogo != null) const SizedBox(width: 8),
              Text(
                vendorName,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        /// Rating
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 5),
              Text("$rating ($ratingCount reviews)"),
            ],
          ),
        ),

        const SizedBox(height: 10),

        /// PRICE
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Builder(
                builder: (context) {
                  double displayPrice = price > 0
                      ? price
                      : double.tryParse(
                              (productData ?? widget.product)['price'] ?? "0",
                            ) ??
                            0;
                  double? regular = double.tryParse(
                    (productData ?? widget.product)['regular_price'] ?? "0",
                  );

                  double? sale = double.tryParse(
                    (productData ?? widget.product)['sale_price'] ?? "0",
                  );
                  if (selectedVariation != null) {
                    displayPrice =
                        double.tryParse(selectedVariation!["price"] ?? "0") ??
                        price;
                    regular = double.tryParse(
                      selectedVariation!["regular_price"] ?? "0",
                    );
                    sale = double.tryParse(
                      selectedVariation!["sale_price"] ?? "0",
                    );
                  }

                  final hasDiscount =
                      sale != null &&
                      sale > 0 &&
                      regular != null &&
                      sale < regular;

                  /// لو مفيش اختيار Variation → اعرض الرينج
                  if (selectedVariation == null && variations.isNotEmpty) {
                    final prices = variations
                        .map((v) => double.tryParse(v["price"] ?? "0") ?? 0)
                        .toList();

                    final minPrice = prices.reduce((a, b) => a < b ? a : b);
                    final maxPrice = prices.reduce((a, b) => a > b ? a : b);

                    return Text(
                      "${minPrice.toStringAsFixed(0)} - ${maxPrice.toStringAsFixed(0)} EGP",
                      style: const TextStyle(
                        fontSize: 26,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                  return Row(
                    children: [
                      Text(
                        "${(hasDiscount ? sale : displayPrice)?.toStringAsFixed(0)} EGP",
                        style: const TextStyle(
                          fontSize: 26,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(width: 10),

                      if (hasDiscount)
                        Text(
                          "${regular!.toStringAsFixed(0)} EGP",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildBottomSection(
    String shortDescription,
    String fullDescription,
    bool hasShipping,
    bool hasReturn,
    bool hasPayment,
    String shippingDays,
    String returnDays,
    List paymentMethods,
    int stockQty,
    bool inStock,
    bool canBuy,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// STOCK
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            (inStock)
                ? (stockQty > 0
                      ? (stockQty < 5 ? "Only $stockQty left 🔥" : "In Stock")
                      : "In Stock")
                : "Out of stock",

            style: TextStyle(
              color: !inStock
                  ? Colors.red
                  : (stockQty > 0 && stockQty < 5)
                  ? Colors.orange
                  : Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 12),

        /// SHORT DESCRIPTION
        if (shortDescription.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              shortDescription,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),

        const SizedBox(height: 12),

        /// FULL DESCRIPTION
        if (fullDescription.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedCrossFade(
                  firstChild: Text(
                    fullDescription,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  secondChild: Text(fullDescription),
                  crossFadeState: showFullDescription
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
                if (fullDescription.length > 150)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        showFullDescription = !showFullDescription;
                      });
                    },
                    child: Text(
                      showFullDescription ? "Show Less" : "Read More",
                    ),
                  ),
              ],
            ),
          ),

        const Divider(height: 40),

        /// DELIVERY + PAYMENT + RETURN
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasShipping)
                Row(
                  children: [
                    const Icon(
                      Icons.local_shipping,
                      size: 18,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Text("Delivery within $shippingDays days"),
                  ],
                ),

              if (hasShipping) const SizedBox(height: 8),

              if (hasPayment)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lock, size: 18, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text("Payment: ${paymentMethods.join(", ")}"),
                    ),
                  ],
                ),

              if (hasPayment) const SizedBox(height: 8),

              if (hasReturn)
                Row(
                  children: [
                    const Icon(Icons.refresh, size: 18, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text("$returnDays-day return policy"),
                  ],
                ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        /// QUANTITY
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              IconButton(
                onPressed: quantity > 1
                    ? () => setState(() => quantity--)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(quantity.toString(), style: const TextStyle(fontSize: 18)),
              IconButton(
                onPressed:
                    quantity <
                        ((widget.product['type'] == 'variable')
                            ? (selectedVariation != null ? stockQuantity : 0)
                            : (stockQty > 0 ? stockQty : 999))
                    ? () => setState(() => quantity++)
                    : null,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        /// BUTTONS
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canBuy
                        ? Colors.black
                        : Colors.grey.shade300,
                  ),
                  onPressed: canBuy
                      ? () async {
                          if (widget.product['type'] == 'variable' &&
                              (selectedColor == null || selectedSize == null)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please select color and size"),
                              ),
                            );
                            return;
                          }

                          if (stockQty == 0 && !inStock) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Out of stock")),
                            );
                            return;
                          }
                          final productId =
                              int.tryParse(widget.product['id'].toString()) ??
                              0;

                          await ref
                              .read(cartProvider.notifier)
                              .addToCart(productId, quantity);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CartScreen(),
                            ),
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Added to cart")),
                          );
                        }
                      : null,
                  child: const Text(
                    "Add to Cart",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canBuy
                        ? Colors.orange
                        : Colors.orange.shade200,
                  ),
                  onPressed: canBuy ? () {} : null,
                  child: const Text(
                    "Buy Now",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
