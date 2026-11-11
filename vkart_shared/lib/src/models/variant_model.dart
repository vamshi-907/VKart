class VariantModel {
  final String id;
  final String weight;
  final double mrp;
  final double price;
  final double offerPrice;
  final int stock;
  final String sku;
  final bool active;

  VariantModel({
    required this.id,
    required this.weight,
    required this.mrp,
    required this.price,
    required this.offerPrice,
    required this.stock,
    required this.sku,
    required this.active,
  });

  Map<String, dynamic> toMap() => {
        'weight': weight,
        'mrp': mrp,
        'price': price,
        'offerPrice': offerPrice,
        'stock': stock,
        'sku': sku,
        'active': active,
      };

  factory VariantModel.fromMap(String id, Map<String, dynamic> map) => VariantModel(
        id: id,
        weight: map['weight'] ?? '',
        mrp: (map['mrp'] as num?)?.toDouble() ?? 0,
        price: (map['price'] as num?)?.toDouble() ?? 0,
        offerPrice: (map['offerPrice'] as num?)?.toDouble() ?? 0,
        stock: (map['stock'] as num?)?.toInt() ?? 0,
        sku: map['sku'] ?? '',
        active: map['active'] ?? true,
      );
}
