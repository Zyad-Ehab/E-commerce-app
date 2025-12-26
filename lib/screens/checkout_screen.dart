import 'package:flutter/material.dart';
import '../services/cart_service.dart';

class CheckoutScreen extends StatefulWidget {
  final double totalAmount;

  const CheckoutScreen({super.key, required this.totalAmount});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

enum PaymentMethod { visa, paypal, onsite }

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final CartService _cartService = CartService();

  // Text Controllers
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Payment State
  PaymentMethod _selectedMethod = PaymentMethod.visa;
  bool _isLoading = false;

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // 1. Prepare Order Data
    final orderData = {
      'amount': widget.totalAmount,
      'address': _addressController.text,
      'city': _cityController.text,
      'phone': _phoneController.text,
      'paymentMethod': _selectedMethod.name, // 'visa', 'paypal', or 'onsite'
      'status': 'pending',
    };

    // 2. Simulate Payment / Save Order
    try {
      // Create the order in Firestore and Clear Cart
      await _cartService.placeOrder(orderData);

      if (!mounted) return;

      // 3. Show Success Dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text("Order Placed!"),
          content: const Text("Your order has been successfully placed."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // Close Dialog
                Navigator.of(context).popUntil((route) => route.isFirst); // Go to Home
              },
              child: const Text("OK"),
            )
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Checkout", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Section 1: Delivery Address ---
              const Text("Delivery Address", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _buildTextField("Street Address", _addressController, Icons.location_on),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildTextField("City", _cityController, Icons.location_city)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTextField("Phone", _phoneController, Icons.phone, isNumber: true)),
                ],
              ),

              const SizedBox(height: 30),

              // --- Section 2: Payment Method ---
              const Text("Payment Method", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              _buildPaymentOption(PaymentMethod.visa, "Visa / Mastercard", Icons.credit_card),
              const SizedBox(height: 10),
              _buildPaymentOption(PaymentMethod.paypal, "PayPal", Icons.account_balance_wallet),
              const SizedBox(height: 10),
              _buildPaymentOption(PaymentMethod.onsite, "On-site / Cash", Icons.money),

              const SizedBox(height: 30),

              // --- Section 3: Summary ---
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Amount", style: TextStyle(fontSize: 16)),
                    Text("\$${widget.totalAmount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // --- Submit Button ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9775FA),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _submitOrder,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Confirm Order", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for Payment Options
  Widget _buildPaymentOption(PaymentMethod method, String title, IconData icon) {
    final isSelected = _selectedMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? const Color(0xFF9775FA) : Colors.grey.shade300, width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? const Color(0xFF9775FA).withOpacity(0.05) : Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF9775FA) : Colors.grey),
            const SizedBox(width: 15),
            Expanded(child: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
            if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF9775FA)),
          ],
        ),
      ),
    );
  }

  // Helper for Text Fields
  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
    );
  }
}