import 'package:dio/dio.dart';
import 'package:product_db_flutter/features/auth/domain/session.dart';

class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  Future<Session> login(String email, String password) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return _parse(res.data);
  }

  Future<Session> refresh(String refreshToken) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    return _parse(res.data);
  }

  Session _parse(Map<String, dynamic>? body) {
    if (body == null) {
      throw const FormatException('Empty auth response');
    }
    return Session.fromJson(body);
  }
}
