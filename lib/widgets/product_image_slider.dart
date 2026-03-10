import 'package:flutter/material.dart';

class ProductImageSlider extends StatelessWidget {
  final List images;
  final PageController controller;
  final int currentIndex;
  final Function(int) onPageChanged;
  final Function(int) onThumbnailTap;
  final bool isOnSale;
  final double discountPercentage;
  final String? selectedImage;

  const ProductImageSlider({
    super.key,
    required this.images,
    required this.controller,
    required this.currentIndex,
    required this.onPageChanged,
    required this.onThumbnailTap,
    required this.isOnSale,
    required this.discountPercentage,
    required this.selectedImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// IMAGE SLIDER
        Stack(
          children: [
            SizedBox(
              height: 340,
              child: PageView.builder(
                controller: controller,
                itemCount: images.length,
                onPageChanged: onPageChanged,
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
                    onThumbnailTap(index);
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
      ],
    );
  }
}
