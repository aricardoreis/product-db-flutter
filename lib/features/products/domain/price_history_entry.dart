class PriceHistoryEntry {
  const PriceHistoryEntry({
    required this.value,
    required this.date,
  });

  factory PriceHistoryEntry.fromJson(Map<String, dynamic> json) {
    final value = switch (json['value']) {
      final num n => n.toDouble(),
      final String s => double.tryParse(s) ?? 0.0,
      _ => 0.0,
    };
    return PriceHistoryEntry(
      value: value,
      date: DateTime.parse(json['date'] as String),
    );
  }

  final double value;
  final DateTime date;
}
