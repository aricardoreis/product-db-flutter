import 'package:product_db_flutter/features/sales/domain/store.dart';

double _asDouble(Object? raw) => switch (raw) {
      final num n => n.toDouble(),
      final String s => double.tryParse(s) ?? 0.0,
      _ => 0.0,
    };

class SaleProductLine {
  const SaleProductLine({
    required this.name,
    required this.code,
    required this.type,
    required this.amount,
    required this.value,
  });

  factory SaleProductLine.fromJson(Map<String, dynamic> json) =>
      SaleProductLine(
        name: json['name'] as String? ?? '',
        code: json['code'] as String? ?? '',
        type: json['type'] as String? ?? '',
        amount: _asDouble(json['amount']),
        value: _asDouble(json['value']),
      );

  final String name;
  final String code;
  final String type;
  final double amount;
  final double value;

  double get lineTotal => amount * value;
}

class SaleDetails {
  const SaleDetails({
    required this.id,
    required this.date,
    required this.total,
    required this.store,
    required this.products,
  });

  factory SaleDetails.fromJson(Map<String, dynamic> json) => SaleDetails(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        total: _asDouble(json['total']),
        store: Store.fromJson(
          (json['store'] as Map<String, dynamic>?) ?? const {},
        ),
        products: (json['products'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>()
            .map(SaleProductLine.fromJson)
            .toList(),
      );

  final String id;
  final DateTime date;
  final double total;
  final Store store;
  final List<SaleProductLine> products;
}
