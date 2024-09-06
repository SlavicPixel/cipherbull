import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> storeDatabasePassword(String password) async {
    await _secureStorage.write(key: 'db_password', value: password);
  }

  Future<String?> getDatabasePassword() async {
    return await _secureStorage.read(key: 'db_password');
  }

  Future<void> storeDatabaseName(String dbName) async {
    await _secureStorage.write(key: 'db_name', value: dbName);
  }

  Future<String?> getDatabaseName() async {
    return await _secureStorage.read(key: 'db_name');
  }

  Future<void> clearCredentials() async {
    await _secureStorage.delete(key: 'db_password');
    await _secureStorage.delete(key: 'db_name');
  }
}
