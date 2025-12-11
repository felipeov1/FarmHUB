import 'package:flutter/material.dart';
import '../main.dart';
import 'products.dart';

class Home extends StatefulWidget {
  final Function(int) onNavigate;

  const Home({super.key, required this.onNavigate});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String hasError = '';
  bool isLoadingProduct = true;
  List<Map<String, dynamic>> products = [];

  TextEditingController fieldName = TextEditingController();
  TextEditingController fieldQuantity = TextEditingController();
  TextEditingController fieldPrice = TextEditingController();

  void getProducts() async {
    try {
      setState(() {
        isLoadingProduct = true;
      });

      final snapshot = await db.collection("products").limit(5).get();

      final productsFromDb = snapshot.docs.map((doc) {
        return {"id": doc.id, ...doc.data()};
      }).toList();

      setState(() {
        products = productsFromDb;
        isLoadingProduct = false;
      });
    } catch (e) {
      setState(() {
        isLoadingProduct = false;
        hasError = "Não foi possível carregar os produtos.";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Text(
                    "Produtos",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    widget.onNavigate(1);
                  },
                  child: const Text(
                    "Ver todos",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 160,
              child: isLoadingProduct
                  ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.green,
                  strokeWidth: 2,
                ),
              )
                  : products.isEmpty
                  ? const Center(
                child: Text(
                  'Nenhum produto encontrado.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final item = products[index];

                  return GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsScreen(
                            productData: item,
                          ),
                        ),
                      );
                      getProducts();
                    },
                    child: Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: products[index]['imageUrl'] !=
                                null &&
                                products[index]['imageUrl']
                                    .isNotEmpty
                                ? Image.network(
                              products[index]['imageUrl'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) {
                                return Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[200],
                                  child: Icon(
                                      Icons.broken_image,
                                      color: Colors.grey),
                                );
                              },
                            )
                                : Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[200],
                              child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['name'] ?? 'Sem nome',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Qtd:${item['quantity']?.toString() ?? '0'}",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          Text(
                            "R\$ ${item['price']?.toStringAsFixed(2) ?? '0.00'}",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
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