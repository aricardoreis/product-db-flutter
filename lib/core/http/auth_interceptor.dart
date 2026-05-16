import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product_db_flutter/core/http/dio_client.dart';
import 'package:product_db_flutter/core/storage/secure_storage.dart';
import 'package:product_db_flutter/features/auth/data/auth_api.dart';
import 'package:product_db_flutter/features/auth/domain/session.dart';

class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor(this._ref);

  final Ref _ref;

  SecureStorage get _storage => _ref.read(secureStorageProvider);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final session = await _storage.readSession();
    if (session != null) {
      options.headers['Authorization'] = 'Bearer ${session.accessToken}';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final isRefreshCall = err.requestOptions.path.contains('/auth/refresh');
    if (!isUnauthorized || isRefreshCall) {
      handler.next(err);
      return;
    }

    final session = await _storage.readSession();
    if (session == null) {
      handler.next(err);
      return;
    }

    Session refreshed;
    try {
      final api = AuthApi(_ref.read(bareDioProvider));
      refreshed = await api.refresh(session.refreshToken);
      await _storage.writeSession(refreshed);
    } on Object {
      await _storage.clear();
      handler.next(err);
      return;
    }

    final retryOptions = err.requestOptions
      ..headers['Authorization'] = 'Bearer ${refreshed.accessToken}';
    try {
      final response =
          await _ref.read(bareDioProvider).fetch<dynamic>(retryOptions);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}
