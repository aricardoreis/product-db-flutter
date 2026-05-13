class Product {
  const Product({
    required this.id,
    required this.name,
    required this.code,
    required this.amount,
    required this.type,
    this.latestPrice,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final amount = switch (json['amount']) {
      final num n => n.toDouble(),
      final String s => double.tryParse(s) ?? 0.0,
      _ => 0.0,
    };
    final history =
        (json['priceHistory'] as List<dynamic>? ?? const <dynamic>[])
            .cast<Map<String, dynamic>>();
    final latestPrice = history.isEmpty
        ? null
        : switch (history.first['value']) {
            final num n => n.toDouble(),
            final String s => double.tryParse(s),
            _ => null,
          };
    return Product(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      code: json['code'] as String? ?? '',
      amount: amount,
      type: json['type'] as String? ?? '',
      latestPrice: latestPrice,
    );
  }

  final int id;
  final String name;
  final String code;
  final double amount;
  final String type;
  final double? latestPrice;
}
