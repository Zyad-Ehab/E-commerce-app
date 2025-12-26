import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';
import '../models/product.dart';
import 'welcome_screen.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Key to open drawer
  
  // Data Variables
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  // 1. Fetch Products from API
  Future<void> _loadProducts() async {
    try {
      final products = await _apiService.fetchProducts();
      if (mounted) {
        setState(() {
          _allProducts = products;
          _filteredProducts = products; // Initially show all
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // 2. Search Logic
  void _runFilter(String keyword) {
    List<Product> results = [];
    if (keyword.isEmpty) {
      results = _allProducts;
    } else {
      results = _allProducts
          .where((product) => product.title.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }
    setState(() {
      _filteredProducts = results;
    });
  }

  // 3. Logout Logic
  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      key: _scaffoldKey, // Assign the key to Scaffold
      backgroundColor: Colors.white,
      
      // --- Side Menu (Drawer) ---
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF9775FA)), // Laza Purple
              accountName: const Text("Laza User"),
              accountEmail: Text(user?.email ?? "No Email"),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Color(0xFF9775FA)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag, color: Colors.black),
              title: const Text("My Cart"),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite, color: Colors.black),
              title: const Text("Favorites"),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),

      // --- Top Bar ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // Menu Button
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          // Quick Cart Button
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
          )
        ],
      ),

      // --- Main Body ---
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Hello", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const Text("Welcome to Laza.", style: TextStyle(fontSize: 15, color: Colors.grey)),
            const SizedBox(height: 20),
            
            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: _runFilter,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                hintText: "Search...",
                filled: true,
                fillColor: const Color(0xFFF5F6FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Product Grid
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF9775FA)))
                  : _errorMessage != null
                      ? Center(child: Text("Error: $_errorMessage"))
                      : _filteredProducts.isEmpty
                          ? const Center(child: Text("No products found"))
                          : GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.65, // Controls card height
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15,
                              ),
                              itemCount: _filteredProducts.length,
                              itemBuilder: (context, index) {
                                return _buildProductCard(_filteredProducts[index]);
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Product Card Helper ---
  Widget _buildProductCard(Product product) {
    return GestureDetector(
      key: const Key('product_card_0'),
      onTap: () {
        // Navigate to Product Detail Screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: const Color(0xFFF5F6FA),
                image: DecorationImage(
                  image: NetworkImage(product.imageUrl),
                  fit: BoxFit.cover,
                  onError: (e, s) => const Icon(Icons.error),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            product.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(
            "\$${product.price}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }
}