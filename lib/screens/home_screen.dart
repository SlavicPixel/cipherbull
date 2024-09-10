import 'package:flutter/material.dart';
import 'package:cipherbull/services/database_helper.dart';
import 'package:cipherbull/models/entry.dart';
import 'package:cipherbull/services/secure_storage_helper.dart';
import 'package:cipherbull/screens/add_entry_screen.dart';
import 'package:cipherbull/screens/login_screen.dart';
import 'package:cipherbull/screens/entry_view_screen.dart';
import 'package:cipherbull/screens/password_generator_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Entry> _passwords = [];
  final SecureStorageService _secureStorageService = SecureStorageService();
  DatabaseHelper? _databaseHelper;

  int _selectedIndex = 0;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _initializeDatabaseHelper();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    bool isDarkMode = await _secureStorageService.loadThemePreference();
    setState(() {
      _isDarkMode = isDarkMode;
    });
  }

  Future<void> _saveThemePreference(bool isDarkMode) async {
    await _secureStorageService.saveThemePreference(isDarkMode);
  }

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

  Future<void> _showDeleteConfirmationDialog(int id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Entry'),
          content: const Text(
              'Are you sure you want to delete this entry? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                _deletePassword(id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addNewEntry() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => AddEntryScreen(
              dbHelper: _databaseHelper!,
              isDarkMode: _isDarkMode,
            ),
          ),
        )
        .then((_) => _loadPasswords());
  }

  Future<void> _logout() async {
    await _secureStorageService.clearCredentials();
    await _databaseHelper?.closeDatabase();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
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
      if (_passwords.isEmpty) {
        return const Center(
          child: Text(
            'There are no items in your vault.',
            style: TextStyle(fontSize: 18),
          ),
        );
      } else {
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
                  _showDeleteConfirmationDialog(password.id!);
                },
              ),
            );
          },
        );
      }
    } else if (_selectedIndex == 1) {
      return const PasswordGeneratorScreen(
        showSaveButton: false,
      );
    } else {
      return Container(); // Empty container for future screens
    }
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDarkMode
          ? ThemeData.dark(useMaterial3: true)
          : ThemeData.light(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('My Vault'),
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: (String result) {
                if (result == 'Logout') {
                  _logout();
                } else if (result == 'Toggle Theme') {
                  setState(() {
                    _isDarkMode = !_isDarkMode;
                    _saveThemePreference(_isDarkMode);
                  });
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'Toggle Theme',
                  child: Text(_isDarkMode
                      ? 'Switch to Light Mode'
                      : 'Switch to Dark Mode'),
                ),
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
      ),
    );
  }
}
