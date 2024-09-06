// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:cipherbull/services/database_helper.dart';
import 'package:cipherbull/models/entry.dart';
import 'package:cipherbull/services/secure_storage_helper.dart';
import 'package:cipherbull/screens/add_entry_screen.dart';
import 'package:cipherbull/screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Entry> _passwords = [];
  final SecureStorageService _secureStorageService = SecureStorageService();
  DatabaseHelper? _databaseHelper; // Declare _databaseHelper globally

  @override
  void initState() {
    super.initState();
    _initializeDatabaseHelper(); // Initialize _databaseHelper in initState
  }

  // Initialize the DatabaseHelper globally
  Future<void> _initializeDatabaseHelper() async {
    String? dbName = await _secureStorageService.getDatabaseName();
    String? dbPassword = await _secureStorageService.getDatabasePassword();

    if (dbName != null && dbPassword != null) {
      _databaseHelper = DatabaseHelper(dbName: dbName, dbPassword: dbPassword);
      await _loadPasswords(); // Load passwords after initializing the database
    } else {
      // Handle case where dbName or dbPassword is null (e.g., logout)
      _showErrorDialog('Database credentials not found. Please log in again.');
    }
  }

  Future<void> _loadPasswords() async {
    if (_databaseHelper != null) {
      List<Entry> passwords = await _databaseHelper!.getEntries();
      setState(() {
        _passwords = passwords;
      });
    }
  }

  Future<void> _deletePassword(int id) async {
    if (_databaseHelper != null) {
      await _databaseHelper!.deleteEntry(id);
      _loadPasswords(); // Reload passwords after deletion
    }
  }

  void _addNewEntry() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => AddEntryScreen(
                dbHelper: _databaseHelper!), // Pass the dbHelper instance
          ),
        )
        .then(
            (_) => _loadPasswords()); // Reload passwords after adding a new one
  }

  Future<void> _logout() async {
    await _secureStorageService
        .clearCredentials(); // Clear credentials from secure storage
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (context) =>
              LoginScreen()), // Redirect to login screen after logout
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
      appBar: AppBar(
        title: const Text('CipherBull'),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'Logout') {
                _logout(); // Call logout if the user selects Logout
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _passwords.length,
        itemBuilder: (context, index) {
          Entry password = _passwords[index];
          return ListTile(
            title: Text(password.title),
            subtitle: Text(password.username),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _deletePassword(password.id!);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewEntry,
        child: const Icon(Icons.add),
      ),
    );
  }
}
