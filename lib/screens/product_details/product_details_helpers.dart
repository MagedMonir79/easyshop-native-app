import 'package:flutter/material.dart';
import '../product_details_screen.dart';

extension ProductDetailsHelpers on ProductDetailsScreenState {
  bool isSizeAvailable(String size) {
    if (!selectedAttributes.containsKey('Color')) return true;

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
          colorValue.toLowerCase() ==
              selectedAttributes['Color']!.toLowerCase()) {
        if (sizeValue == size ||
            (sizeValue?.toLowerCase().contains("any") ?? false)) {
          return true;
        }
      }
    }

    return false;
  }

  bool isColorAvailable(String color) {
    if (!selectedAttributes.containsKey('Size')) return true;

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
        if (sizeValue == selectedAttributes['Size'] ||
            (sizeValue?.toLowerCase().contains("any") ?? false)) {
          return true;
        }
      }
    }

    return false;
  }

  void updateSelectedVariation() {
    selectedVariation = null;

    for (var v in variations) {
      bool match = true;

      for (var attr in v["attributes"]) {
        String name = attr["name"].toString();
        String value = attr["option"].toString();

        if (selectedAttributes[name] != value) {
          match = false;
          break;
        }
      }

      if (match) {
        selectedVariation = v;

        selectedPrice = v["price"]?.toString();
        selectedImage = v["image"]?["src"];
        stockQuantity =
            int.tryParse(v["stock_quantity"]?.toString() ?? "0") ?? 0;

        /// تحديث الصورة
        if (selectedImage != null) {
          int imageIndex = images.indexWhere(
            (img) => img["src"] == selectedImage,
          );

          if (imageIndex != -1) {
            currentIndex = imageIndex;

            controller.animateToPage(
              imageIndex,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          }
        }

        break;
      }
    }

    /// لو مفيش match
    if (selectedVariation == null) {
      stockQuantity = 0;
    }

    setState(() {});
  }
}
