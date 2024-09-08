import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cipherbull/models/password_generator.dart'; // Import the translated password generator

class PasswordGeneratorScreen extends StatefulWidget {
  final bool showSaveButton;

  PasswordGeneratorScreen({this.showSaveButton = true});

  @override
  _PasswordGeneratorScreenState createState() =>
      _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  int _passwordLength = 12;
  bool _includeUppercase = true;
  bool _includeLowercase = true; // Lowercase always starts enabled
  bool _includeNumbers = true;
  bool _includeSpecialChars = true;
  String _generatedPassword = "";

  @override
  void initState() {
    super.initState();
    _generatePassword(); // Generate a password on load
  }

  // Function to generate password based on current settings
  void _generatePassword() {
    PasswordGenerator.clear(); // Clear previous generators

    // Add generators based on toggle settings
    if (_includeUppercase) PasswordGenerator.add(UpperCaseGenerator());
    if (_includeLowercase) PasswordGenerator.add(LowerCaseGenerator());
    if (_includeNumbers) PasswordGenerator.add(NumericGenerator());
    if (_includeSpecialChars) PasswordGenerator.add(SpecialCharGenerator());

    // Ensure at least lowercase is included
    if (PasswordGenerator.isEmpty()) {
      PasswordGenerator.add(LowerCaseGenerator());
      setState(() {
        _includeLowercase = true; // Force lowercase to be enabled
      });
    }

    // Generate the password
    setState(() {
      _generatedPassword = PasswordGenerator.generatePassword(_passwordLength);
    });
  }

  // Copy the password to clipboard
  void _copyPassword() {
    Clipboard.setData(ClipboardData(text: _generatedPassword));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: const Text("Password copied to clipboard")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Password Generator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the generated password
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: _generatedPassword),
                    readOnly: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Generated Password',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: _copyPassword, // Copy password to clipboard
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _generatePassword, // Refresh the password
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Password length slider
            Text("Length: $_passwordLength"),
            Slider(
              value: _passwordLength.toDouble(),
              min: 4,
              max: 128,
              divisions: 124,
              label: _passwordLength.toString(),
              onChanged: (double value) {
                setState(() {
                  _passwordLength = value.toInt();
                  _generatePassword(); // Regenerate password when length changes
                });
              },
            ),

            // Toggle switches for password options
            SwitchListTile(
              title: const Text("Uppercase (A-Z)"),
              value: _includeUppercase,
              onChanged: (bool value) {
                setState(() {
                  _includeUppercase = value;
                  _generatePassword(); // Regenerate password when toggle changes
                });
              },
            ),
            SwitchListTile(
              title: const Text("Lowercase (a-z)"),
              value: _includeLowercase,
              onChanged: (bool value) {
                // Ensure lowercase cannot be disabled if all others are off
                if (!value &&
                    !_includeUppercase &&
                    !_includeNumbers &&
                    !_includeSpecialChars) {
                  return; // Do nothing to prevent disabling all
                }
                setState(() {
                  _includeLowercase = value;
                  _generatePassword(); // Regenerate password when toggle changes
                });
              },
            ),
            SwitchListTile(
              title: const Text("Numbers (0-9)"),
              value: _includeNumbers,
              onChanged: (bool value) {
                setState(() {
                  _includeNumbers = value;
                  _generatePassword(); // Regenerate password when toggle changes
                });
              },
            ),
            SwitchListTile(
              title: const Text("Special Characters (!@#\$%^&*)"),
              value: _includeSpecialChars,
              onChanged: (bool value) {
                setState(() {
                  _includeSpecialChars = value;
                  _generatePassword(); // Regenerate password when toggle changes
                });
              },
            ),

            const SizedBox(height: 20),
            if (widget.showSaveButton)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Implement save functionality
                  },
                  child: const Text("Save Password"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
