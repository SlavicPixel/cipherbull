// lib/screens/add_entry_screen.dart
import 'package:flutter/material.dart';
import 'package:cipherbull/services/database_helper.dart';
import 'package:cipherbull/models/entry.dart';

class AddEntryScreen extends StatefulWidget {
  final DatabaseHelper dbHelper; // Pass the DatabaseHelper instance

  AddEntryScreen({required this.dbHelper});

  @override
  _AddEntryScreenState createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Function to handle the save action
  void _saveEntry() async {
    String title = _titleController.text;
    String username = _usernameController.text;
    String password = _passwordController.text;
    String url = _urlController.text;
    String notes = _notesController.text;

    if (title.isNotEmpty && username.isNotEmpty && password.isNotEmpty) {
      // Create a new Entry object
      Entry newEntry = Entry(
        title: title,
        username: username,
        password: password,
        url: url,
        notes: notes,
      );

      // Insert the new entry into the database
      await widget.dbHelper.insertEntry(newEntry);

      // Go back to the previous screen after saving
      Navigator.of(context).pop();
    } else {
      _showErrorDialog(
          'Please fill out all required fields (Title, Username, and Password).');
    }
  }

  // Function to show an error dialog if fields are missing
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
        title: const Text('Add New Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                ),
              ),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username *',
                ),
              ),
              TextField(
                obscureText: true,
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password *', // Hide password text
                ),
              ),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'URL',
                ),
              ),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveEntry,
                child: const Text('Save Entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
