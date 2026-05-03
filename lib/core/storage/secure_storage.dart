import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:product_db_flutter/features/auth/domain/session.dart';

class SecureStorage {
  SecureStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _sessionKey = 'auth.session';

  Future<Session?> readSession() async {
    final raw = await _storage.read(key: _sessionKey);
    if (raw == null) return null;
    return Session.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> writeSession(Session session) =>
      _storage.write(key: _sessionKey, value: jsonEncode(session.toJson()));

  Future<void> clear() => _storage.delete(key: _sessionKey);
}

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage(const FlutterSecureStorage());
});
