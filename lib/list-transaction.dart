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

  void postApprove(transactionId) async {
    var apiUrl = Uri.parse(
        'http://192.168.0.107:8000/api/v1/transaction/$transactionId');
    var response = await http.put(
      apiUrl,
      body: jsonEncode({"status": 1}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Registration successful, handle the response if needed
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Status Approved.')));
      print(response.body);
      fetchTransactions();
    } else {
      // Registration failed, handle the response if needed
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed.')));
      print(response.body);
    }
  }

  Future<void> fetchTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt('id');
    int? level = prefs.getInt('level');
    print(level);

    if (level == 1) {
      final url = Uri.parse(
          'http://192.168.0.107:8000/api/v1/transaction/list?user_id=0');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        List<dynamic> transactions = jsonResponse['result'];

        // Sort transactions based on the transaction_status
        transactions.sort((a, b) => a['data'][0]['transaction_status']
            .compareTo(b['data'][0]['transaction_status']));

        setState(() {
          this.transactions = transactions;
        });
        print("ini transaksi ${transactions}");
      } else {
        print('Failed to fetch transaction ${response.body}');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('List Transaction Failed.')));
      }
    } else {
      final url = Uri.parse(
          'http://192.168.0.107:8000/api/v1/transaction/list?user_id=$id');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          this.transactions = jsonResponse['result'];
        });
      } else {
        print('Failed to fetch transaction ${response.body}');
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
        ),
        // backgroundColor: Colors.white,
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
                      Image.network(
                        "http://192.168.0.107:8000/api/v1/upload/image/evidence/${transaction['data'][0]['transaction_evidence']}",
                        scale: 7,
                        errorBuilder: (context, error, stackTrace) {
                          if (error.toString().contains('ENOENT')) {
                            return Image.network(
                              'https://www.kliknusae.com/img/404.jpg',
                              scale: 1,
                            );
                          } else {
                            return Image.network(
                              'https://www.kliknusae.com/img/404.jpg',
                              scale: 1,
                            );
                            // return Container(); // or any other widget you want to display in case of other errors
                          }
                        },
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Transaction ID: ${transaction['transaction_code']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('Total Quantity: ${transaction['total_quantity']}'),
                      SizedBox(height: 8),
                      Text('Total Amount: Rp.${transaction['total_amount']}'),
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
                      title: Text('Nama Produk: ${item['product_name']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Quantity: ${item['transaction_quantity']}'),
                          Text('Price: Rp.${item['product_price']}'),
                          Text('Total: Rp.${item['transaction_total']}'),
                        ],
                      ),
                    );
                  },
                ),
                if (level == 1)
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              transaction['data'][0]['transaction_status'] == 1
                                  ? Colors.green
                                  : Colors.blue),
                      onPressed: () {
                        postApprove(transaction["transaction_code"]);
                      },
                      child: Text(
                          transaction['data'][0]['transaction_status'] == 1
                              ? 'Approved'
                              : 'Approve'),
                    ),
                  ),
                if (level == 0)
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              transaction['data'][0]['transaction_status'] == 1
                                  ? Colors.green
                                  : Color.fromARGB(255, 217, 159, 35)),
                      onPressed: () {},
                      child: Text(
                          transaction['data'][0]['transaction_status'] == 1
                              ? 'Approved'
                              : 'Pending'),
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
