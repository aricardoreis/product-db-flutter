import 'package:product_db_flutter/features/products/domain/price_history_entry.dart';

class ProductDetails {
  const ProductDetails({
    required this.id,
    required this.name,
    required this.code,
    required this.amount,
    required this.type,
    required this.isEan,
    required this.priceHistory,
  });

  factory ProductDetails.fromJson(Map<String, dynamic> json) {
    final amount = switch (json['amount']) {
      final num n => n.toDouble(),
      final String s => double.tryParse(s) ?? 0.0,
      _ => 0.0,
    };
    return ProductDetails(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      amount: amount,
      type: json['type'] as String? ?? '',
      isEan: json['isEan'] as bool? ?? false,
      priceHistory: (json['priceHistory'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(PriceHistoryEntry.fromJson)
          .toList(),
    );
  }

  final int id;
  final String name;
  final String code;
  final double amount;
  final String type;
  final bool isEan;
  final List<PriceHistoryEntry> priceHistory;

  double? get latestPrice =>
      priceHistory.isEmpty ? null : priceHistory.first.value;
  DateTime? get latestDate =>
      priceHistory.isEmpty ? null : priceHistory.first.date;
}
