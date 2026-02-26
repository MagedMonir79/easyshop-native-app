class CartService {
  static final CartService _instance = CartService._internal();

  factory CartService() {
    return _instance;
  }

  CartService._internal();

  List<dynamic> cartItems = [];

  void addToCart(dynamic product) {
    cartItems.add(product);
  }

  void removeFromCart(dynamic product) {
    cartItems.remove(product);
  }

  List<dynamic> getItems() {
    return cartItems;
  }

  double getTotal() {
    double total = 0;
    for (var item in cartItems) {
      total += double.tryParse(item['price'] ?? "0") ?? 0;
    }
    return total;
  }

  int getCount() {
    return cartItems.length;
  }
}
