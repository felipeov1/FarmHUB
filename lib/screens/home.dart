import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  final Function(int) onNavigate;

  const Home({super.key, required this.onNavigate});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> products = [
    {"name": "Arroz 5kg", "quantity": 12},
    {"name": "Feijão Preto", "quantity": 7},
    {"name": "Macarrão", "quantity": 20},
    {"name": "Café 500g", "quantity": 15},
  ];

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
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
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
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final item = products[index];

                  return Container(
                    width: 160,
                    margin: EdgeInsets.only(right: 12),
                    padding: EdgeInsets.all(12),
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
                          child: Image.asset(
                            "images/products/test.png",
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item["name"],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Qtd: ${item["quantity"]}",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        Text(
                          "Valor: R\$${item["quantity"]}",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
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
