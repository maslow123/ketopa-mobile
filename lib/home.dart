import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmacy_apps/cart.dart';
import 'package:pharmacy_apps/list-transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    title: "Home",
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  List<Product> _products = [];
  String? name;
  String? phone;
  String? address;
  List<Product> tempCart = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
    validasi();
  }

  void fetchProducts() async {
    final response = await http
        .get(Uri.parse('http://192.168.0.107:8000/api/v1/product/list'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> results = data['result'];
      List<Product> products =
          results.map((result) => Product.fromJson(result)).toList();

      setState(() {
        _products = products;
      });
      // String? data_user = prefs.getString('data_user');
      // print(data_user);
    } else {
      print('Failed to fetch products');
    }
  }

  void addToCart(Product item) {
    setState(() {
      if (!tempCart.contains(item)) {
        tempCart.add(item);
        item.quantity++;
      } // Increment the cart count
    });
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushReplacementNamed(context, '/login');
  }

  void validasi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    print(token);
    if (token == null) {
      await prefs.remove('token');
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      setState(() {
        name = prefs.getString('name');
        phone = prefs.getString('phone');
        address = prefs.getString('address');
      });
    }
  }

  Widget build(BuildContext context) {
    List<Widget> _screens = [
      ProductListScreen(
        products: _products,
        addToCart: addToCart,
        tempCart: tempCart,
      ),
      Cart(
        tempCart: tempCart,
      ),
      ListTransactionPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart),
                if (tempCart.length > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        tempCart.length.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Transactions',
          ),
        ],
      ),
    );
  }
}

class ProductListScreen extends StatelessWidget {
  final List<Product> products;
  final Function addToCart; // Callback function to add product to cart
  final String? name;
  final String? phone;
  final String? address;
  final List<Product> tempCart;

  ProductListScreen({
    required this.products,
    required this.addToCart,
    required this.tempCart,
    this.name,
    this.phone,
    this.address,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (BuildContext context, int index) {
        final product = products[index];
        return ListTile(
          leading: Icon(
            product.category == "Cair"
                ? Icons.medication_liquid
                : (product.category == "Tablet"
                    ? Icons.control_point_duplicate_outlined
                    : Icons.medication_liquid),
            size: 60,
            color: Colors.blue,
          ),
          title: Text(product.name),
          subtitle: Text(product.category),
          trailing: IconButton(
            onPressed: () {
              addToCart(
                  product); // Call the addToCart function to increment the cart count
            },
            icon: Icon(Icons.add_shopping_cart),
          ),
        );
      },
    );
  }
}

class Product {
  final int id;
  final String category;
  final String name;
  final String image;
  final double price;
  final int stock;
  int quantity;

  Product(
      {required this.id,
      required this.category,
      required this.name,
      required this.image,
      required this.price,
      required this.stock,
      this.quantity = 0});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      category: json['category']['name'],
      name: json['name'],
      image: json['image'],
      price: json['price'].toDouble(),
      stock: json['stock'],
    );
  }
}
