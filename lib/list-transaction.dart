import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ListTransactionPage extends StatefulWidget {
  @override
  _ListTransactionPageState createState() => _ListTransactionPageState();
}

class _ListTransactionPageState extends State<ListTransactionPage> {
  List<dynamic> transactions = [];
  String? name;
  String? phone;
  String? address;
  int? token;
  int? id;
  int? level;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
    validasi();
  }

  Future<void> fetchTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('id');
    int? level = prefs.getInt('level');
    print(level);

    if (level == 1) {
      final url = Uri.parse(
          'http://10.107.254.37:8000/api/v1/transaction/list?user_id=0');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          transactions = jsonResponse['result'];
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('List Transaction Failed.')));
      }
    } else {
      final url = Uri.parse(
          'http://10.107.254.37:8000/api/v1/transaction/list?user_id=$id');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          transactions = jsonResponse['result'];
        });
      } else {
        print('Failed to fetch transactions');
      }
    }
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
        id = prefs.getInt('id');
        level = prefs.getInt('level');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transaction List',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (BuildContext context, int index) {
          final transaction = transactions[index];

          return Card(
            margin: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transaction Code: ${transaction['transaction_code']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.0),
                      Text('Total Quantity: ${transaction['total_quantity']}'),
                      SizedBox(height: 8.0),
                      Text('Total Amount: ${transaction['total_amount']}'),
                    ],
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: transaction['data'].length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = transaction['data'][index];
                    return ListTile(
                      title: Text('Product Name: ${item['product_name']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Quantity: ${item['transaction_quantity']}'),
                          Text('Price: ${item['product_price']}'),
                          Text('Total: ${item['transaction_total']}'),
                        ],
                      ),
                    );
                  },
                ),
                if (level == 1)
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Card(
                      child: ElevatedButton(
                        onPressed: () {},
                        child: Text('Approve'),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
