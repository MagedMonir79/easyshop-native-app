import 'package:flutter/material.dart';

class ProductImageSlider extends StatelessWidget {
  final List images;
  final PageController controller;
  final int currentIndex;
  final Function(int) onPageChanged;
  final Function(int) onThumbnailTap;
  final bool isOnSale;
  final double regularPrice;
  final double salePrice;
  final String? selectedImage;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;

  const ProductImageSlider({
    super.key,
    required this.images,
    required this.controller,
    required this.currentIndex,
    required this.onPageChanged,
    required this.onThumbnailTap,
    required this.isOnSale,
    required this.regularPrice,
    required this.salePrice,
    required this.selectedImage,
    required this.isFavorite,
    required this.onFavoritePressed,
  });

  double get discountPercentage {
    if (!isOnSale || regularPrice <= 0) return 0;
    final discount = ((regularPrice - salePrice) / regularPrice) * 100;
    return discount < 1 ? 0 : discount;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// MAIN IMAGE
        SizedBox(
          height: 360,
          width: double.infinity,
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

        /// GRADIENT LIKE AMAZON
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.4), Colors.transparent],
              ),
            ),
          ),
        ),

        /// FAVORITE BUTTON (TOP RIGHT)
        Positioned(
          top: 20,
          right: 20,
          child: GestureDetector(
            onTap: onFavoritePressed,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.black,
                size: 22,
              ),
            ),
          ),
        ),

        /// DISCOUNT BADGE
        if (isOnSale)
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
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

        /// THUMBNAILS INSIDE IMAGE
        if (images.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      onThumbnailTap(index);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: currentIndex == index
                              ? Colors.white
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          images[index]['src'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
