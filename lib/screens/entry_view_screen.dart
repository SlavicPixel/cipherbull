import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cipherbull/models/entry.dart';
import 'package:cipherbull/services/database_helper.dart';
import 'package:cipherbull/screens/entry_edit_screen.dart';

//ignore: must_be_immutable
class EntryViewScreen extends StatefulWidget {
  Entry entry;
  final DatabaseHelper dbHelper;

  EntryViewScreen({super.key, required this.entry, required this.dbHelper});

  @override
  // ignore: library_private_types_in_public_api
  _EntryViewScreenState createState() => _EntryViewScreenState();
}

class _EntryViewScreenState extends State<EntryViewScreen> {
  bool _isPasswordVisible = false;

  Future<void> _deleteEntry() async {
    await widget.dbHelper.deleteEntry(widget.entry.id!);
    if (mounted) Navigator.of(context).pop(true);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteEntry();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _editEntry() async {
    final updatedEntry = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EntryEditScreen(
          entry: widget.entry,
          dbHelper: widget.dbHelper,
        ),
      ),
    );

    if (updatedEntry != null) {
      setState(() {
        widget.entry = updatedEntry;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Information'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'Delete') {
                _confirmDelete();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'Delete',
                  child: Text('Delete'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem('Title', widget.entry.title),
            _buildDetailItem('Username', widget.entry.username,
                isCopyable: true),
            _buildPasswordField('Password', widget.entry.password),
            _buildDetailItem('URL', widget.entry.url),
            _buildDetailItem('Notes', widget.entry.notes),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _editEntry,
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value,
      {bool isCopyable = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: TextEditingController(text: value),
                readOnly: true,
                decoration: const InputDecoration(border: InputBorder.none),
                style: const TextStyle(fontSize: 18),
              ),
            ),
            if (isCopyable) _buildCopyIcon(value),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPasswordField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: TextEditingController(text: value),
                obscureText: !_isPasswordVisible,
                readOnly: true,
                decoration: const InputDecoration(border: InputBorder.none),
                style: const TextStyle(fontSize: 18),
              ),
            ),
            IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            _buildCopyIcon(value),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCopyIcon(String value) {
    return IconButton(
      icon: const Icon(Icons.copy),
      onPressed: () {
        Clipboard.setData(ClipboardData(text: value));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Copied to clipboard')),
        );
      },
    );
  }
}
