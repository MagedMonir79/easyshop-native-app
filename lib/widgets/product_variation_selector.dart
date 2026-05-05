import 'package:flutter/material.dart';
import '../../utils/color_map.dart';

Color getColor(String color) {
  return colorMap[color] ?? Colors.grey;
}

class ProductVariationSelector extends StatelessWidget {
  final List<String> colors;
  final List<String> sizes;
  final bool isLoadingVariations;

  final String? selectedColor;
  final String? selectedSize;
  final Map<String, String> selectedAttributes;

  final bool Function(String) isColorAvailable;
  final bool Function(String) isSizeAvailable;

  final Function(String) onColorSelected;
  final Function(String) onSizeSelected;

  /// 🔥 NEW
  final Map<String, List<String>> otherAttributes;
  final Function(String, String) onAttributeSelected;

  /// 🔥 الحل هنا
  final bool Function(String, String) isAttributeAvailable;

  const ProductVariationSelector({
    super.key,
    required this.colors,
    required this.sizes,
    required this.selectedAttributes,
    required this.isLoadingVariations,
    required this.selectedColor,
    required this.selectedSize,
    required this.isColorAvailable,
    required this.isSizeAvailable,
    required this.onColorSelected,
    required this.onSizeSelected,
    required this.otherAttributes,
    required this.onAttributeSelected,
    required this.isAttributeAvailable, // 👈 مهم
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// COLOR SELECTOR
        if (!isLoadingVariations && colors.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  "Color",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: colors.map((color) {
                    bool available = isColorAvailable(color);

                    return ChoiceChip(
                      label: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: getColor(color),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor == color
                                ? Colors.black
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                      ),
                      selected: selectedColor == color,
                      backgroundColor: Colors.transparent,
                      selectedColor: Colors.transparent,
                      shape: const CircleBorder(),
                      onSelected: available
                          ? (_) => onColorSelected(color)
                          : null,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

        /// SIZE SELECTOR
        if (!isLoadingVariations && sizes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  "Size",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                          ? (_) => onSizeSelected(size)
                          : null,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

        /// 🔥 OTHER ATTRIBUTES
        if (!isLoadingVariations && otherAttributes.isNotEmpty)
          ...otherAttributes.entries.map((entry) {
            String attrName = entry.key;
            List<String> values = entry.value;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    attrName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: values.map((val) {
                      bool isSelected = selectedAttributes[attrName] == val;

                      /// 🔥 الربط الصح
                      bool available = isAttributeAvailable(attrName, val);

                      return ChoiceChip(
                        label: Text(val),
                        selected: isSelected,
                        onSelected: available
                            ? (_) {
                                if (isSelected) {
                                  onAttributeSelected(attrName, "");
                                } else {
                                  onAttributeSelected(attrName, val);
                                }
                              }
                            : null,
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }).toList(),
      ],
    );
  }
}
