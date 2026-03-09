import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../features/cart/provider/cart_provider.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final dynamic product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  late PageController controller;
  int currentIndex = 0;
  bool showFullDescription = false;
  bool isFav = false;

  int quantity = 1;
  String? selectedColor;
  String? selectedSize;
  Map? selectedVariation;
  String? selectedPrice;
  String? selectedImage;

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
    controller = PageController();
    fetchVariations();
  }

  Future<void> fetchVariations() async {
    setState(() {
      isLoadingVariations = true;
    });

    final productId = widget.product['id'];

    final url = Uri.parse(
      "$baseUrl/wp-json/wc/v3/products/$productId/variations?consumer_key=$consumerKey&consumer_secret=$consumerSecret",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        variations = json.decode(response.body) ?? [];
        Set<String> colorSet = {};
        Set<String> sizeSet = {};

        for (var v in variations) {
          print("VARIATION DATA:");
          print(v);
          if (v["attributes"] != null) {
            for (var attr in v["attributes"]) {
              String name = attr["name"].toString().toLowerCase();
              String option = attr["option"].toString();

              if (name.contains("color")) {
                colorSet.add(option);
              }

              if (name.contains("size")) {
                sizeSet.add(option);
              }
            }
          }
        }

        colors = colorSet.toList();
        sizes = sizeSet.toList();
        sizes.sort((a, b) {
          int? aNum = int.tryParse(a);
          int? bNum = int.tryParse(b);

          if (aNum != null && bNum != null) {
            return aNum.compareTo(bNum);
          }

          return a.compareTo(b);
        });
        print("🎨 COLORS: $colors");
        print("👟 SIZES: $sizes");
        isLoadingVariations = false;
      });

      print("🔥 VARIATIONS COUNT: ${variations.length}");
      print("🔥 VARIATIONS DATA: $variations");
    } else {
      setState(() {
        isLoadingVariations = false;
      });

      print("❌ ERROR FETCHING VARIATIONS");
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool isSizeAvailable(String size) {
    if (selectedColor == null) return true;

    for (var v in variations) {
      String? colorValue;
      String? sizeValue;

      for (var attr in v["attributes"]) {
        String name = attr["name"].toString().toLowerCase();

        if (name.contains("color")) {
          colorValue = attr["option"];
        }

        if (name.contains("size")) {
          sizeValue = attr["option"];
        }
      }

      if (colorValue != null &&
          colorValue.toLowerCase() == selectedColor!.toLowerCase()) {
        if (sizeValue == size ||
            (sizeValue?.toLowerCase().contains("any") ?? false)) {
          return true;
        }
      }
    }

    return false;
  }

  bool isColorAvailable(String color) {
    if (selectedSize == null) return true;

    for (var v in variations) {
      String? colorValue;
      String? sizeValue;

      for (var attr in v["attributes"]) {
        String name = attr["name"].toString().toLowerCase();

        if (name.contains("color")) {
          colorValue = attr["option"];
        }

        if (name.contains("size")) {
          sizeValue = attr["option"];
        }
      }

      if (colorValue != null &&
          colorValue.toLowerCase() == color.toLowerCase()) {
        if (sizeValue == selectedSize ||
            (sizeValue?.toLowerCase().contains("any") ?? false)) {
          return true;
        }
      }
    }

    return false;
  }

  void updateSelectedVariation() {
    if (selectedColor == null || selectedSize == null) return;

    for (var v in variations) {
      String? colorValue;
      String? sizeValue;

      for (var attr in v["attributes"]) {
        String name = attr["name"].toString().toLowerCase();

        if (name.contains("color")) {
          colorValue = attr["option"];
        }

        if (name.contains("size")) {
          sizeValue = attr["option"];
        }
      }

      if (colorValue != null &&
          sizeValue != null &&
          colorValue.toLowerCase() == selectedColor!.toLowerCase() &&
          sizeValue.toLowerCase() == selectedSize!.toLowerCase()) {
        setState(() {
          selectedVariation = v;
          selectedPrice = v["price"];
          selectedImage = v["image"]?["src"];

          /// تحريك السلايدر للصورة الصحيحة
          if (selectedImage != null) {
            int imageIndex = images.indexWhere(
              (img) => img["src"] == selectedImage,
            );

            if (imageIndex != -1) {
              controller.animateToPage(
                imageIndex,
                duration: Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            }
          }
        });

        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print("FULL PRODUCT DATA:");
    print(widget.product);

    images = widget.product['images'] ?? [];

    double price = selectedPrice != null
        ? double.tryParse(selectedPrice!) ?? 0
        : double.tryParse(widget.product['price'] ?? "0") ?? 0;
    double regularPrice =
        double.tryParse(widget.product['regular_price'] ?? "0") ?? 0;

    bool isOnSale = regularPrice > price;

    double discountPercentage = isOnSale && regularPrice != 0
        ? ((regularPrice - price) / regularPrice) * 100
        : 0;

    double rating =
        double.tryParse(widget.product['average_rating'] ?? "0") ?? 0;

    int ratingCount =
        int.tryParse(widget.product['rating_count'].toString()) ?? 0;

    String shortDescription =
        widget.product['short_description']?.toString().replaceAll(
          RegExp(r'<[^>]*>'),
          '',
        ) ??
        "";

    String fullDescription =
        widget.product['description']?.toString().replaceAll(
          RegExp(r'<[^>]*>'),
          '',
        ) ??
        "";

    String vendorName = widget.product['vendor_name'] ?? "Official Store";

    String? vendorLogo = widget.product['vendor_logo'];

    bool inStock = (widget.product['stock_status'] ?? "instock") == "instock";

    int stockQty =
        int.tryParse(widget.product['stock_quantity']?.toString() ?? "0") ?? 0;

    String shippingDays = widget.product['shipping_days'] ?? "";
    String returnDays = widget.product['return_days'] ?? "";
    List paymentMethods = widget.product['allowed_payment_methods'] ?? [];

    bool hasShipping = shippingDays.isNotEmpty;
    bool hasReturn = returnDays.isNotEmpty;
    bool hasPayment = paymentMethods.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product['name']),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.red : Colors.black,
            ),
            onPressed: () {
              setState(() {
                isFav = !isFav;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE SLIDER
            Stack(
              children: [
                SizedBox(
                  height: 340,
                  child: PageView.builder(
                    controller: controller,
                    itemCount: images.length,
                    onPageChanged: (index) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Image.network(
                        selectedImage ?? images[index]['src'],
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),

                if (isOnSale)
                  Positioned(
                    top: 20,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        "-${discountPercentage.toStringAsFixed(0)}%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            /// THUMBNAILS
            if (images.length > 1)
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        controller.jumpToPage(index);
                        setState(() {
                          currentIndex = index;
                        });

                        /// ربط الصورة باللون
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

                          if (variationImage == imageUrl &&
                              colorValue != null) {
                            setState(() {
                              selectedColor = colorValue;
                            });

                            break;
                          }
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: currentIndex == index
                                ? Colors.black
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Image.network(
                          images[index]['src'],
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),

            /// NAME
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.product['name'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
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
                  Text(
                    selectedPrice != null
                        ? "$selectedPrice EGP"
                        : variations.isNotEmpty
                        ? "${variations.map((v) => double.tryParse(v["price"] ?? "0") ?? 0).reduce((a, b) => a > b ? a : b)} - ${variations.map((v) => double.tryParse(v["price"] ?? "0") ?? 0).reduce((a, b) => a < b ? a : b)} EGP"
                        : "$price EGP",
                    style: const TextStyle(
                      fontSize: 26,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(width: 10),
                  if (isOnSale)
                    Text(
                      "$regularPrice EGP",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// COLOR SELECTOR
            if (!isLoadingVariations &&
                variations.isNotEmpty &&
                colors.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    const Text(
                      "Color",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 10,
                      children: colors.map((color) {
                        bool available = isColorAvailable(color);

                        return ChoiceChip(
                          label: Text(color),
                          selected: selectedColor == color,

                          selectedColor: Colors.black,
                          labelStyle: TextStyle(
                            color: selectedColor == color
                                ? Colors.white
                                : Colors.black,
                          ),

                          onSelected: available
                              ? (_) {
                                  setState(() {
                                    selectedColor = color;

                                    /// reset size when color changes
                                    selectedSize = null;
                                    updateSelectedVariation();
                                  });
                                }
                              : null,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

            /// SIZE SELECTOR
            if (!isLoadingVariations &&
                variations.isNotEmpty &&
                sizes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    const Text(
                      "Size",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 10,
                      children: sizes.map((size) {
                        bool available = isSizeAvailable(size);

                        return ChoiceChip(
                          label: Text(size.toString()),
                          selected: selectedSize == size,
                          onSelected: available
                              ? (_) {
                                  setState(() {
                                    selectedSize = size;
                                    updateSelectedVariation();
                                  });
                                }
                              : null,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

            /// STOCK
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                inStock ? "In Stock" : "Out of Stock",
                style: TextStyle(
                  color: inStock ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// SHORT DESCRIPTION
            if (shortDescription.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  shortDescription,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            const SizedBox(height: 20),

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
                        const Icon(
                          Icons.refresh,
                          size: 18,
                          color: Colors.orange,
                        ),
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
                  Text(
                    quantity.toString(),
                    style: const TextStyle(fontSize: 18),
                  ),
                  IconButton(
                    onPressed: quantity < stockQty
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
                        backgroundColor: Colors.black,
                      ),
                      onPressed: inStock
                          ? () async {
                              final productId =
                                  int.tryParse(
                                    widget.product['id'].toString(),
                                  ) ??
                                  0;

                              await ref
                                  .read(cartProvider.notifier)
                                  .addToCart(productId, quantity);

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
                        backgroundColor: Colors.orange,
                      ),
                      onPressed: inStock ? () {} : null,
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
        ),
      ),
    );
  }
}
