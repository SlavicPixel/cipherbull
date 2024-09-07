// lib/screens/entry_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:cipherbull/models/entry.dart';
import 'package:cipherbull/services/database_helper.dart';

class EntryEditScreen extends StatefulWidget {
  final Entry entry; // The entry to be edited
  final DatabaseHelper dbHelper; // Database helper to save the updated entry

  EntryEditScreen({required this.entry, required this.dbHelper});

  @override
  _EntryEditScreenState createState() => _EntryEditScreenState();
}

class _EntryEditScreenState extends State<EntryEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _urlController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    // Initialize text controllers with the current values of the entry
    _titleController = TextEditingController(text: widget.entry.title);
    _usernameController = TextEditingController(text: widget.entry.username);
    _passwordController = TextEditingController(text: widget.entry.password);
    _urlController = TextEditingController(text: widget.entry.url);
    _notesController = TextEditingController(text: widget.entry.notes);
  }

  // Function to save the updated entry
  Future<void> _saveEntry() async {
    String updatedTitle = _titleController.text;
    String updatedUsername = _usernameController.text;
    String updatedPassword = _passwordController.text;
    String updatedUrl = _urlController.text;
    String updatedNotes = _notesController.text;

    // Ensure required fields are filled
    if (updatedTitle.isNotEmpty &&
        updatedUsername.isNotEmpty &&
        updatedPassword.isNotEmpty) {
      // Create a new updated Entry object
      Entry updatedEntry = Entry(
        id: widget.entry.id, // Keep the same ID
        title: updatedTitle,
        username: updatedUsername,
        password: updatedPassword,
        url: updatedUrl,
        notes: updatedNotes,
      );

      // Save the updated entry to the database
      await widget.dbHelper.updateEntry(updatedEntry);

      // Navigate back to the EntryViewScreen with the updated entry
      Navigator.of(context).pop(updatedEntry);
    } else {
      _showErrorDialog(
          'Please fill out all required fields (Title, Username, and Password).');
    }
  }

  // Show error dialog if required fields are missing
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
        title: const Text('Edit Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEditableField('Title', _titleController),
              _buildEditableField('Username', _usernameController),
              _buildEditableField('Password', _passwordController,
                  obscureText: true),
              _buildEditableField('URL', _urlController),
              _buildEditableField('Notes', _notesController, maxLines: 5),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveEntry,
        child: const Icon(Icons.check),
      ),
    );
  }

  // Helper function to build editable text fields
  Widget _buildEditableField(String label, TextEditingController controller,
      {bool obscureText = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        TextField(
          controller: controller,
          obscureText: obscureText,
          maxLines: maxLines,
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
          ),
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
