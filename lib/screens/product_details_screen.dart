import 'package:flutter/material.dart';
import '../services/cart_service.dart';


class ProductDetailsScreen extends StatefulWidget {
  final dynamic product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late PageController controller;
  int currentIndex = 0;

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

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product['name']),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔥 IMAGE SLIDER
            Stack(
              children: [
                SizedBox(
                  height: 300,
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

                /// 🔥 Discount Badge
                if (isOnSale)
                  Positioned(
                    top: 15,
                    left: 15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
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

            /// Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => Container(
                  margin: const EdgeInsets.all(4),
                  width: currentIndex == index ? 12 : 8,
                  height: currentIndex == index ? 12 : 8,
                  decoration: BoxDecoration(
                    color: currentIndex == index
                        ? Colors.black
                        : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// 📝 PRODUCT NAME
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.product['name'],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            /// 🏪 VENDOR NAME WITH ICON
            if (widget.product['vendor_name'] != null &&
                widget.product['vendor_name']
                    .toString()
                    .isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.storefront,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.product['vendor_name'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 10),

            /// ⭐ Rating
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 5),
                  Text(
                    "$rating ($ratingCount reviews)",
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// 💰 Price Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    "$price EGP",
                    style: const TextStyle(
                      fontSize: 22,
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
                        decoration:
                            TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 📄 DESCRIPTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.product['description']
                    .toString()
                    .replaceAll(RegExp(r'<[^>]*>'), ''),
                style: const TextStyle(fontSize: 14),
              ),
            ),

            const SizedBox(height: 30),

            /// 🛒 BUTTONS
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
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
  CartService().addToCart(widget.product);

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Added to cart"),
      duration: Duration(seconds: 1),
    ),
  );
},

                      child: const Text(
                        "Add to Cart",
                        style:
                            TextStyle(color: Colors.white),
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
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text(
                        "Buy Now",
                        style:
                            TextStyle(color: Colors.white),
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
