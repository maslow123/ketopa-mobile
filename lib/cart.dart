import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    title: "Cart",
    home: Cart(),
  ));
}

class Cart extends StatefulWidget {
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  List<Product> cartItems = [
    Product(
      id: 1,
      name: "Siladex",
      price: 5,
      quantity: 2,
    ),
    Product(
      id: 2,
      name: "Panadol",
      price: 10,
      quantity: 3,
    ),
    Product(
      id: 3,
      name: "Diapet",
      price: 15,
      quantity: 1,
    ),
  ];

  void addItemToCart(Product product) {
    setState(() {
      cartItems.add(product);
    });
  }

  void removeItemFromCart(Product product) {
    setState(() {
      cartItems.remove(product);
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

  double getTotalPrice() {
    double totalPrice = 0;
    for (final product in cartItems) {
      totalPrice += product.price * product.quantity;
    }
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
              Text('Total Price: \Rp.${getTotalPrice().toStringAsFixed(2)}'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pushNamed(
                    context, '/upload'); // Navigate to the "/upload" route
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
      body: cartItems.isEmpty
          ? Center(
              child: Text('No items in the cart.'),
            )
          : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (BuildContext context, int index) {
                final product = cartItems[index];
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

class Product {
  final int id;
  final String name;
  final double price;
  int quantity;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });
}
