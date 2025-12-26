import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../services/favorites_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final CartService _cartService = CartService();
  final FavoritesService _favoritesService = FavoritesService();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  void _checkFavoriteStatus() async {
    bool exists = await _favoritesService.isFavorite(widget.product.id);
    if (mounted) setState(() => _isFavorite = exists);
  }

  void _toggleFavorite() async {
    if (_isFavorite) {
      await _favoritesService.removeFromFavorites(widget.product.id);
    } else {
      await _favoritesService.addToFavorites(widget.product);
    }
    setState(() => _isFavorite = !_isFavorite);
  }

  void _addToCart() async {
    await _cartService.addToCart(widget.product);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Added to Cart"), backgroundColor: Color(0xFF9775FA)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: const Color(0xFFF5F6FA),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(widget.product.imageUrl, fit: BoxFit.cover),
            ),
            leading: const BackButton(color: Colors.black),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Men's Clothing", // Category placeholder
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                      ),
                      Text(
                        "Price",
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.title,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        "\$${widget.product.price}",
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  Text(
                    widget.product.description,
                    style: const TextStyle(color: Colors.grey, height: 1.5),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9775FA),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            key: const Key('add_to_cart_btn'),
            onPressed: _addToCart,
            child: const Text("Add to Cart", style: TextStyle(color: Colors.white, fontSize: 17)),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: _toggleFavorite,
        child: Icon(
          _isFavorite ? Icons.favorite : Icons.favorite_border,
          color: _isFavorite ? Colors.red : Colors.grey,
        ),
      ),
    );
  }
}