import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    title: "List Transaction",
    home: ApprovalTransaction(),
  ));
}

class ApprovalTransaction extends StatefulWidget {
  @override
  _ApprovalTransactionState createState() => _ApprovalTransactionState();
}

class _ApprovalTransactionState extends State<ApprovalTransaction> {
  List<Transaction> transactions = [];

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    final response = await http
        .get(Uri.parse('http://192.168.0.107:8000/api/v1/transaction/list'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final result = data['result'][0];
      final transactionData = result['data'];
      setState(() {
        transactions = List<Transaction>.from(
          transactionData.map((x) =>
              Transaction.fromJson({...x, 'image': x['transaction_image']})),
        );
      });
    }
  }

  Future<void> updateTransactionStatus(
      String transactionCode, int newStatus) async {
    final url = Uri.parse(
        'http://192.168.0.107:8000/api/v1/transaction/$transactionCode');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': newStatus}),
    );

    if (response.statusCode == 200) {
      // Status updated successfully
      // You can handle the response as per your requirement
    } else {
      // Failed to update status
      // You can handle the error or display an error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Approval Transaction'),
      ),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          Transaction transaction = transactions[index];
          return TransactionCard(
            transaction: transaction,
            onApprove: () {
              setState(() {
                // Update the transaction status to 'Approved'
                transaction.status = 'Approved';
              });
              // Call the updateTransactionStatus method
              updateTransactionStatus(transaction.transactionId, 1);
            },
          );
        },
      ),
    );
  }
}

class Transaction {
  String transactionId;
  int transactionQuantity;
  double transactionTotal;
  int transactionStatus;
  String transactionEvidence;
  DateTime transactionCreatedAt;
  int productId;
  String productName;
  double productPrice;
  int userId;
  String userFullName;
  String _status;
  String image;

  Transaction({
    required this.transactionId,
    required this.transactionQuantity,
    required this.transactionTotal,
    required this.transactionStatus,
    required this.transactionEvidence,
    required this.transactionCreatedAt,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.userId,
    required this.userFullName,
    required this.image,
  }) : _status = transactionStatus == 1 ? 'Approved' : 'Pending';

  String get status => _status;

  set status(String value) {
    _status = value;
    transactionStatus = value == 'Approved' ? 1 : 0;
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      transactionId: json['transaction_id'].toString(),
      transactionQuantity: json['transaction_quantity'],
      transactionTotal: double.parse(json['transaction_total'].toString()),
      transactionStatus: json['transaction_status'],
      transactionEvidence: json['transaction_evidence'],
      transactionCreatedAt: DateTime.parse(json['transaction_created_at']),
      productId: json['product_id'],
      productName: json['product_name'],
      productPrice: double.parse(json['product_price'].toString()),
      userId: json['user_id'],
      userFullName: json['user_fullname'],
      image: json['image'] ?? '',
    );
  }
}

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onApprove;

  TransactionCard({
    required this.transaction,
    required this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction ID: ${transaction.transactionId}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            // Display the image
            Image.network(transaction.image),
            Text('Product ID: ${transaction.productId}'),
            Text('User ID: ${transaction.userId}'),
            Text('Quantity: ${transaction.transactionQuantity}'),
            Text(
              'Total: \Rp.${transaction.transactionTotal.toStringAsFixed(2)}',
            ),
            SizedBox(height: 8.0),
            Text(
              'Status: ${transaction.status}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: onApprove,
              child: Text('Approve'),
            ),
          ],
        ),
      ),
    );
  }
}
