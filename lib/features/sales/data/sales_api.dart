import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product_db_flutter/core/http/dio_client.dart';
import 'package:product_db_flutter/features/sales/domain/sale.dart';

class SalesPage {
  const SalesPage({required this.items, required this.total});
  final List<Sale> items;
  final int total;
}

class SalesApi {
  SalesApi(this._dio);

  final Dio _dio;

  Future<SalesPage> list({
    required int page,
    required int limit,
    String sort = 'date:desc',
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/sales',
      queryParameters: {'page': page, 'limit': limit, 'sort': sort},
    );
    final body = res.data;
    if (body == null) {
      throw const FormatException('Empty sales response');
    }
    final result = (body['result'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(Sale.fromJson)
        .toList();
    return SalesPage(
      items: result,
      total: (body['total'] as num? ?? 0).toInt(),
    );
  }
}

final salesApiProvider = Provider<SalesApi>((ref) {
  return SalesApi(ref.read(dioProvider));
});
