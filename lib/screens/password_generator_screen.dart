import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cipherbull/models/password_generator.dart';
import 'package:cipherbull/services/secure_storage_helper.dart';

class PasswordGeneratorScreen extends StatefulWidget {
  final bool showSaveButton;

  const PasswordGeneratorScreen({super.key, this.showSaveButton = true});

  @override
  // ignore: library_private_types_in_public_api
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

  final SecureStorageService _secureStorageService = SecureStorageService();
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
    _generatePassword();
  }

  Future<void> _loadThemePreference() async {
    bool isDarkMode = await _secureStorageService.loadThemePreference();
    setState(() {
      _isDarkMode = isDarkMode;
    });
  }

  void _generatePassword() {
    PasswordGenerator.clear();

    if (_includeUppercase) PasswordGenerator.add(UpperCaseGenerator());
    if (_includeLowercase) PasswordGenerator.add(LowerCaseGenerator());
    if (_includeNumbers) PasswordGenerator.add(NumericGenerator());
    if (_includeSpecialChars) PasswordGenerator.add(SpecialCharGenerator());

    if (PasswordGenerator.isEmpty()) {
      PasswordGenerator.add(LowerCaseGenerator());
      setState(() {
        _includeLowercase = true;
      });
    }

    setState(() {
      _generatedPassword = PasswordGenerator.generatePassword(_passwordLength);
    });
  }

  void _copyPassword() {
    Clipboard.setData(ClipboardData(text: _generatedPassword));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Password copied to clipboard")),
    );
  }

  void _savePassword() {
    Navigator.of(context).pop(_generatedPassword);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDarkMode
          ? ThemeData.dark(useMaterial3: true)
          : ThemeData.light(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text('Password Generator')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller:
                          TextEditingController(text: _generatedPassword),
                      readOnly: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Generated Password',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: _copyPassword,
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _generatePassword,
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
                    _generatePassword();
                  });
                },
              ),
              SwitchListTile(
                title: const Text("Uppercase (A-Z)"),
                value: _includeUppercase,
                onChanged: (bool value) {
                  setState(() {
                    _includeUppercase = value;
                    _generatePassword();
                  });
                },
              ),
              SwitchListTile(
                title: const Text("Lowercase (a-z)"),
                value: _includeLowercase,
                onChanged: (bool value) {
                  if (!value &&
                      !_includeUppercase &&
                      !_includeNumbers &&
                      !_includeSpecialChars) {
                    return;
                  }
                  setState(() {
                    _includeLowercase = value;
                    _generatePassword();
                  });
                },
              ),
              SwitchListTile(
                title: const Text("Numbers (0-9)"),
                value: _includeNumbers,
                onChanged: (bool value) {
                  setState(() {
                    _includeNumbers = value;
                    _generatePassword();
                  });
                },
              ),
              SwitchListTile(
                title: const Text("Special Characters (!@#\$%^&*)"),
                value: _includeSpecialChars,
                onChanged: (bool value) {
                  setState(() {
                    _includeSpecialChars = value;
                    _generatePassword();
                  });
                },
              ),
              const SizedBox(height: 20),
              if (widget.showSaveButton)
                Center(
                  child: ElevatedButton(
                    onPressed: _savePassword,
                    child: const Text("Save Password"),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
