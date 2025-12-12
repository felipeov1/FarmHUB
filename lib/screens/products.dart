import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:farm_hub/main.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class Products extends StatefulWidget {
  final dynamic onNavigate;

  const Products({super.key, required this.onNavigate});

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

  Future<void> runWithTimeout(Future<void> Function() action, BuildContext context) async {
    bool online = await isOnline();

    try {
      await action().timeout(
        const Duration(seconds: 4),
        onTimeout: () {
          if (!online) {
            throw 'offline_timeout';
          } else {
            throw 'online_timeout';
          }
        },
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e == 'offline_timeout'
                ? "Operação concluída offline."
                : "Ocorreu um problema, tente novamente.",
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }


  Future<bool> isOnline() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> createProduct(BuildContext context) async {
    await runWithTimeout(() async {
      bool online = await isOnline();
      String imageUrl = '';

      if (selectedImage != null && online) {
        final fileName = 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final ref = FirebaseStorage.instance.ref().child(
          'product_images/$fileName',
        );
        final snap = await ref.putFile(selectedImage!);
        imageUrl = await snap.ref.getDownloadURL();
      }

      await db.collection("products").add({
        "name": fieldName.text,
        "quantity": int.tryParse(fieldQuantity.text) ?? 0,
        "price": double.tryParse(fieldPrice.text) ?? 0.0,
        "description": fieldDescription.text,
        "imageUrl": imageUrl,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              online
                  ? "Produto salvo com sucesso!"
                  : "Produto salvo offline (sem imagem)!",
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    }, context);
  }

  void getProducts() {
    db.collection("products").snapshots().listen((snapshot) {
      final productsFromDb = snapshot.docs.map((doc) {
        return {"id": doc.id, ...doc.data()};
      }).toList();
      if (mounted) {
        setState(() {
          products = productsFromDb;
          isLoadingProduct = false;
        });
      }
    });
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
        padding: const EdgeInsets.only(top: 35, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
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
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              title: const Text(
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
                                      decoration: const InputDecoration(
                                        labelText: "Nome",
                                        labelStyle: TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    TextField(
                                      controller: fieldDescription,
                                      decoration: const InputDecoration(
                                        labelText: "Descrição",
                                        labelStyle: TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    TextField(
                                      controller: fieldQuantity,
                                      decoration: const InputDecoration(
                                        labelText: "Quantidade",
                                        labelStyle: TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                    TextField(
                                      controller: fieldPrice,
                                      decoration: const InputDecoration(
                                        labelText: "Preço",
                                        labelStyle: TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                    const SizedBox(height: 20),
                                    selectedImage == null
                                        ? const Text(
                                            'Nenhuma imagem selecionada.',
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          )
                                        : Container(
                                            padding: const EdgeInsets.symmetric(
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
                                    const SizedBox(height: 10),
                                    TextButton.icon(
                                      icon: const Icon(
                                        Icons.image,
                                        color: Colors.green,
                                      ),
                                      label: const Text(
                                        'Selecionar Imagem',
                                        style: TextStyle(color: Colors.green),
                                      ),
                                      onPressed: () async {
                                        bool online = await isOnline();
                                        if (!online) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Sem internet. Você pode salvar sem imagem e adicionar depois.",
                                              ),
                                              backgroundColor: Colors.orange,
                                            ),
                                          );
                                          return;
                                        }
                                        final ImagePicker picker =
                                            ImagePicker();
                                        final XFile? image = await picker
                                            .pickImage(
                                              source: ImageSource.gallery,
                                            );
                                        if (image != null) {
                                          setDialogState(() {
                                            selectedImage = File(image.path);
                                          });
                                        }
                                      },
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
                                  onPressed: isSaving
                                      ? null
                                      : () => Navigator.pop(context),
                                  child: const Text("Cancelar"),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: isSaving
                                      ? null
                                      : () async {
                                          setDialogState(() => isSaving = true);
                                          await createProduct(context);
                                        },
                                  child: isSaving
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text("Salvar"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoadingProduct
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.green),
                    )
                  : products.isEmpty
                  ? const Center(child: Text('Nenhum produto encontrado.'))
                  : ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailsScreen(
                                    productData: product,
                                  ),
                                ),
                              );
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
                                      errorBuilder: (ctx, err, stack) =>
                                          Container(
                                            width: 60,
                                            height: 60,
                                            color: Colors.grey[200],
                                            child: const Icon(
                                              Icons.image_not_supported,
                                            ),
                                          ),
                                    )
                                  : Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.image),
                                    ),
                            ),
                            title: Text(product["name"] ?? 'Sem nome'),
                            subtitle: Text("Qtd: ${product['quantity']}"),
                            trailing: Text(
                              "R\$ ${product['price']?.toStringAsFixed(2)}",
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

  Future<void> runWithTimeout(Function action, BuildContext context) async {
    try {
      await Future.any(
        [
              action(),
              Future.delayed(const Duration(seconds: 4), () => throw 'timeout'),
            ]
            as Iterable<Future<dynamic>>,
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Operação concluída offline."),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

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

  Future<bool> isOnline() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> pickNewImage() async {
    bool online = await isOnline();
    if (!online) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Sem internet. Você pode editar tudo, menos trocar a imagem.",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
    await runWithTimeout(() async {
      bool online = await isOnline();
      String imageUrl = widget.productData['imageUrl'] ?? '';

      if (newImageFile != null && online) {
        final fileName = 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final ref = FirebaseStorage.instance.ref().child(
          'product_images/$fileName',
        );
        final snap = await ref.putFile(newImageFile!);
        imageUrl = await snap.ref.getDownloadURL();
      }

      await db.collection("products").doc(widget.productData['id']).update({
        "name": nameController.text,
        "price": double.tryParse(priceController.text) ?? 0.0,
        "quantity": quantity,
        "description": descriptionController.text,
        "imageUrl": imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            online
                ? "Atualizado com sucesso!"
                : "Atualizado offline (sem imagem)!",
          ),
          backgroundColor: Colors.green,
        ),
      );

      setState(() => isEditing = false);
    }, context);
    setState(() => isSaving = false);
  }

  Future<void> deleteProduct() async {
    setState(() => isDeleting = true);
    await runWithTimeout(() async {
      bool online = await isOnline();
      String? imageUrl = widget.productData['imageUrl'];

      await db.collection("products").doc(widget.productData['id']).delete();

      if (online && imageUrl != null && imageUrl.isNotEmpty) {
        try {
          await FirebaseStorage.instance.refFromURL(imageUrl).delete();
        } catch (_) {}
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            online
                ? "Produto excluído com sucesso!"
                : "Produto excluído offline!",
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }, context);
    setState(() => isDeleting = false);
  }

  void incrementQuantity() => setState(() => quantity++);
  void decrementQuantity() {
    if (quantity > 0) setState(() => quantity--);
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
              icon: const Icon(Icons.edit, color: Colors.green),
              onPressed: () => setState(() => isEditing = true),
            ),
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
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
                      child: const Center(
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
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Qtd: $quantity",
                style: TextStyle(
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          "Preço: R\$${priceController.text}",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade700,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          descriptionController.text,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: "Nome"),
        ),
        TextField(
          controller: priceController,
          decoration: const InputDecoration(labelText: "Preço"),
          keyboardType: TextInputType.number,
        ),
        TextField(
          controller: descriptionController,
          decoration: const InputDecoration(labelText: "Descrição"),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Text("Quantidade:", style: TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            IconButton(
              onPressed: decrementQuantity,
              icon: const Icon(Icons.remove_circle, color: Colors.red),
            ),
            Text(
              "$quantity",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: incrementQuantity,
              icon: const Icon(Icons.add_circle, color: Colors.green),
            ),
          ],
        ),
        const SizedBox(height: 20),
        isSaving
            ? const Center(
                child: CircularProgressIndicator(color: Colors.green),
              )
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: (isSaving || isDeleting) ? null : updateProduct,
                child: const Text("Salvar Alterações"),
              ),
        const SizedBox(height: 20),
        isDeleting
            ? const Center(child: CircularProgressIndicator(color: Colors.red))
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: (isSaving || isDeleting) ? null : deleteProduct,
                child: const Text("Excluir Produto"),
              ),
      ],
    );
  }
}
