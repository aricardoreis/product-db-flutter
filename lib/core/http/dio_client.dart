import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product_db_flutter/core/env.dart';
import 'package:product_db_flutter/core/http/auth_interceptor.dart';

BaseOptions _baseOptions() => BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 5),
      sendTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: Headers.jsonContentType,
    );

final bareDioProvider = Provider<Dio>((ref) => Dio(_baseOptions()));

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(_baseOptions());
  dio.interceptors.add(AuthInterceptor(ref));
  return dio;
});
