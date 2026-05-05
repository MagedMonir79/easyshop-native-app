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

        /// 🔥 NEW (تجميع باقي الـ attributes)
        Map<String, Set<String>> tempAttributes = {};

        for (var v in variations) {
          print("VARIATION DATA:");
          print(v);

          if (v["attributes"] != null) {
            for (var attr in v["attributes"]) {
              String name = attr["name"].toString().toLowerCase();
              String option = attr["option"].toString();

              if (name.contains("color")) {
                colorSet.add(option);
              } else if (name.contains("size")) {
                sizeSet.add(option);
              } else {
                /// 🔥 أي attribute تاني
                if (!tempAttributes.containsKey(attr["name"])) {
                  tempAttributes[attr["name"]] = {};
                }
                tempAttributes[attr["name"]]!.add(option);
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

        /// 🔥 تحويل باقي الـ attributes لـ List
        otherAttributes = tempAttributes.map(
          (key, value) => MapEntry(key, value.toList()),
        );

        print("🎨 COLORS: $colors");
        print("👟 SIZES: $sizes");
        print("📦 OTHER ATTRIBUTES: $otherAttributes");

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
