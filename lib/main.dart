
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MiniKatalogApp());
}

class Product {
  final String name;
  final String category;
  final String price;
  final String description;
  final String imageUrl;

  const Product({
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name']?.toString() ?? 'İsimsiz ürün',
      category: json['category']?.toString() ?? 'Diğer',
      price: json['price']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}

class MiniKatalogApp extends StatelessWidget {
  const MiniKatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mini Katalog',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4255D4),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> products = [];
  final List<Product> cart = [];
  String searchText = '';
  String selectedCategory = 'Tümü';
  bool isLoading = true;
  String? errorMessage;

  final List<String> categories = [
    'Tümü',
    'Elektronik',
    'Bilgisayar',
    'Ses Sistemleri',
    'Fotoğrafçılık',
    'Giyilebilir Teknoloji',
  ];

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      final jsonString = await rootBundle.loadString(
        'lib/assets/products.json',
      );
      final decoded = jsonDecode(jsonString) as List<dynamic>;
      final loadedProducts = decoded
          .map((item) => Product.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList();

      if (!mounted) return;

      setState(() {
        products = loadedProducts;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'Ürünler yüklenemedi. products.json dosyasını kontrol et.';
      });

      debugPrint('JSON yükleme hatası: $e');
    }
  }

  void addToCart(Product product) {
    setState(() {
      cart.add(product);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} sepete eklendi.')),
    );
  }

  void removeFromCart(Product product) {
    setState(() {
      cart.remove(product);
    });
  }

  void openCart() {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CartPage(
          cart: cart,
          onRemove: removeFromCart,
        ),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = products.where((product) {
      final matchesSearch = product.name
          .toLowerCase()
          .contains(searchText.trim().toLowerCase());

      final matchesCategory = selectedCategory == 'Tümü' ||
          product.category == selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MINI KATALOG',
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 2,
                color: Color(0xFF4255D4),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Keşfet',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sepeti aç',
            onPressed: openCart,
            icon: Badge(
              label: Text('${cart.length}'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            errorMessage!,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () {
                              setState(() {
                                isLoading = true;
                                errorMessage = null;
                              });
                              loadProducts();
                            },
                            child: const Text('Tekrar dene'),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              searchText = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Ürün ara...',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Kategoriler',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 42,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: categories.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final category = categories[index];

                            return ChoiceChip(
                              label: Text(category),
                              selected: selectedCategory == category,
                              onSelected: (_) {
                                setState(() {
                                  selectedCategory = category;
                                });
                              },
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Öne Çıkan Ürünler',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('${filteredProducts.length} ürün'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: filteredProducts.isEmpty
                            ? const Center(
                                child: Text(
                                  'Aramana uygun ürün bulunamadı.',
                                ),
                              )
                            : GridView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  childAspectRatio: 0.68,
                                ),
                                itemCount: filteredProducts.length,
                                itemBuilder: (context, index) {
                                  final product = filteredProducts[index];

                                  return ProductCard(
                                    product: product,
                                    onTap: () {
                                      Navigator.push<void>(
                                        context,
                                        MaterialPageRoute<void>(
                                          builder: (_) => ProductDetailPage(
                                            product: product,
                                            onAddToCart: () =>
                                                addToCart(product),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEEEEF4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EBFA),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22394488),
                      blurRadius: 12,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: product.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.shopping_bag_outlined,
                            size: 64,
                            color: Color(0xFF39436D),
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.shopping_bag_outlined,
                        size: 64,
                        color: Color(0xFF39436D),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              product.category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
            const SizedBox(height: 5),
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              product.price,
              style: const TextStyle(
                color: Color(0xFF4255D4),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            const Row(
              children: [
                Expanded(child: Text('Detayları gör')),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: Color(0xFF4255D4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDetailPage extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;

  const ProductDetailPage({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ürün Detayı')),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Container(
            height: 270,
            decoration: BoxDecoration(
              color: const Color(0xFFE8EBFA),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22394488),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: product.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.shopping_bag_outlined,
                        size: 115,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.shopping_bag_outlined,
                    size: 115,
                  ),
          ),
          const SizedBox(height: 24),
          Text(
            product.category.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF4255D4),
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            product.price,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4255D4),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Ürün Açıklaması',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            product.description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 30),
          FilledButton.icon(
            onPressed: onAddToCart,
            icon: const Icon(Icons.shopping_cart_outlined),
            label: const Text('Sepete Ekle'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }
}

class CartPage extends StatelessWidget {
  final List<Product> cart;
  final ValueChanged<Product> onRemove;

  const CartPage({
    super.key,
    required this.cart,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sepetim')),
      body: cart.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 72,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Sepetin şu an boş.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text('Ürün eklemek için kataloğa geri dön.'),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: cart.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final product = cart[index];

                return Card(
                  color: Colors.white,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFFE8EBFA),
                      child: product.imageUrl.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                product.imageUrl,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.shopping_bag_outlined,
                                ),
                              ),
                            )
                          : const Icon(Icons.shopping_bag_outlined),
                    ),
                    title: Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(product.price),
                    trailing: IconButton(
                      tooltip: 'Sepetten çıkar',
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        onRemove(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${product.name} sepetten çıkarıldı.',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
