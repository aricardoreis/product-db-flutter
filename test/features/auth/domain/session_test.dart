import 'package:flutter_test/flutter_test.dart';
import 'package:product_db_flutter/features/auth/domain/session.dart';

void main() {
  group('Session.fromJson', () {
    test('parses all fields from backend payload', () {
      final session = Session.fromJson({
        'access_token': 'a-token',
        'refresh_token': 'r-token',
        'token_type': 'bearer',
        'expires_at': 1735689600,
        'expires_in': 3600,
      });

      expect(session.accessToken, 'a-token');
      expect(session.refreshToken, 'r-token');
      expect(session.tokenType, 'bearer');
      expect(session.expiresAt, 1735689600);
    });

    test('defaults token_type to "bearer" when missing', () {
      final session = Session.fromJson({
        'access_token': 'a',
        'refresh_token': 'r',
      });

      expect(session.tokenType, 'bearer');
    });

    test('defaults expires_at to 0 when missing', () {
      final session = Session.fromJson({
        'access_token': 'a',
        'refresh_token': 'r',
      });

      expect(session.expiresAt, 0);
    });

    test('throws when access_token is missing', () {
      expect(
        () => Session.fromJson({'refresh_token': 'r'}),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('Session.toJson', () {
    test('round-trips through fromJson', () {
      const original = Session(
        accessToken: 'a',
        refreshToken: 'r',
        tokenType: 'bearer',
        expiresAt: 42,
      );

      final reparsed = Session.fromJson(original.toJson());

      expect(reparsed.accessToken, original.accessToken);
      expect(reparsed.refreshToken, original.refreshToken);
      expect(reparsed.tokenType, original.tokenType);
      expect(reparsed.expiresAt, original.expiresAt);
    });

    test('emits backend snake_case keys', () {
      const session = Session(
        accessToken: 'a',
        refreshToken: 'r',
        tokenType: 'bearer',
        expiresAt: 1,
      );

      expect(session.toJson().keys, containsAll(<String>[
        'access_token',
        'refresh_token',
        'token_type',
        'expires_at',
      ]));
    });
  });
}
