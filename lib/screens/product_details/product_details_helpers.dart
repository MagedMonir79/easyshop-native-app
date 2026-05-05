import 'package:flutter/material.dart';
import '../product_details_screen.dart';

extension ProductDetailsHelpers on ProductDetailsScreenState {
  /// 🔥 إضافة (مفيش حذف)
  bool _isSameAttr(String attrName, String variationName) {
    String a = attrName.toLowerCase();
    String b = variationName.toLowerCase();
    return b.contains(a); // يدعم size / pa_size / attribute_pa_size
  }

  /// 🔥 إضافة جديدة (المفتاح الحقيقي للحل)
  String? _getSelectedValueForAttr(String variationAttrName) {
    String name = variationAttrName.toLowerCase();

    for (var key in selectedAttributes.keys) {
      if (_isSameAttr(key, name)) {
        return selectedAttributes[key];
      }
    }

    return null;
  }

  bool isSizeAvailable(String size) {
    if (!isAttributeAvailable("size", size)) return false;
    for (var v in variations) {
      bool match = true;

      for (var attr in v["attributes"]) {
        String name = attr["name"].toString().toLowerCase();
        String value = attr["option"].toString().toLowerCase();

        /// 🔥 تعديل (بدل containsKey)
        String? selectedValue = _getSelectedValueForAttr(attr["name"]);

        if (selectedValue != null) {
          if (value != selectedValue.toLowerCase()) {
            match = false;
            break;
          }
        }

        /// 🔥 نفس كودك زي ما هو
        if (_isSameAttr("size", name) && value != size.toLowerCase()) {
          match = false;
        }
      }

      if (match) return true;
    }

    return false;
  }

  bool isColorAvailable(String color) {
    if (!isAttributeAvailable("color", color)) return false;
    for (var v in variations) {
      bool match = true;

      for (var attr in v["attributes"]) {
        String name = attr["name"].toString().toLowerCase();
        String value = attr["option"].toString().toLowerCase();

        /// 🔥 تعديل (بدل containsKey)
        String? selectedValue = _getSelectedValueForAttr(attr["name"]);

        if (selectedValue != null) {
          if (value != selectedValue.toLowerCase()) {
            match = false;
            break;
          }
        }

        /// 🔥 نفس كودك زي ما هو
        if (_isSameAttr("color", name) && value != color.toLowerCase()) {
          match = false;
        }
      }

      if (match) return true;
    }

    return false;
  }

  /// 🔥 التعديل الوحيد هنا (فلترة ديناميك لكل المتغيرات)
  bool isAttributeAvailable(String attrName, String value) {
    for (var v in variations) {
      bool match = true;

      for (var attr in v["attributes"]) {
        String name = attr["name"].toString().toLowerCase();
        String val = attr["option"].toString().toLowerCase();

        if (_isSameAttr(attrName, name)) continue;

        /// 🔥 إضافة جديدة (اللي كانت ناقصة)
        String? selectedValue = _getSelectedValueForAttr(attr["name"]);
        if (selectedValue != null) {
          if (val != selectedValue.toLowerCase()) {
            match = false;
            break;
          }
        }

        /// 🔥 تعديل هنا (بدل ==)
        selectedAttributes.forEach((key, selectedVal) {
          if (_isSameAttr(key, name)) {
            if (selectedVal.toLowerCase() != val) {
              match = false;
            }
          }
        });

        if (!match) break;
      }

      bool hasValue = v["attributes"].any(
        (a) =>
            _isSameAttr(attrName, a["name"].toString()) &&
            a["option"].toString().toLowerCase() == value.toLowerCase(),
      );

      if (match && hasValue) return true;
    }

    return false;
  }

  void updateSelectedVariation() {
    for (var v in variations) {
      bool match = true;

      for (var attr in v["attributes"]) {
        String name = attr["name"].toString().toLowerCase();
        String value = attr["option"].toString().toLowerCase();

        String? selectedValue;

        selectedAttributes.forEach((key, val) {
          if (key.toLowerCase() == name) {
            selectedValue = val.toLowerCase();
          }
        });

        if (selectedValue != null && value != selectedValue) {
          match = false;
          break;
        }
      }

      if (match) {
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
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            }
          }
        });

        return;
      }
    }

    setState(() {
      selectedVariation = null;
      stockQuantity = 0;
    });
  }
}
