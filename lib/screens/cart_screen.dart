import 'package:flutter/material.dart';
import '../services/cart_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  @override
  Widget build(BuildContext context) {
    var cart = CartService().getItems();
    double total = CartService().getTotal();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cart"),
      ),
      body: cart.isEmpty
          ? const Center(child: Text("Your cart is empty"))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      var item = cart[index];
                      return ListTile(
                        leading: Image.network(
                          item['images'][0]['src'],
                          width: 50,
                        ),
                        title: Text(item['name']),
                        subtitle: Text("${item['price']} EGP"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              CartService().removeFromCart(item);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        "Total: $total EGP",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text("Checkout"),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
