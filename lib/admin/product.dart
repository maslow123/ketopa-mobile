import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    title: "Data Obat",
    home: ListProduct(),
  ));
}

class Category {
  int id;
  int createdAt;
  String name;

  Category({
    required this.id,
    required this.createdAt,
    required this.name,
  });
}

class Product {
  int id;
  int categoryId;
  String name;
  String image;
  double price;
  int stock;

  Product({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.image,
    required this.price,
    required this.stock,
  });
}

class ListProduct extends StatefulWidget {
  @override
  _ListProductState createState() => _ListProductState();
}

class _ListProductState extends State<ListProduct> {
  List<Product> products = [];
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchCategories();
  }

  Future<void> fetchProducts() async {
    final response = await http
        .get(Uri.parse('http://172.20.10.2:8000/api/v1/product/list'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final productList = jsonData['result'] as List<dynamic>;
      setState(() {
        products = productList
            .map((item) => Product(
                  id: item['id'] ?? 0,
                  categoryId: item['category']['id'] ?? 0,
                  name: item['name'] ?? '',
                  image: item['image'] ?? '',
                  price: item['price'] != null ? item['price'].toDouble() : 0.0,
                  stock: item['stock'] ?? 0,
                ))
            .toList();
      });
    } else {
      print('Error fetching products. Status code: ${response.statusCode}');
    }
  }

  Future<void> fetchCategories() async {
    final response = await http
        .get(Uri.parse('http://172.20.10.2:8000/api/v1/category/list'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final categoryList = jsonData['result'] as List<dynamic>;
      setState(() {
        categories = categoryList
            .map((item) => Category(
                  id: item['id'] ?? 0,
                  createdAt: item['created_at'] ?? 0,
                  name: item['name'] ?? '',
                ))
            .toList();
      });
    } else {
      print('Error fetching categories. Status code: ${response.statusCode}');
    }
  }

  Future<void> deleteProductAPI(int productId) async {
    final response = await http
        .delete(Uri.parse('http://172.20.10.2:8000/api/v1/product/$productId'));
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Product delete successfully')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Product delete Failed')));
    }
  }

  Future<void> editProductAPI(
      int productId, Map<String, dynamic> updatedProductData) async {
    final url = Uri.parse('http://172.20.10.2:8000/api/v1/product/$productId');
    final response = await http.put(
      url,
      body: jsonEncode({
        ...updatedProductData,
        'category_id': updatedProductData['category']['id'],
      }),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product updated successfully')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Product updated Failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Obat'),
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            leading: Icon(
              Icons.medication_liquid,
              size: 60,
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name),
                Text(
                  'Category: ${getCategoryName(product.categoryId)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            subtitle: Text('Price: \Rp.${product.price}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    editProduct(product);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    deleteProduct(index, product.id);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, "/admin/add");
        },
      ),
    );
  }

  String getCategoryName(int categoryId) {
    final category = categories.firstWhere((cat) => cat.id == categoryId,
        orElse: () => Category(id: 0, createdAt: 0, name: ''));
    return category.name;
  }

  void deleteProduct(int index, int productId) {
    setState(() {
      products.removeAt(index);
    });
    deleteProductAPI(productId);
  }

  void editProduct(Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController nameController = TextEditingController();
        TextEditingController categoryIdController = TextEditingController();
        TextEditingController imageController = TextEditingController();
        TextEditingController priceController = TextEditingController();
        TextEditingController stockController = TextEditingController();

        nameController.text = product.name;
        categoryIdController.text = product.categoryId.toString();
        imageController.text = product.image;
        priceController.text = product.price.toString();
        stockController.text = product.stock.toString();

        return AlertDialog(
          title: Text('Edit Product'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                DropdownButtonFormField<int>(
                  value: product.categoryId,
                  items: categories.map((category) {
                    return DropdownMenuItem<int>(
                      value: category.id,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      product.categoryId = value!;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Category'),
                ),
                TextFormField(
                  controller: imageController,
                  decoration: InputDecoration(labelText: 'Image'),
                ),
                TextFormField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: 'Price'),
                ),
                TextFormField(
                  controller: stockController,
                  decoration: InputDecoration(labelText: 'Stock'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                setState(() {
                  product.name = nameController.text;
                  product.image = imageController.text;
                  product.price = double.parse(priceController.text);
                  product.stock = int.parse(stockController.text);
                });

                Map<String, dynamic> updatedProductData = {
                  'category': {
                    'id': product.categoryId,
                    'created_at':
                        0, // Assuming this field is not used in the request
                    'name': getCategoryName(product.categoryId),
                  },
                  'name': product.name,
                  'image': product.image,
                  'price': product.price,
                  'stock': product.stock,
                  'created_by': 29,
                };

                editProductAPI(product.id, updatedProductData);

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
