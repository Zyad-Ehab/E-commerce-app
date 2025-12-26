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
      final cartRef = _firestore.collection('users').doc(_userId).collection('cart').doc(product.id.toString());
      final doc = await cartRef.get();
      if (doc.exists) {
        await cartRef.update({'quantity': FieldValue.increment(1)});
      } else {
        await cartRef.set({
          'productId': product.id,
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

  // Get Cart Stream
  Stream<List<Map<String, dynamic>>> getCartItems() {
    if (_userId == null) return Stream.value([]);
    return _firestore.collection('users').doc(_userId).collection('cart').orderBy('addedAt', descending: true).snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Remove Item
  Future<void> removeFromCart(int productId) async {
    if (_userId == null) return;
    await _firestore.collection('users').doc(_userId).collection('cart').doc(productId.toString()).delete();
  }
  
  // Checkout (Clear Cart)
  Future<void> clearCart() async {
    if (_userId == null) return;
    final batch = _firestore.batch();
    final snapshot = await _firestore.collection('users').doc(_userId).collection('cart').get();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}