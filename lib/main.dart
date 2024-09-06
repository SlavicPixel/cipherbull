// lib/main.dart
import 'package:flutter/material.dart';
import 'package:cipherbull/screens/login_screen.dart';
import 'package:cipherbull/screens/home_screen.dart';
import 'package:cipherbull/services/secure_storage_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(), // Start with a splash screen to check login state
    );
  }
}

class SplashScreen extends StatelessWidget {
  final SecureStorageService _secureStorageService = SecureStorageService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkLoginState(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          return snapshot.data == true ? HomeScreen() : LoginScreen();
        }
      },
    );
  }

  Future<bool> _checkLoginState() async {
    // Check if the user is already logged in by seeing if we have a saved database password
    String? dbPassword = await _secureStorageService.getDatabasePassword();
    return dbPassword != null;
  }
}
