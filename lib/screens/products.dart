import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:farm_hub/main.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Products extends StatefulWidget {
  const Products({super.key, required void Function(int) onNavigate});

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  String hasError = '';
  bool isLoadingProduct = true;
  List<Map<String, dynamic>> products = [];
  File? selectedImage;
  TextEditingController fieldName = TextEditingController();
  TextEditingController fieldQuantity = TextEditingController();
  TextEditingController fieldPrice = TextEditingController();

  Future<void> saveProduct(
    String name,
    int quantity,
    double price,
    File? imageFile,
  ) async {
    try {
      String imageUrl = '';

      if (imageFile != null) {
        String fileName =
            'product_${DateTime.now().millisecondsSinceEpoch}.jpg';

        Reference storageRef = FirebaseStorage.instance.ref().child(
          'product_images/$fileName',
        );

        UploadTask uploadTask = storageRef.putFile(imageFile);

        TaskSnapshot taskSnapshot = await uploadTask;

        imageUrl = await taskSnapshot.ref.getDownloadURL();
        print("Upload da imagem concluído. URL: $imageUrl");
      }

      await db.collection("products").add({
        "name": name,
        "quantity": quantity,
        "price": price,
        "imageUrl": imageUrl,
      });

      getProducts();
    } catch (e) {
      print("Ocorreu um erro ao salvar o produto: $e");
    }
  }

  void getProducts() async {
    try {
      setState(() {
        isLoadingProduct = true;
      });

      final snapshot = await db.collection("products").get();

      final productsFromDb = snapshot.docs.map((doc) {
        return {"id": doc.id, ...doc.data()};
      }).toList();

      setState(() {
        products = productsFromDb;
        isLoadingProduct = false;
      });
    } catch (e) {
      print("Erro ao buscar produtos: $e");
    }
  }

  Future<void> deleteProduct(String productId, String? imageUrl) async {
    try {
      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          await FirebaseStorage.instance.refFromURL(imageUrl).delete();
        } catch (e) {
          print("Erro ao deletar imagem (pode não existir mais): $e");
        }
      }
      await db.collection("products").doc(productId).delete();
      getProducts();
    } catch (e) {
      print("Erro ao deletar o produto: $e");
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
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
                    setState(() {
                      selectedImage = null;
                      fieldName.clear();
                      fieldQuantity.clear();
                      fieldPrice.clear();
                    });

                    showDialog(
                      context: context,
                      builder: (context) {
                        bool isSaving = false;
                        return StatefulBuilder(
                          builder:
                              (
                                BuildContext context,
                                StateSetter setDialogState,
                              ) {

                                Future<void> pickImageForDialog() async {
                                  final ImagePicker picker = ImagePicker();
                                  final XFile? image = await picker.pickImage(
                                    source: ImageSource.gallery,
                                  );
                                  if (image != null) {
                                    setDialogState(() {
                                      selectedImage = File(image.path);
                                    });
                                  }
                                }

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

                                  content: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: fieldName,
                                          decoration: InputDecoration(
                                            labelText: "Nome",
                                            labelStyle: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        TextField(
                                          controller: fieldQuantity,
                                          decoration: InputDecoration(
                                            labelText: "Quantidade",
                                            labelStyle: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                          keyboardType: TextInputType.number,
                                        ),
                                        TextField(
                                          controller: fieldPrice,
                                          decoration: InputDecoration(
                                            labelText: "Preço",
                                            labelStyle: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                          keyboardType: TextInputType.number,
                                        ),
                                        SizedBox(height: 20),

                                        selectedImage == null
                                            ? Text(
                                                'Nenhuma imagem selecionada.',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              )
                                            : Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  selectedImage!.path
                                                      .split('/')
                                                      .last,
                                                  style: TextStyle(
                                                    color:
                                                        Colors.green.shade800,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                        SizedBox(height: 10),
                                        TextButton.icon(
                                          icon: Icon(
                                            Icons.image,
                                            color: Colors.green,
                                          ),
                                          label: Text(
                                            'Selecionar Imagem',
                                            style: TextStyle(
                                              color: Colors.green,
                                            ),
                                          ),
                                          onPressed: pickImageForDialog,
                                        ),
                                      ],
                                    ),
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
                                      onPressed: isSaving
                                          ? null
                                          : () async {
                                              final String name =
                                                  fieldName.text;
                                              final int quantity =
                                                  int.tryParse(
                                                    fieldQuantity.text,
                                                  ) ??
                                                  0;
                                              final double price =
                                                  double.tryParse(
                                                    fieldPrice.text,
                                                  ) ??
                                                  0.0;

                                              setDialogState(() {
                                                isSaving = true;
                                              });
                                              await saveProduct(
                                                name,
                                                quantity,
                                                price,
                                                selectedImage,
                                              );

                                              if (context.mounted) {
                                                Navigator.pop(context);
                                              }
                                            },
                                      child: isSaving
                                          ? Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2,
                                                      ),
                                                ),
                                                SizedBox(width: 10),
                                                Text("Salvando..."),
                                              ],
                                            )
                                          : Text("Salvar"),
                                    ),
                                  ],
                                );
                              },
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
              child: isLoadingProduct
                  ? Center(
                      child: CircularProgressIndicator(color: Colors.green),
                    )
                  : products.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhum produto encontrado.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
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
                            TextEditingController nameController = TextEditingController(
                              text: products[index]["name"],
                            );
                            TextEditingController quantityController = TextEditingController(
                              text: products[index]["quantity"].toString(),
                            );
                            TextEditingController priceController = TextEditingController(
                              text: products[index]["price"].toString(),
                            );

                            bool isDeleting = false;
                            bool isSaving = false;

                            return StatefulBuilder(
                              builder: (context, setDialogState) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        child: Icon(Icons.close, color: Colors.black),
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
                                          labelStyle: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                      TextField(
                                        controller: quantityController,
                                        decoration: InputDecoration(
                                          labelText: "Quantidade",
                                          labelStyle: TextStyle(color: Colors.black),
                                        ),
                                        keyboardType: TextInputType.number,
                                      ),
                                      TextField(
                                        controller: priceController,
                                        decoration: InputDecoration(
                                          labelText: "Valor",
                                          labelStyle: TextStyle(color: Colors.black),
                                        ),
                                        keyboardType: TextInputType.number,
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: isDeleting
                                              ? null
                                              : () async {
                                            setDialogState(() {
                                              isDeleting = true;
                                            });

                                            await deleteProduct(
                                              products[index]["id"],
                                              products[index]["imageUrl"],
                                            );

                                            if (context.mounted) {
                                              Navigator.pop(context);
                                            }
                                          },
                                          child: isDeleting
                                              ? Row(
                                            children: [
                                              SizedBox(
                                                width: 12,
                                                height: 12,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Text("Excluindo..."),
                                            ],
                                          )
                                              : Text("Excluir"),
                                        ),

                                        ElevatedButton(
                                          onPressed: isSaving
                                              ? null
                                              : () async {
                                            setDialogState(() {
                                              isSaving = true;
                                            });

                                            await saveProduct(
                                              nameController.text,
                                              int.tryParse(quantityController.text) ?? 0,
                                              double.tryParse(priceController.text) ?? 0.0,
                                              null,
                                            );

                                            if (context.mounted) Navigator.pop(context);
                                          },
                                          child: isSaving
                                              ? Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Text("Salvando..."),
                                            ],
                                          )
                                              : Text("Salvar"),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: products[index]['imageUrl'] != null &&
                            products[index]['imageUrl'].isNotEmpty
                            ? Image.network(
                          products[index]['imageUrl'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[200],
                              child: Icon(Icons.broken_image, color: Colors.grey),
                            );
                          },
                        )
                            : Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[200],
                          child: Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      ),
                      title: Text(products[index]["name"]?.toString() ?? 'Sem nome'),
                      subtitle: Text(
                        "Qtd: ${products[index]['quantity']?.toString() ?? '0'}",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      trailing: Text(
                        "R\$${products[index]['price']?.toStringAsFixed(2) ?? '0.00'}",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  );
                },
              )
            ),
          ],
        ),
      ),
    );
  }
}
