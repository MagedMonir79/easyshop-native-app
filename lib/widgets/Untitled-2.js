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
                        controller.jumpToPage(index);
                        setState(() {
                          currentIndex = index;
                        });

                        /// ربط الصورة باللون
                        String imageUrl = images[index]["src"];

                        for (var v in variations) {
                          String? colorValue;
                          String? variationImage = v["image"]?["src"];

                          for (var attr in v["attributes"]) {
                            String name = attr["name"].toString().toLowerCase();

                            if (name.contains("color")) {
                              colorValue = attr["option"];
                            }
                          }

                          if (variationImage == imageUrl &&
                              colorValue != null) {
                            setState(() {
                              selectedColor = colorValue;
                            });

                            break;
                          }
                        }
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
