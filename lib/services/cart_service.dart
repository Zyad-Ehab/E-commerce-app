import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // Add to Cart
  Future<void> addToCart(Product product) async {
    if (_userId == null) return;
    try {
      // Use product.id (int) converted to String for the document ID
      final cartRef = _firestore.collection('users').doc(_userId).collection('cart').doc(product.id.toString());
      final doc = await cartRef.get();
      if (doc.exists) {
        await cartRef.update({'quantity': FieldValue.increment(1)});
      } else {
        await cartRef.set({
          'productId': product.id, // Stored as int
          'title': product.title,
          'price': product.price,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'quantity': 1,
          'addedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Error adding to cart: $e');
    }
  }

  // Get Items
  Stream<List<Map<String, dynamic>>> getCartItems() {
    if (_userId == null) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('cart')
        .orderBy('addedAt', descending: true) // Optional: Sort by newest
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  //  Update Quantity
  Future<void> updateQuantity(int productId, int quantity) async {
    if (_userId == null) return;
    if (quantity < 1) return; // Prevent invalid quantity

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('cart')
          .doc(productId.toString()) // Convert int ID to String for lookup
          .update({'quantity': quantity});
    } catch (e) {
      print("Error updating quantity: $e");
    }
  }

  // Remove Item
  Future<void> removeFromCart(int productId) async {
    if (_userId == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('cart')
          .doc(productId.toString())
          .delete();
    } catch (e) {
      print("Error removing item: $e");
    }
  }

  // Clear Cart
  Future<void> clearCart() async {
    if (_userId == null) return;
    final batch = _firestore.batch();
    final snapshot = await _firestore.collection('users').doc(_userId).collection('cart').get();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> placeOrder(Map<String, dynamic> orderDetails) async {
    if (_userId == null) return;

    final batch = _firestore.batch();

    // 1. Create a reference for the new order
    final orderRef = _firestore.collection('users').doc(_userId).collection('orders').doc();

    // 2. Add timestamp
    orderDetails['date'] = FieldValue.serverTimestamp();

    // 3. (Optional) Move cart items to the order document so we know what they bought
    // For simplicity, we assume the backend handles this or we just save the total.
    // If you want to save items, you would fetch them here first.

    batch.set(orderRef, orderDetails);

    // 4. Clear the Cart
    final cartSnapshot = await _firestore.collection('users').doc(_userId).collection('cart').get();
    for (var doc in cartSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // 5. Commit all changes
    await batch.commit();
  }
}