import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserList extends StatefulWidget {
  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  List<Map<String, dynamic>> userList = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response =
        await http.get(Uri.parse('http://192.168.0.107:8000/api/v1/user/list'));
    final responseData = json.decode(response.body);

    setState(() {
      userList = List<Map<String, dynamic>>.from(responseData['result']);
    });
  }

  Future<void> deleteUser(int index) async {
    final userId = userList[index]['id'];
    final url = Uri.parse('http://192.168.0.107:8000/api/v1/user/$userId');

    final response = await http.delete(url);

    if (response.statusCode == 200) {
      setState(() {
        userList.removeAt(index);
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('User deleted successfully.')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to delete user.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
      ),
      body: userList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: userList.length,
              itemBuilder: (context, index) {
                final user = userList[index];

                return ListTile(
                  title: Text('Username: ${user['username']}'),
                  subtitle: Text('Full Name: ${user['fullname']}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => deleteUser(index),
                  ),
                );
              },
            ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: UserList(),
  ));
}
