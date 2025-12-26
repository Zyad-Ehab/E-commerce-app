import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import 'checkout_screen.dart'; // Ensure this file exists from the previous step

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();

  // Navigation to Checkout Page
  void _goToCheckout(double totalAmount) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(totalAmount: totalAmount),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Cart", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _cartService.getCartItems(),
        builder: (context, snapshot) {
          // 1. Safety Checks
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Something went wrong: ${snapshot.error}"));
          }
          final items = snapshot.data ?? [];

          // Empty State
          if (items.isEmpty) {
            return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 60, color: Colors.grey),
                    SizedBox(height: 10),
                    Text("Your cart is empty", style: TextStyle(color: Colors.grey)),
                  ],
                )
            );
          }

          // 2. Safe Total Calculation
          double total = 0;
          for (var item in items) {
            final price = (item['price'] as num?)?.toDouble() ?? 0.0;
            final qty = (item['quantity'] as num?)?.toInt() ?? 1;
            total += (price * qty);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    final item = items[index];

                    // Safe Data Extraction
                    final int productId = item['productId']; // Ensure this matches your Service (int)
                    final String title = item['title'] ?? 'Unknown';
                    final String imageUrl = item['imageUrl'] ?? '';
                    final double price = (item['price'] as num?)?.toDouble() ?? 0.0;
                    final int quantity = (item['quantity'] as num?)?.toInt() ?? 1;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // IMAGE
                        Container(
                          width: 90, height: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[100],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, error, stack) => const Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),

                        // DETAILS
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis
                              ),
                              const SizedBox(height: 5),
                              Text("\$${price.toStringAsFixed(2)}", style: TextStyle(color: Colors.grey[600])),
                              const SizedBox(height: 10),

                              // QUANTITY CONTROLS
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    height: 35,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.white,
                                    ),
                                    child: Row(
                                      children: [
                                        // Minus / Delete Button
                                        InkWell(
                                          onTap: () {
                                            if (quantity > 1) {
                                              _cartService.updateQuantity(productId, quantity - 1);
                                            } else {
                                              _cartService.removeFromCart(productId);
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            child: Icon(
                                              quantity == 1 ? Icons.delete_outline : Icons.remove,
                                              size: 18,
                                              color: quantity == 1 ? Colors.red : Colors.black,
                                            ),
                                          ),
                                        ),

                                        // Quantity Text
                                        Text(
                                          "$quantity",
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),

                                        // Plus Button
                                        InkWell(
                                          onTap: () {
                                            _cartService.updateQuantity(productId, quantity + 1);
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 10),
                                            child: Icon(Icons.add, size: 18),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Remove Text
                                  InkWell(
                                    onTap: () => _cartService.removeFromCart(productId),
                                    child: Text("Remove", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // TOTAL & CHECKOUT SECTION
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6FA),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("\$${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF9775FA))),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // CHECKOUT BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9775FA),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                        ),
                        // Navigate to Checkout Screen
                        onPressed: items.isEmpty ? null : () => _goToCheckout(total),
                        child: const Text("Checkout", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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