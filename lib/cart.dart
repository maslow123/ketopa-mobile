import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

class Cart extends StatefulWidget {
  List<Product> tempCart;
  Cart({required this.tempCart});

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  File? imageFile;
  List cart = [];

  void uploadEvidence() async {
    await getFromGallery();
    if (imageFile != null) {
      var apiUrl =
          Uri.parse('http://192.168.0.107:8000/api/v1/upload/evidence');
      var request = new http.MultipartRequest("POST", apiUrl);
      request.files.add(await http.MultipartFile.fromPath(
        'files',
        imageFile!.path,
      ));

      var response = await request.send();

      print("ini response ${response}");

      if (response.statusCode == 200) {
        // Registration successful, handle the response if needed
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Upload successfully.')));

        var res = await await http.Response.fromStream(response);
        var resDecoded = json.decode(res.body);

        print("uploaded! $resDecoded");

        createTransaction(evidence: resDecoded['data']['filename']);
      } else {
        // Registration failed, handle the response if needed
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Upload failed.')));
        print(response.statusCode);
      }
    }
  }

  void createTransaction({required String evidence}) async {
    Map<String, dynamic> requestData = {
      "user_id": await getId(),
      "products": cart,
      "evidence": evidence
    };

    print("ini data ${requestData}");

    var apiUrl =
        Uri.parse('http://192.168.0.107:8000/api/v1/transaction/create');
    var response = await http.post(
      apiUrl,
      body: jsonEncode(requestData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Registration successful, handle the response if needed
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Transaction successfully.')));
      print(response.body);
      Navigator.popAndPushNamed(context, "/upload");
      setState(() {
        widget.tempCart = [];
      });
    } else {
      // Registration failed, handle the response if needed
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Transaction failed.')));
      print(response.body);
    }
  }

  getId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    int? stringValue = prefs.getInt('id');
    return stringValue;
  }

  void addItemToCart(Product product) {
    setState(() {
      widget.tempCart.add(product);
    });
  }

  void removeItemFromCart(Product product) {
    setState(() {
      widget.tempCart.remove(product);
    });
  }

  void increaseQuantity(Product product) {
    setState(() {
      product.quantity++;
    });
  }

  void decreaseQuantity(Product product) {
    setState(() {
      if (product.quantity > 1) {
        product.quantity--;
      }
    });
  }

  Future<void> getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
    }
    print("ini file $imageFile");
  }

  double getTotalPrice() {
    double totalPrice = 0;
    for (final product in widget.tempCart) {
      totalPrice += product.price * product.quantity;
      cart.add({
        "product_id": product.id,
        "quantity": product.quantity,
        "total": product.price * product.quantity,
      });
    }
    print("ini cart $cart");
    return totalPrice;
  }

  void checkout() {
    // Implement your checkout logic here

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Checkout'),
          content:
              Text('Total Harga: \Rp.${getTotalPrice().toStringAsFixed(2)}'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                uploadEvidence(); // Navigate to the "/upload" route
              },
              child: Text('Confirm'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cart',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      body: widget.tempCart.isEmpty
          ? Center(
              child: Text('No items in the cart.'),
            )
          : ListView.builder(
              itemCount: widget.tempCart.length,
              itemBuilder: (BuildContext context, int index) {
                final product = widget.tempCart[index];
                return ListTile(
                  leading: Text(
                    '${product.quantity}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  title: Text(product.name),
                  subtitle: Text('\Rp.${product.price.toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => increaseQuantity(product),
                        icon: Icon(Icons.add),
                      ),
                      IconButton(
                        onPressed: () => decreaseQuantity(product),
                        icon: Icon(Icons.remove),
                      ),
                      IconButton(
                        onPressed: () => removeItemFromCart(product),
                        icon: Icon(Icons.delete),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: checkout,
            child: Text('Checkout'),
          ),
        ),
      ),
    );
  }
}

class ProductCart {
  final int id;
  final String name;
  final double price;
  int quantity;

  ProductCart({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });
}
