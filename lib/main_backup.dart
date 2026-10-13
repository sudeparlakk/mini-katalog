
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

void main() {
  runApp(const MiniKatalogApp());
}

class Product {
  final String name;
  final String category;
  final String price;
  final String description;
  final IconData icon;
  final Color color;

  const Product({
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.icon,
    required this.color,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'description': description,
      'iconCodePoint': icon.codePoint,
      'colorValue': color.toARGB32(),
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'] as String,
      category: json['category'] as String,
      price: json['price'].toString(),
      description: json['description'] as String,
      icon: IconData(
      json['iconCodePoint'] as int,
      fontFamily: 'MaterialIcons',
      matchTextDirection: false,
),
      color: Color(json['colorValue'] as int),
    );
  }
}

const List<Product> products = [
  Product(
    name: 'Kablosuz Kulaklık',
    category: 'Elektronik',
    price: '1.499 TL',
    description:
        'Günlük kullanım için konforlu, kablosuz ve şık tasarımlı kulaklık.',
    icon: Icons.headphones_rounded,
    color: Color(0xFFE1E8FF),
  ),
  Product(
    name: 'Akıllı Saat',
    category: 'Giyilebilir Teknoloji',
    price: '2.299 TL',
    description:
        'Aktivite takibi ve günlük kullanım için modern akıllı saat.',
    icon: Icons.watch_rounded,
    color: Color(0xFFFFE7D6),
  ),
  Product(
    name: 'Dizüstü Bilgisayar',
    category: 'Bilgisayar',
    price: '24.999 TL',
    description:
        'Eğitim, çalışma ve günlük kullanım için taşınabilir bilgisayar.',
    icon: Icons.laptop_mac_rounded,
    color: Color(0xFFDDF4E7),
  ),
  Product(
    name: 'Bluetooth Hoparlör',
    category: 'Ses Sistemleri',
    price: '999 TL',
    description:
        'Kompakt tasarımlı, taşınabilir Bluetooth hoparlör.',
    icon: Icons.speaker_rounded,
    color: Color(0xFFFFE0E8),
  ),
  Product(
    name: 'Tablet',
    category: 'Elektronik',
    price: '8.499 TL',
    description:
        'Not almak, içerik tüketmek ve günlük işler için kullanışlı tablet.',
    icon: Icons.tablet_mac_rounded,
    color: Color(0xFFE9E0FF),
  ),
  Product(
    name: 'Fotoğraf Makinesi',
    category: 'Fotoğrafçılık',
    price: '12.499 TL',
    description:
        'Özel anları yakalamak için tasarlanmış kompakt fotoğraf makinesi.',
    icon: Icons.camera_alt_rounded,
    color: Color(0xFFFFEFC9),
  ),
];

class MiniKatalogApp extends StatelessWidget {
  const MiniKatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mini Katalog',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 10, 35, 195),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F8FC),
          elevation: 0,
          centerTitle: false,
        ),
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
  String searchText = '';
  String selectedCategory = 'Tümü';
  List<Product> products = [];
  bool isLoading = true;
  @override
void initState() {
  super.initState();
  loadProducts();
}

Future<void> loadProducts() async {
  try {
    final String jsonString =
        await DefaultAssetBundle.of(context)
            .loadString('lib/assets/products.json');

    final List<dynamic> jsonList = jsonDecode(jsonString);

    setState(() {
      products = jsonList
          .map((item) => Product.fromJson(item))
          .toList();
      isLoading = false;
    });
  } catch (e) {
    setState(() {
      isLoading = false;
    });
    debugPrint('Ürünler yüklenemedi: $e');
  }
}

  final List<String> categories = [
    'Tümü',
    'Elektronik',
    'Bilgisayar',
    'Ses Sistemleri',
    'Fotoğrafçılık',
    'Giyilebilir Teknoloji',
  ];

  @override
  Widget build(BuildContext context) {
    final filteredProducts = products.where((product) {
      final matchesSearch = product.name
          .toLowerCase()
          .contains(searchText.toLowerCase());

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
                color: Color(0xFF20233A),
              ),
            ),
          ],
        ),
        toolbarHeight: 82,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategory == category;

                  return ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
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
                  Text(
                    '${filteredProducts.length} ürün',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredProducts.isEmpty
                  ? const Center(
                      child: Text('Aramana uygun ürün bulunamadı.'),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
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

                        return ProductCard(product: product);
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

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEEEEF4)),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: product.color,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  product.icon,
                  size: 66,
                  color: const Color(0xFF39436D),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              product.category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
              ),
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
            const SizedBox(height: 8),
            const Row(
              children: [
                Expanded(
                  child: Text(
                    'Detayları gör',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
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

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ürün Detayı'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            Container(
              height: 270,
              decoration: BoxDecoration(
                color: product.color,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                product.icon,
                size: 115,
                color: const Color(0xFF39436D),
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
  onPressed: () {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} sepete eklendi!'),
      ),
    );
  },
    icon: const Icon(Icons.shopping_cart_outlined),
    label: const Text('Sepete Ekle'),
    style: FilledButton.styleFrom(
     padding: const EdgeInsets.all(16),
  ),
            ),
          ],
        ),
      ),
    );
  }
}
