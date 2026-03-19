import 'package:flutter/material.dart';
import '../product_details_screen.dart';

extension ProductDetailsHelpers on ProductDetailsScreenState {
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

      /// حالة اختيار اللون فقط
      if (selectedColor != null && selectedSize == null) {
        if (colorValue != null &&
            colorValue.toLowerCase() == selectedColor!.toLowerCase()) {
          String? image = v["image"]?["src"];

          setState(() {
            selectedImage = image;
          });

          if (image != null) {
            int imageIndex = images.indexWhere((img) => img["src"] == image);

            if (imageIndex != -1) {
              setState(() {
                currentIndex = imageIndex;
              });

              controller.animateToPage(
                imageIndex,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            }
          }

          return;
        }
      }

      /// حالة اختيار اللون والمقاس
      if (selectedColor != null && selectedSize != null) {
        if (colorValue != null &&
            sizeValue != null &&
            colorValue.toLowerCase() == selectedColor!.toLowerCase() &&
            sizeValue.toLowerCase() == selectedSize!.toLowerCase()) {
          setState(() {
            selectedVariation = v;
            selectedPrice = v["price"];
            selectedImage = v["image"]?["src"];
            stockQuantity =
                int.tryParse(v["stock_quantity"]?.toString() ?? "0") ?? 0;

            if (selectedImage != null) {
              int imageIndex = images.indexWhere(
                (img) => img["src"] == selectedImage,
              );

              if (imageIndex != -1) {
                currentIndex = imageIndex;
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
    setState(() {
      selectedVariation = null;
      stockQuantity = 0;
    });
  }
}
