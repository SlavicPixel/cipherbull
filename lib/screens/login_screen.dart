// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:cipherbull/services/secure_storage_helper.dart';
import 'package:cipherbull/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final SecureStorageService _secureStorageService = SecureStorageService();

  void _login() async {
    String dbName = _usernameController.text;
    String password = _passwordController.text;

    if (dbName.isNotEmpty && password.isNotEmpty) {
      await _secureStorageService.storeDatabaseName(dbName);
      await _secureStorageService.storeDatabasePassword(password);

      // Navigate to home screen with the dbName and dbPassword
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
    } else {
      // Show error
      _showErrorDialog('Please enter both username and password');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login/Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login/Register'),
            ),
          ],
        ),
      ),
    );
  }
}
