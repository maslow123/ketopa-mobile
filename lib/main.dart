import 'package:flutter/material.dart';
import 'package:pharmacy_apps/admin/add.dart';
import 'package:pharmacy_apps/admin/approvel.dart';
import 'package:pharmacy_apps/admin/index.dart';
import 'package:pharmacy_apps/admin/product.dart';
import 'package:pharmacy_apps/admin/users_list.dart';
import 'package:pharmacy_apps/cart.dart';
import 'package:pharmacy_apps/home.dart';
import 'package:pharmacy_apps/list-transaction.dart';
import 'package:pharmacy_apps/login.dart';
import 'package:pharmacy_apps/regis.dart';
import 'package:pharmacy_apps/upload.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    home: MainRouting(),
  ));
}

class MainRouting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('token')),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Menampilkan tampilan loading jika masih menunggu token
          return CircularProgressIndicator();
        } else {
          final String? token = snapshot.data;
          final Future<SharedPreferences> prefsFuture =
              SharedPreferences.getInstance();

          return FutureBuilder<SharedPreferences>(
            future: prefsFuture,
            builder: (context, prefsSnapshot) {
              if (prefsSnapshot.connectionState == ConnectionState.waiting) {
                // Menampilkan tampilan loading jika masih menunggu SharedPreferences
                return CircularProgressIndicator();
              } else {
                final SharedPreferences prefs = prefsSnapshot.data!;
                final int? level = prefs.getInt('level');
                String initialRoute;

                if (level == 1) {
                  initialRoute = '/admin';
                } else if (level == 0) {
                  initialRoute = '/home';
                } else {
                  initialRoute = '/login';
                }

                return MaterialApp(
                  initialRoute: initialRoute,
                  title: "Home",
                  routes: {
                    "/home": (context) => Home(),
                    "/login": (context) => Login(),
                    "/regis": (context) => Regis(),
                    "/cart": (context) => Cart(
                          tempCart: [],
                        ),
                    "/upload": (context) => Upload(),
                    "/list-transaction": (context) => ListTransactionPage(),
                    "/admin": (context) => Index(),
                    "/admin/list-user": (context) => UserList(),
                    "/admin/product": (context) => ListProduct(),
                    "/admin/add": (context) => AddProduct(),
                    "/admin/approvel": (context) => ApprovalTransaction(),
                  },
                  onGenerateRoute: (settings) {
                    if (settings.name == '/login' &&
                        (token == null || token.isEmpty)) {
                      // Jika token tidak ada, arahkan ke halaman login
                      return MaterialPageRoute(builder: (context) => Login());
                    }
                    // Tambahan kode lainnya jika diperlukan
                    return null;
                  },
                  onUnknownRoute: (settings) {
                    // Jika rute tidak ditemukan, arahkan ke halaman login
                    return MaterialPageRoute(builder: (context) => Login());
                  },
                );
              }
            },
          );
        }
      },
    );
  }
}
