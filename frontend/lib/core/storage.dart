import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Storage {
  Storage._();

  static const _tokenKey = 'auth_token';
  static const FlutterSecureStorage _secure = FlutterSecureStorage();

  static Future<void> setToken(String token) =>
      _secure.write(key: _tokenKey, value: token);

  static Future<String?> getToken() =>
      _secure.read(key: _tokenKey);

  static Future<void> clearToken() =>
      _secure.delete(key: _tokenKey);
}
