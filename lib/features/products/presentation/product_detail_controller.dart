import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:product_db_flutter/features/products/data/products_api.dart';
import 'package:product_db_flutter/features/products/domain/product_details.dart';

final FutureProviderFamily<ProductDetails, int> productDetailProvider =
    FutureProvider.autoDispose.family<ProductDetails, int>((ref, id) {
  return ref.read(productsApiProvider).byId(id);
});
