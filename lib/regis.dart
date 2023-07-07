import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    title: "Daftar",
    home: Regis(),
  ));
}

class Regis extends StatefulWidget {
  @override
  _RegisState createState() => _RegisState();
}

class _RegisState extends State<Regis> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  void registerUser() async {
    String username = usernameController.text;
    String password = passwordController.text;
    String name = nameController.text;
    String address = addressController.text;
    String phoneNumber = phoneNumberController.text;

    Map<String, dynamic> requestData = {
      "username": username,
      "password": password,
      "level": 0,
      "fullname": name,
      "phone_number": phoneNumber,
      "address": address,
    };

    var apiUrl = Uri.parse('http://192.168.0.107:8000/api/v1/user/create');
    var response = await http.post(
      apiUrl,
      body: jsonEncode(requestData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Registration successful, handle the response if needed
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Registration successfully.')));
      print(response.body);
    } else {
      // Registration failed, handle the response if needed
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Registration failed.')));
      print(response.statusCode);
    }
  }

  void login() {
    Navigator.popAndPushNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 60, bottom: 20),
              child: Text(
                "Daftar",
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.people),
                  labelText: "Username",
                  hintText: "Masukkan Username",
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.key),
                  labelText: "Password",
                  hintText: "Masukkan Password",
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                  labelText: "Name",
                  hintText: "Masukkan Nama",
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                controller: addressController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                  labelText: "Address",
                  hintText: "Masukkan Alamat",
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                controller: phoneNumberController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                  labelText: "Phone Number",
                  hintText: "Masukkan Nomor Telepon",
                ),
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.only(bottom: 40, left: 20, right: 20, top: 30),
              child: GestureDetector(
                onTap: () {
                  // Handle registration button click
                  registerUser();
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      "Daftar",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: GestureDetector(
                onTap: login,
                child: Text("Login"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
