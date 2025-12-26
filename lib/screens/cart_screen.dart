import 'package:flutter/material.dart';
import '../services/cart_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();

  void _processCheckout() async {
    // Mock Checkout
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Order Confirmed!"),
        content: const Text("Thank you for your purchase."),
        actions: [
          TextButton(
            onPressed: () async {
              await _cartService.clearCart(); // Clear Firestore cart
              if (mounted) {
                Navigator.pop(ctx); // Close Dialog
                Navigator.pop(context); // Go back to Home
              }
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cart", key: Key('cart_title'), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _cartService.getCartItems(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final items = snapshot.data!;
          
          if (items.isEmpty) return const Center(child: Text("Your cart is empty"));

          // Calculate Total
          double total = 0;
          for (var item in items) {
            total += (item['price'] * item['quantity']);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 15),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Row(
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(image: NetworkImage(item['imageUrl']), fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1),
                              Text("\$${item['price']}"),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _cartService.removeFromCart(item['productId']),
                            ),
                            Text("x${item['quantity']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        )
                      ],
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                color: const Color(0xFFF5F6FA),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("\$${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF9775FA))),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9775FA)),
                        onPressed: _processCheckout,
                        child: const Text("Checkout", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}