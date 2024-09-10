import 'package:flutter/material.dart';
import 'package:cipherbull/models/entry.dart';
import 'package:cipherbull/services/database_helper.dart';
import 'package:cipherbull/screens/password_generator_screen.dart';

class EntryEditScreen extends StatefulWidget {
  final Entry entry;
  final DatabaseHelper dbHelper;

  const EntryEditScreen(
      {super.key, required this.entry, required this.dbHelper});

  @override
  // ignore: library_private_types_in_public_api
  _EntryEditScreenState createState() => _EntryEditScreenState();
}

class _EntryEditScreenState extends State<EntryEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _urlController;
  late TextEditingController _notesController;
  bool _isPasswordVisible = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry.title);
    _usernameController = TextEditingController(text: widget.entry.username);
    _passwordController = TextEditingController(text: widget.entry.password);
    _urlController = TextEditingController(text: widget.entry.url);
    _notesController = TextEditingController(text: widget.entry.notes);
  }

  Future<void> _saveEntry() async {
    String updatedTitle = _titleController.text;
    String updatedUsername = _usernameController.text;
    String updatedPassword = _passwordController.text;
    String updatedUrl = _urlController.text;
    String updatedNotes = _notesController.text;

    if (updatedTitle.isNotEmpty &&
        updatedUsername.isNotEmpty &&
        updatedPassword.isNotEmpty) {
      Entry updatedEntry = Entry(
        id: widget.entry.id,
        title: updatedTitle,
        username: updatedUsername,
        password: updatedPassword,
        url: updatedUrl,
        notes: updatedNotes,
      );

      await widget.dbHelper.updateEntry(updatedEntry);

      if (mounted) Navigator.of(context).pop(updatedEntry);
    } else {
      _showErrorDialog(
          'Please fill out all required fields (Title, Username, and Password).');
    }
  }

  void _generatedPassword() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => const PasswordGeneratorScreen(),
      ),
    )
        .then((result) {
      if (result != null) {
        setState(() {
          _passwordController.text = result;
        });
      }
    });
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
              Row(
                children: [
                  Expanded(
                    child: _buildEditableField('Password', _passwordController,
                        obscureText: _isPasswordVisible),
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
                  IconButton(
                    icon: const Icon(Icons.sync),
                    onPressed: _generatedPassword,
                  ),
                ],
              ),
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
