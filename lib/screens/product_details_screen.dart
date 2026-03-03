import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/cart/provider/cart_provider.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final dynamic product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState
    extends ConsumerState<ProductDetailsScreen> {

  late PageController controller;
  int currentIndex = 0;
  bool showFullDescription = false;
  bool isFav = false;

  int selectedQuantity = 1;

  @override
  void initState() {
    super.initState();
    controller = PageController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    List images = widget.product['images'];

    double price =
        double.tryParse(widget.product['price'] ?? "0") ?? 0;

    double regularPrice =
        double.tryParse(widget.product['regular_price'] ?? "0") ?? 0;

    bool isOnSale = regularPrice > price;

    double discountPercentage =
        isOnSale ? ((regularPrice - price) / regularPrice) * 100 : 0;

    double rating =
        double.tryParse(widget.product['average_rating'] ?? "0") ?? 0;

    int ratingCount =
        int.tryParse(widget.product['rating_count'].toString()) ?? 0;

    String shortDescription = widget.product['short_description']
            ?.toString()
            .replaceAll(RegExp(r'<[^>]*>'), '') ?? "";

    String fullDescription = widget.product['description']
            ?.toString()
            .replaceAll(RegExp(r'<[^>]*>'), '') ?? "";

    String vendorName =
        widget.product['vendor_name'] ?? "Official Store";

    String sku = widget.product['sku'] ?? "N/A";

    bool inStock =
        (widget.product['stock_status'] ?? "instock") == "instock";

    int stockQuantity =
        widget.product['stock_quantity'] ?? 999;

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
          )
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
                        images[index]['src'],
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
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        "-${discountPercentage.toStringAsFixed(0)}%",
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),

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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.storefront,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    vendorName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.verified,
                      size: 14, color: Colors.blue),
                ],
              ),
            ),

            /// Rating
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.star,
                      color: Colors.amber, size: 18),
                  const SizedBox(width: 5),
                  Text(
                    "$rating ($ratingCount reviews)",
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// PRICE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (isOnSale)
                    Text(
                      "$regularPrice EGP  ",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        decoration:
                            TextDecoration.lineThrough,
                      ),
                    ),
                  Text(
                    "$price EGP",
                    style: const TextStyle(
                      fontSize: 26,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ✨ SHORT DESCRIPTION (موجود زي ما هو)
            if (shortDescription.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  shortDescription,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            /// 📄 FULL DESCRIPTION (متلمسش)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16),
              child: AnimatedCrossFade(
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
            ),

            if (fullDescription.length > 150)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      showFullDescription =
                          !showFullDescription;
                    });
                  },
                  child: Text(
                    showFullDescription
                        ? "Show Less"
                        : "Read More",
                  ),
                ),
              ),

            const SizedBox(height: 30),

            /// BUTTONS (اتعدل بس هنا)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [

                  /// Quantity + Add To Cart جنب بعض
                  Row(
                    children: [

                      /// Quantity
                      Row(
                        children: [
                          GestureDetector(
                            onTap: selectedQuantity > 1
                                ? () => setState(() => selectedQuantity--)
                                : null,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius:
                                    BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.remove,
                                  color: Colors.white,
                                  size: 18),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            selectedQuantity.toString(),
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: selectedQuantity <
                                    stockQuantity
                                ? () => setState(
                                    () => selectedQuantity++)
                                : null,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius:
                                    BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.add,
                                  color: Colors.white,
                                  size: 18),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: 12),

                      /// Add To Cart
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.black,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(10),
                              ),
                            ),
                            onPressed: () async {
                              final productId =
                                  int.tryParse(widget
                                              .product['id']
                                              .toString()) ??
                                      0;

                              await ref
                                  .read(cartProvider
                                      .notifier)
                                  .addToCart(
                                      productId,
                                      selectedQuantity);

                              ScaffoldMessenger.of(
                                      context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Added to cart"),
                                ),
                              );
                            },
                            child: const Text(
                              "Add to Cart",
                              style: TextStyle(
                                  color:
                                      Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// Buy Now (موجود زي ما هو)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.orange,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text(
                        "Buy Now",
                        style: TextStyle(
                            color: Colors.white),
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