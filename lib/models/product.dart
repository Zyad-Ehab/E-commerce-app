class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String imageUrl;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Platzi API returns images as a list of strings ["url1", "url2"]
    // We take the first one and clean it up if needed
    String image = "https://i.imgur.com/6Iib02Y.png"; // Default placeholder
    
    if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      String rawUrl = json['images'][0];
      // Fix for some broken Platzi URLs containing brackets
      if (rawUrl.startsWith('["') && rawUrl.endsWith('"]')) {
         rawUrl = rawUrl.substring(2, rawUrl.length - 2);
      }
      image = rawUrl;
    }

    return Product(
      id: json['id'],
      title: json['title'] ?? 'No Title',
      price: (json['price'] as num).toDouble(),
      description: json['description'] ?? '',
      imageUrl: image,
    );
  }
}