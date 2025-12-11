import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:farm_hub/main.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Products extends StatefulWidget {
  const Products({super.key, required void Function(int) onNavigate});

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  bool isLoadingProduct = true;
  List<Map<String, dynamic>> products = [];
  File? selectedImage;

  TextEditingController fieldName = TextEditingController();
  TextEditingController fieldQuantity = TextEditingController();
  TextEditingController fieldPrice = TextEditingController();
  TextEditingController fieldDescription = TextEditingController();

  Future<void> createProduct(
    String name,
    int quantity,
    double price,
    String description,
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
      }

      await db.collection("products").add({
        "name": name,
        "quantity": quantity,
        "price": price,
        "description": description,
        "imageUrl": imageUrl,
      });

      getProducts();
    } catch (e) {
      print(e);
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
      print(e);
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
                      fieldDescription.clear();
                    });

                    showDialog(
                      context: context,
                      builder: (context) {
                        bool isSaving = false;
                        return StatefulBuilder(
                          builder: (context, setDialogState) {
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
                                      controller: fieldDescription,
                                      decoration: InputDecoration(
                                        labelText: "Descrição",
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
                                              color: Colors.green.withOpacity(
                                                0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              selectedImage!.path
                                                  .split('/')
                                                  .last,
                                              style: TextStyle(
                                                color: Colors.green.shade800,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
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
                                        style: TextStyle(color: Colors.green),
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
                                          setDialogState(() {
                                            isSaving = true;
                                          });
                                          await createProduct(
                                            fieldName.text,
                                            int.tryParse(fieldQuantity.text) ??
                                                0,
                                            double.tryParse(fieldPrice.text) ??
                                                0.0,
                                            fieldDescription.text,
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
                  ? Center(child: Text('Nenhum produto encontrado.'))
                  : ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailsScreen(
                                    productData: product,
                                  ),
                                ),
                              );
                              getProducts();
                            },
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child:
                                  product['imageUrl'] != null &&
                                      product['imageUrl'].isNotEmpty
                                  ? Image.network(
                                      product['imageUrl'],
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[200],
                                      child: Icon(Icons.image),
                                    ),
                            ),
                            title: Text(product["name"] ?? 'Sem nome'),
                            subtitle: Text("Qtd: ${product['quantity']}"),
                            trailing: Text(
                              "R\$${product['price']?.toStringAsFixed(2)}",
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

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> productData;

  const ProductDetailsScreen({super.key, required this.productData});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController descriptionController;
  int quantity = 0;
  bool isSaving = false;
  bool isDeleting = false;
  bool isEditing = false;

  File? newImageFile;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.productData['name']);
    priceController = TextEditingController(
      text: widget.productData['price'].toString(),
    );
    descriptionController = TextEditingController(
      text: widget.productData['description'] ?? '',
    );
    quantity = widget.productData['quantity'] ?? 0;
  }

  Future<void> pickNewImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        newImageFile = File(image.path);
      });
    }
  }

  Future<void> updateProduct() async {
    setState(() => isSaving = true);
    try {
      String imageUrl = widget.productData['imageUrl'] ?? '';

      if (newImageFile != null) {
        String fileName =
            'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
        Reference storageRef = FirebaseStorage.instance.ref().child(
          'product_images/$fileName',
        );
        UploadTask uploadTask = storageRef.putFile(newImageFile!);
        TaskSnapshot taskSnapshot = await uploadTask;
        imageUrl = await taskSnapshot.ref.getDownloadURL();
      }

      await db.collection("products").doc(widget.productData['id']).update({
        "name": nameController.text,
        "price": double.tryParse(priceController.text) ?? 0.0,
        "quantity": quantity,
        "description": descriptionController.text,
        "imageUrl": imageUrl,
      });

      setState(() {
        isSaving = false;
        isEditing = false;
        newImageFile = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Atualizado com sucesso!")));
        Navigator.pop(context);
      }
    } catch (e) {
      print(e);
      setState(() => isSaving = false);
    }
  }

  Future<void> deleteProduct() async {
    setState(() => isDeleting = true);
    try {
      String? imageUrl = widget.productData['imageUrl'];
      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          await FirebaseStorage.instance.refFromURL(imageUrl).delete();
        } catch (e) {
          print(e);
        }
      }

      await db.collection("products").doc(widget.productData['id']).delete();

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print(e);
      setState(() => isDeleting = false);
    }
  }

  void incrementQuantity() {
    setState(() {
      quantity++;
    });
  }

  void decrementQuantity() {
    if (quantity > 0) {
      setState(() {
        quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;

    if (newImageFile != null) {
      imageProvider = FileImage(newImageFile!);
    } else if (widget.productData['imageUrl'] != null &&
        widget.productData['imageUrl'] != '') {
      imageProvider = NetworkImage(widget.productData['imageUrl']);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Editar Produto" : "Detalhes do Produto"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (!isEditing)
            IconButton(
              icon: Icon(Icons.edit, color: Colors.green),
              onPressed: () {
                setState(() {
                  isEditing = true;
                });
              },
            ),
          if (isEditing)
            IconButton(
              icon: Icon(Icons.close, color: Colors.red),
              onPressed: () {
                setState(() {
                  isEditing = false;
                  nameController.text = widget.productData['name'];
                  priceController.text = widget.productData['price'].toString();
                  descriptionController.text =
                      widget.productData['description'] ?? '';
                  quantity = widget.productData['quantity'];
                  newImageFile = null;
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: isEditing ? pickNewImage : null,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      image: imageProvider != null
                          ? DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: imageProvider == null
                        ? Icon(
                            Icons.image_not_supported,
                            size: 80,
                            color: Colors.grey[300],
                          )
                        : null,
                  ),
                  if (isEditing)
                    Container(
                      width: double.infinity,
                      height: 250,
                      color: Colors.black38,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 40,
                            ),
                            Text(
                              "Aperte para mudar a Imagem",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: isEditing ? _buildEditForm() : _buildViewMode(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                nameController.text,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Estoque: $quantity",
                style: TextStyle(
                  color: Colors.green[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),

        Text(
          "R\$ ${double.tryParse(priceController.text)?.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.green,
          ),
        ),
        SizedBox(height: 20),

        Text(
          "Descrição",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 5),
        Text(
          descriptionController.text.isEmpty
              ? "Sem descrição."
              : descriptionController.text,
          style: TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.5),
        ),

        SizedBox(height: 40),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      children: [
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: "Nome",
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        SizedBox(height: 15),

        TextField(
          controller: descriptionController,
          decoration: InputDecoration(
            labelText: "Descrição",
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          maxLines: 4,
        ),
        SizedBox(height: 15),

        TextField(
          controller: priceController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "Preço (R\$)",
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        SizedBox(height: 20),

        Text(
          "Ajustar Estoque",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: decrementQuantity,
              icon: Icon(Icons.remove_circle, color: Colors.red, size: 40),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "$quantity",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              onPressed: incrementQuantity,
              icon: Icon(Icons.add_circle, color: Colors.green, size: 40),
            ),
          ],
        ),

        SizedBox(height: 30),

        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: isDeleting ? null : deleteProduct,
                child: isDeleting
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text("Excluir"),
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: isSaving ? null : updateProduct,
                child: isSaving
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text("Salvar"),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
