import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product_db_flutter/features/auth/data/auth_api.dart';

typedef Responder = Response<dynamic> Function(RequestOptions options);

Dio _buildDio(Responder responder) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        try {
          handler.resolve(responder(options));
        } on DioException catch (e) {
          handler.reject(e);
        }
      },
    ),
  );
  return dio;
}

Response<dynamic> _ok(RequestOptions options, Map<String, dynamic> body) =>
    Response<Map<String, dynamic>>(
      requestOptions: options,
      statusCode: 200,
      data: body,
    );

Map<String, dynamic> _validBody() => {
      'access_token': 'a',
      'refresh_token': 'r',
      'token_type': 'bearer',
      'expires_at': 123,
      'expires_in': 3600,
    };

void main() {
  group('AuthApi.login', () {
    test('posts to /auth/login with email + password and returns Session', () async {
      RequestOptions? captured;
      final dio = _buildDio((options) {
        captured = options;
        return _ok(options, _validBody());
      });

      final session = await AuthApi(dio).login('a@b.com', 'pw');

      expect(captured?.path, '/auth/login');
      expect(captured?.method, 'POST');
      expect(captured?.data, {'email': 'a@b.com', 'password': 'pw'});
      expect(session.accessToken, 'a');
      expect(session.refreshToken, 'r');
    });

    test('throws FormatException on empty body', () async {
      final dio = _buildDio(
        (options) => Response<Map<String, dynamic>>(
          requestOptions: options,
          statusCode: 200,
        ),
      );

      expect(
        () => AuthApi(dio).login('a@b.com', 'pw'),
        throwsA(isA<FormatException>()),
      );
    });

    test('propagates DioException on 401', () async {
      final dio = _buildDio((options) {
        throw DioException(
          requestOptions: options,
          response: Response<Map<String, dynamic>>(
            requestOptions: options,
            statusCode: 401,
            data: {'message': 'Unauthorized', 'statusCode': 401},
          ),
          type: DioExceptionType.badResponse,
        );
      });

      await expectLater(
        AuthApi(dio).login('a@b.com', 'pw'),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('AuthApi.refresh', () {
    test('posts to /auth/refresh with camelCase refreshToken', () async {
      RequestOptions? captured;
      final dio = _buildDio((options) {
        captured = options;
        return _ok(options, _validBody());
      });

      final session = await AuthApi(dio).refresh('rt');

      expect(captured?.path, '/auth/refresh');
      expect(captured?.method, 'POST');
      expect(captured?.data, {'refreshToken': 'rt'});
      expect(session.accessToken, 'a');
    });
  });
}
