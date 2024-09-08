import 'package:flutter/material.dart';
import 'package:cipherbull/services/database_helper.dart';
import 'package:cipherbull/models/entry.dart';
import 'package:cipherbull/services/secure_storage_helper.dart';
import 'package:cipherbull/screens/add_entry_screen.dart';
import 'package:cipherbull/screens/login_screen.dart';
import 'package:cipherbull/screens/entry_view_screen.dart';
import 'package:cipherbull/screens/password_generator_screen.dart'; // Import the Password Generator Screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Entry> _passwords = [];
  final SecureStorageService _secureStorageService = SecureStorageService();
  DatabaseHelper? _databaseHelper;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeDatabaseHelper();
  }

  // Initialize the DatabaseHelper globally
  Future<void> _initializeDatabaseHelper() async {
    String? dbName = await _secureStorageService.getDatabaseName();
    String? dbPassword = await _secureStorageService.getDatabasePassword();

    if (dbName != null && dbPassword != null) {
      _databaseHelper = DatabaseHelper(dbName: dbName, dbPassword: dbPassword);
      await _loadPasswords();
    } else {
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
      _loadPasswords();
    }
  }

  void _addNewEntry() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => AddEntryScreen(dbHelper: _databaseHelper!),
          ),
        )
        .then((_) => _loadPasswords());
  }

  Future<void> _logout() async {
    await _secureStorageService.clearCredentials();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
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

  Widget _getSelectedScreen() {
    if (_selectedIndex == 0) {
      return ListView.builder(
        itemCount: _passwords.length,
        itemBuilder: (context, index) {
          Entry password = _passwords[index];
          return ListTile(
            title: Text(password.title),
            subtitle: Text(password.username),
            onTap: () {
              Navigator.of(context)
                  .push(
                MaterialPageRoute(
                  builder: (context) => EntryViewScreen(
                    entry: password,
                    dbHelper: _databaseHelper!,
                  ),
                ),
              )
                  .then((value) {
                setState(() {
                  _loadPasswords();
                });
              });
            },
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _deletePassword(password.id!);
              },
            ),
          );
        },
      );
    } else if (_selectedIndex == 1) {
      return PasswordGeneratorScreen(
        showSaveButton: false,
      );
    } else {
      return Container(); // Empty container for future screens
    }
  }

  // Handle bottom navigation bar tap
  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vault'),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'Logout') {
                _logout();
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
      body: _getSelectedScreen(),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _addNewEntry,
              child: const Icon(Icons.add),
            )
          : null, // Only show FAB on the home screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.lock),
            label: 'My Vault',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sync),
            label: 'Generator',
          ),
        ],
      ),
    );
  }
}
