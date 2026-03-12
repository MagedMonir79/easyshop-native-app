import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../product_details_screen.dart';

extension ProductDetailsLogic on ProductDetailsScreenState {
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

        /// ترتيب الألوان حسب ترتيب الصور
        colors.sort((a, b) {
          int indexA = images.indexWhere((img) {
            return variations.any(
              (v) =>
                  v["image"]?["src"] == img["src"] &&
                  v["attributes"].any(
                    (attr) =>
                        attr["name"].toString().toLowerCase().contains(
                          "color",
                        ) &&
                        attr["option"].toString().toLowerCase() ==
                            a.toLowerCase(),
                  ),
            );
          });

          int indexB = images.indexWhere((img) {
            return variations.any(
              (v) =>
                  v["image"]?["src"] == img["src"] &&
                  v["attributes"].any(
                    (attr) =>
                        attr["name"].toString().toLowerCase().contains(
                          "color",
                        ) &&
                        attr["option"].toString().toLowerCase() ==
                            b.toLowerCase(),
                  ),
            );
          });

          return indexA.compareTo(indexB);
        });
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
}
