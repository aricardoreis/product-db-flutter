import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product_db_flutter/core/http/dio_client.dart';
import 'package:product_db_flutter/features/products/domain/product.dart';
import 'package:product_db_flutter/features/products/domain/product_details.dart';

class ProductsPage {
  const ProductsPage({required this.items, required this.total});
  final List<Product> items;
  final int total;
}

class ProductsApi {
  ProductsApi(this._dio);

  final Dio _dio;

  Future<ProductsPage> list({
    required int page,
    required int limit,
    String? keyword,
    String sort = 'name:asc',
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/products',
      queryParameters: {
        'page': page,
        'limit': limit,
        'sort': sort,
        if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
      },
    );
    final body = res.data;
    if (body == null) {
      throw const FormatException('Empty products response');
    }
    final items = (body['result'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList();
    return ProductsPage(
      items: items,
      total: (body['total'] as num? ?? 0).toInt(),
    );
  }

  Future<ProductDetails> byId(int id) async {
    final res = await _dio.get<Map<String, dynamic>>('/products/$id');
    final result = res.data?['result'] as Map<String, dynamic>?;
    if (result == null) {
      throw const FormatException('Empty product response');
    }
    return ProductDetails.fromJson(result);
  }
}

final productsApiProvider = Provider<ProductsApi>((ref) {
  return ProductsApi(ref.read(dioProvider));
});
