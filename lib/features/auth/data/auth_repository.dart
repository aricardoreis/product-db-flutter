import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product_db_flutter/core/http/dio_client.dart';
import 'package:product_db_flutter/core/storage/secure_storage.dart';
import 'package:product_db_flutter/features/auth/data/auth_api.dart';
import 'package:product_db_flutter/features/auth/domain/session.dart';

class AuthRepository {
  AuthRepository({required AuthApi api, required SecureStorage storage})
      : _api = api,
        _storage = storage;

  final AuthApi _api;
  final SecureStorage _storage;

  Future<Session> signIn({
    required String email,
    required String password,
  }) async {
    final session = await _api.login(email, password);
    await _storage.writeSession(session);
    return session;
  }

  Future<void> signOut() => _storage.clear();

  Future<Session?> restore() => _storage.readSession();
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    api: AuthApi(ref.read(bareDioProvider)),
    storage: ref.read(secureStorageProvider),
  );
});
