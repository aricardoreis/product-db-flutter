import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:product_db_flutter/core/storage/secure_storage.dart';
import 'package:product_db_flutter/features/auth/data/auth_api.dart';
import 'package:product_db_flutter/features/auth/data/auth_repository.dart';
import 'package:product_db_flutter/features/auth/domain/session.dart';

class _MockAuthApi extends Mock implements AuthApi {}

class _MockSecureStorage extends Mock implements SecureStorage {}

const _session = Session(
  accessToken: 'a',
  refreshToken: 'r',
  tokenType: 'bearer',
  expiresAt: 42,
);

void main() {
  late _MockAuthApi api;
  late _MockSecureStorage storage;
  late AuthRepository repo;

  setUpAll(() {
    registerFallbackValue(_session);
  });

  setUp(() {
    api = _MockAuthApi();
    storage = _MockSecureStorage();
    repo = AuthRepository(api: api, storage: storage);
  });

  group('signIn', () {
    test('calls api.login then writes session and returns it', () async {
      when(() => api.login('e', 'p')).thenAnswer((_) async => _session);
      when(() => storage.writeSession(any())).thenAnswer((_) async {});

      final result = await repo.signIn(email: 'e', password: 'p');

      expect(result, _session);
      verifyInOrder([
        () => api.login('e', 'p'),
        () => storage.writeSession(_session),
      ]);
    });

    test('does not write storage when api throws', () async {
      when(() => api.login(any(), any())).thenThrow(Exception('boom'));

      await expectLater(
        repo.signIn(email: 'e', password: 'p'),
        throwsException,
      );
      verifyNever(() => storage.writeSession(any()));
    });
  });

  group('signOut', () {
    test('clears storage', () async {
      when(() => storage.clear()).thenAnswer((_) async {});

      await repo.signOut();

      verify(() => storage.clear()).called(1);
    });
  });

  group('restore', () {
    test('returns session from storage', () async {
      when(() => storage.readSession()).thenAnswer((_) async => _session);

      expect(await repo.restore(), _session);
    });

    test('returns null when storage is empty', () async {
      when(() => storage.readSession()).thenAnswer((_) async => null);

      expect(await repo.restore(), isNull);
    });
  });
}
