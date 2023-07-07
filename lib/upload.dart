import 'package:flutter/material.dart';

class Upload extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pembayaran',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BankListPage(),
    );
  }
}

class BankListPage extends StatelessWidget {
  final List<Bank> banks = [
    Bank('Bank BCA', '1234567890',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/Bank_Central_Asia.svg/2560px-Bank_Central_Asia.svg.png'),
    Bank('Bank BRI ', '9876543210',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/6/68/BANK_BRI_logo.svg/1280px-BANK_BRI_logo.svg.png'),
    Bank('Bank MANDIRI', '2468135790',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ad/Bank_Mandiri_logo_2016.svg/2560px-Bank_Mandiri_logo_2016.svg.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pembayaran'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: banks.length,
              itemBuilder: (context, index) {
                final bank = banks[index];
                return BankCard(bank: bank);
              },
            ),
          ),
          Container(
            height: 100,
            color: Colors.grey[200],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Upload Bukti Pembayaran',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: pickImage,
                    icon: Icon(Icons.upload),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Bank {
  final String name;
  final String accountNumber;
  final String logoUrl;

  Bank(this.name, this.accountNumber, this.logoUrl);
}

class BankCard extends StatelessWidget {
  final Bank bank;

  BankCard({required this.bank});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.network(
          bank.logoUrl,
          width: 48,
          height: 48,
        ),
        title: Text(bank.name),
        subtitle: Text('Account Number: ${bank.accountNumber}'),
        onTap: () {
          // TODO: Implement bank card tap logic
        },
      ),
    );
  }
}

void pickImage() {
  // TODO: Implement image selection logic
}
