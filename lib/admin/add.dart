import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(MaterialApp(
    title: "Buat Form Produk",
    home: AddProduct(),
  ));
}

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController stockController = TextEditingController();
  File? selectedImage;
  String? selectedCategory;
  List<String> categoryOptions = [];

  @override
  void initState() {
    super.initState();
    fetchCategories(); // Fetch categories on widget initialization
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    stockController.dispose();
    super.dispose();
  }

  Future<void> fetchCategories() async {
    final response = await http.get(
      Uri.parse('http://172.20.10.2:8000/api/v1/category/list'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> categories = data['result'];

      setState(() {
        categoryOptions =
            categories.map((category) => category['name'].toString()).toList();
      });
    } else {
      print('Failed to fetch categories. Error: ${response.body}');
    }
  }

  Future<void> pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<void> createProduct() async {
    final name = nameController.text;
    final price = double.tryParse(priceController.text);
    final stock = int.tryParse(stockController.text);
    final category = selectedCategory;

    // Build the request body
    final requestBody = {
      'category_id': 8,
      'name': name,
      'image': selectedImage != null
          ? selectedImage!.path
          : 'https://picsum.photos/200/300',
      'description': '',
      'price': price,
      'created_by': 29,
      'stock': stock,
    };

    final response = await http.post(
      Uri.parse('http://172.20.10.2:8000/api/v1/product/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      print('Product created successfully!');
      nameController.clear();
      priceController.clear();
      stockController.clear();
      setState(() {
        selectedImage = null;
        selectedCategory = null;
      });

      // Redirect to /admin/product
      Navigator.pushReplacementNamed(context, '/admin/product');
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to create product')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Product'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Product',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Stock',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategory = newValue!;
                });
              },
              items: categoryOptions.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 26),
            Column(
              children: [
                Center(
                  child: Text(
                    'Upload Foto',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Center(
                  child: IconButton(
                    onPressed: pickImage,
                    icon: Icon(Icons.upload),
                  ),
                )
              ],
            ),
            SizedBox(height: 16),
            selectedImage != null
                ? Image.file(
                    selectedImage!,
                    height: 150,
                  )
                : Container(),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: createProduct,
              child: Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
