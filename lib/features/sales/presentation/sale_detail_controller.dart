import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:product_db_flutter/features/sales/data/sales_api.dart';
import 'package:product_db_flutter/features/sales/domain/sale_details.dart';

final FutureProviderFamily<SaleDetails, String> saleDetailProvider =
    FutureProvider.autoDispose.family<SaleDetails, String>((ref, id) {
  return ref.read(salesApiProvider).byId(id);
});
