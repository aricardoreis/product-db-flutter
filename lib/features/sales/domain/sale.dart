class Sale {
  const Sale({
    required this.id,
    required this.date,
    required this.total,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    final total = switch (json['total']) {
      final num n => n.toDouble(),
      final String s => double.tryParse(s) ?? 0.0,
      _ => 0.0,
    };
    return Sale(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      total: total,
    );
  }

  final String id;
  final DateTime date;
  final double total;
}
