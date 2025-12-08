import 'package:flutter/material.dart';
import 'package:farm_hub/main.dart';

class Products extends StatefulWidget {
  const Products({super.key, required void Function(int) onNavigate});

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  List<Map<String, dynamic>> products = [];

  TextEditingController fieldName = TextEditingController();
  TextEditingController fieldQuantity = TextEditingController();
  TextEditingController fieldPrice = TextEditingController();

  Future<void> saveProduct(String name, int quantity, double price) async {
    try {
      await db.collection("products").add({
        "name": name,
        "quantity": quantity,
        "price": price,
      });

      print("Produto '$name' salvo com sucesso no Firebase!");

    } catch (e) {
      print("Erro ao salvar o produto: $e");
    }
  }

  void getProducts() async {try {

    final snapshot = await db.collection("products").get();

    final productsFromDb = snapshot.docs.map((doc) {
      return {
        "id": doc.id,
        ...doc.data()
      };
    }).toList();

    setState(() {
      products = productsFromDb;
    });

    print("Produtos carregados");

  } catch (e) {
    print("Erro ao buscar produtos: $e");
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
      body: Padding(
        padding: EdgeInsets.only(top: 35, left: 20, right: 20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [

                Expanded(
                  child: Center(
                    child: Text(
                      "Todos Produtos",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                FloatingActionButton(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  mini: true,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: Text(
                            "ADICIONAR PRODUTO",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),

                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: fieldName,
                                decoration: InputDecoration(
                                  labelText: "Nome",
                                  labelStyle: TextStyle(color: Colors.black),
                                ),
                              ),
                              TextField(
                                controller: fieldQuantity,
                                decoration: InputDecoration(
                                  labelText: "Quantidade",
                                  labelStyle: TextStyle(color: Colors.black),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              TextField(
                                controller: fieldPrice,
                                decoration: InputDecoration(
                                  labelText: "Preço",
                                  labelStyle: TextStyle(color: Colors.black),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),

                          actions: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.grey,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("Cancelar"),
                            ),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {

                                final String name = fieldName.text;
                                final int quantity = int.tryParse(fieldQuantity.text) ?? 0;
                                final double price = double.tryParse(fieldPrice.text) ?? 0.0;

                                saveProduct(name, quantity, price);
                                Navigator.pop(context);
                              },
                              child: Text("Salvar"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Icon(Icons.add),
                ),
              ],
            ),

            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: products.length,

                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {

                            TextEditingController nameController =
                                TextEditingController(
                                  text: products[index]["name"],
                                );
                            TextEditingController quantityController =
                                TextEditingController(
                                  text: products[index]["quantity"].toString(),
                                );
                            TextEditingController priceController =
                                TextEditingController(
                                  text: products[index]["price"].toString(),
                                );



                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Detalhes do Produto",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),

                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: nameController,
                                    decoration: InputDecoration(
                                      labelText: "Nome",
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  TextField(
                                    controller: quantityController,
                                    decoration: InputDecoration(
                                      labelText: "Quantidade",
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                  TextField(
                                    controller: priceController,
                                    decoration: InputDecoration(
                                      labelText: "Valor",
                                      labelStyle: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ],
                              ),

                              actions: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          products.removeAt(index);
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: Text("Deletar"),
                                    ),

                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          products[index]["name"] =
                                              nameController.text;
                                          products[index]["quantity"] =
                                              int.tryParse(
                                                quantityController.text,
                                              ) ??
                                              0;
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: Text("Salvar"),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      },

                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          "images/products/test.png",
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(products[index]["name"].toString()),
                      subtitle: Text(
                        "Quantidade: ${products[index]["quantity"].toString()}",
                      ),
                      trailing: Text(
                        "Valor: R\$${products[index]["quantity"].toString()}",
                      ),
                      contentPadding: EdgeInsets.zero,
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
