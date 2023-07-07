import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EditProduct extends StatefulWidget {
  final int productId;

  EditProduct({required this.productId});

  @override
  _EditProductState createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _stockController = TextEditingController();

  Future<void> updateProductAPI(
      int productId, Map<String, dynamic> updatedProductData) async {
    final url =
        Uri.parse('http://192.168.0.107:8000/api/v1/product/$productId');
    final response = await http.put(
      url,
      body: jsonEncode(updatedProductData),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      // Product updated successfully, show a success message
      print('Product updated successfully');
    } else {
      // Handle error cases
      print('Error updating product. Status code: ${response.statusCode}');
    }
  }

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      // Create a Map object with the updated product data
      final updatedProductData = {
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'stock': int.parse(_stockController.text),
      };

      updateProductAPI(widget.productId, updatedProductData);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  // Validate if the input can be parsed as a double
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _stockController,
                decoration: InputDecoration(
                  labelText: 'Stock',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a stock value';
                  }
                  // Validate if the input can be parsed as an integer
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid stock value';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: submitForm,
                child: Text('Update Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
