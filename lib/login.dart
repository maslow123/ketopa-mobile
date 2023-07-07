import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    title: "Login",
    home: Login(),
  ));
}

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> login() async {
    final url = Uri.parse('http://10.107.254.37:8000/api/v1/user/login');
    print(usernameController.text);
    print(passwordController.text);
    final response = await http.post(url,
        body: json.encode({
          'username': usernameController.text,
          'password': passwordController.text,
        }),
        headers: {'Content-Type': 'application/json'});
    print(response.body);
    if (response.statusCode == 200) {
      // Successful login
      final responseData = json.decode(response.body);
      final token = responseData['token'];
      print(responseData['data']['id']);
      // Save the token to storage for session
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setInt('id', responseData['data']['id']);
      await prefs.setInt('level', responseData['data']['level']);
      await prefs.setString('name', responseData['data']['fullname']);
      await prefs.setString('phone', responseData['data']['phone_number']);
      await prefs.setString('address', responseData['data']['address']);
      // Redirect to '/home' route
      if (responseData['data']['level'] == 0) {
        Navigator.popAndPushNamed(context, '/home');
      } else {
        Navigator.popAndPushNamed(context, '/admin');
      }
    } else {
      print("Failed Login");
    }
  }

  void regis() {
    Navigator.popAndPushNamed(context, '/regis');
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 60, bottom: 20),
              child: Text(
                "Login",
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.only(right: 20, left: 20, bottom: 20, top: 10),
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
              padding: EdgeInsets.only(right: 20, left: 20),
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
              padding:
                  EdgeInsets.only(bottom: 40, left: 20, right: 20, top: 30),
              child: GestureDetector(
                onTap: login,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: GestureDetector(
                onTap: regis,
                child: Text("Daftar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
