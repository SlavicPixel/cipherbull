import 'package:flutter/material.dart';
import 'package:cipherbull/services/database_helper.dart';
import 'package:cipherbull/services/secure_storage_helper.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final SecureStorageService _secureStorageService = SecureStorageService();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _firstTap = false;
  bool _isPasswordVisible = true;
  bool _isConfirmPasswordVisible = true;

  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    bool isDarkMode = await _secureStorageService.loadThemePreference();
    setState(() {
      _isDarkMode = isDarkMode;
    });
  }

  void _createVault() async {
    if (_formKey.currentState!.validate()) {
      String username = _usernameController.text;
      String password = _passwordController.text;

      try {
        DatabaseHelper dbHelper =
            DatabaseHelper(dbName: username, dbPassword: password);

        if (await dbHelper.checkDatabaseExists() != true) {
          if (_firstTap == false) {
            await _showDialog(
                'Warning',
                """
  Make sure to remember you password. Due to security reasons, there is no way to recover your password in case you forget it.
  
  Your username is used as your database filename and your password is used to encrypt the database, therefore your password is not stored anywhere and is unrecoverable.""",
                buttonMsg: 'I understand');
            _firstTap = true;
          } else {
            await dbHelper.getEntries();
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            }
          }
        } else {
          _showDialog('Error', "Vault with name '$username' already exists.");
        }
      } catch (e) {
        _showDialog('Error', 'Error creating the database: ${e.toString()}');
      }
    }
  }

  Future<void> _showDialog(String title, String message,
      {String buttonMsg = 'OK'}) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(buttonMsg),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDarkMode
          ? ThemeData.dark(useMaterial3: true)
          : ThemeData.light(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text('Create vault')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Create New Vault",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _passwordController,
                        decoration:
                            const InputDecoration(labelText: 'Password'),
                        obscureText: _isPasswordVisible,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          return null;
                        },
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
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        decoration: const InputDecoration(
                            labelText: 'Confirm Password'),
                        obscureText: _isConfirmPasswordVisible,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32.0),
                Center(
                  child: ElevatedButton(
                    onPressed: _createVault,
                    child: const Text('Confirm'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
