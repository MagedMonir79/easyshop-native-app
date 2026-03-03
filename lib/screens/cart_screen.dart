import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/cart_service.dart';
import '../features/cart/provider/cart_provider.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {

  @override
  Widget build(BuildContext context) {

    final cartState = ref.watch(cartProvider);

    var cart = cartState.items;
    double total = cartState.total;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cart"),
      ),
      body: cartState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : cart.isEmpty
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
                              item.image,
                              width: 50,
                            ),
                            title: Text(item.name),
                            subtitle:
                                Text("${item.price} EGP"),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await ref
                                    .read(cartProvider.notifier)
                                    .removeItem(item.productId);
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
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              child:
                                  const Text("Checkout"),
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