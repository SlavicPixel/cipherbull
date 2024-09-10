// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:cipherbull/services/secure_storage_helper.dart';
import 'package:cipherbull/services/database_helper.dart';
import 'package:cipherbull/screens/home_screen.dart';
import 'package:cipherbull/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final SecureStorageService _secureStorageService = SecureStorageService();
  bool _isPasswordVisible = true;

  void _login() async {
    String dbName = _usernameController.text;
    String password = _passwordController.text;

    if (dbName.isNotEmpty && password.isNotEmpty) {
      final dbHelper = DatabaseHelper(dbName: dbName, dbPassword: password);
      if (await dbHelper.checkDatabaseExists()) {
        try {
          await dbHelper.getEntries();

          await _secureStorageService.storeDatabaseName(dbName);
          await _secureStorageService.storeDatabasePassword(password);

          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
          }
        } catch (e) {
          _showErrorDialog("Incorrect password or database name.");
        }
      } else {
        _showErrorDialog("Database with name '$dbName' does not exist.");
      }
    } else {
      _showErrorDialog('Please enter both username and password');
    }
  }

  void _createVault() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RegisterScreen(),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CipherBull')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Sign In",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    obscureText: _isPasswordVisible,
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password *',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 5),
              child: ElevatedButton(
                onPressed: _createVault,
                child: const Text('Create new vault'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
