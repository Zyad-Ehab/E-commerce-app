import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/favorites_service.dart';
import 'product_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favoritesService = FavoritesService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Favorites", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0, leading: const BackButton(color: Colors.black)),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _favoritesService.getFavorites(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final items = snapshot.data!;
          if (items.isEmpty) return const Center(child: Text("No favorites yet"));

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.65, crossAxisSpacing: 15, mainAxisSpacing: 15),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final data = items[index];
              final product = Product(id: data['productId'], title: data['title'], price: (data['price'] as num).toDouble(), description: data['description'], imageUrl: data['imageUrl']);
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), image: DecorationImage(image: NetworkImage(product.imageUrl), fit: BoxFit.cover)))),
                    Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text("\$${product.price}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}