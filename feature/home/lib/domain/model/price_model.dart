class PriceModel {
  final String type;
  final double price;

  PriceModel({
    required this.type,
    required this.price,
  });

  factory PriceModel.fromJson(Map<String, dynamic> json) {
    return PriceModel(
      type: json['type'],
      price: (json['price'] as num).toDouble(),
    );
  }
}
