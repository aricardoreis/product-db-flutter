class Store {
  const Store({required this.name, required this.address});

  factory Store.fromJson(Map<String, dynamic> json) => Store(
        name: json['name'] as String? ?? '',
        address: json['address'] as String? ?? '',
      );

  final String name;
  final String address;
}
