class BrandModel {
  final String id;
  final String name;
  final String nameTelugu;
  final String logo;
  final bool active;

  BrandModel({
    required this.id,
    required this.name,
    required this.nameTelugu,
    required this.logo,
    required this.active,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'nameTelugu': nameTelugu,
        'logo': logo,
        'active': active,
      };

  factory BrandModel.fromMap(String id, Map<String, dynamic> map) => BrandModel(
        id: id,
        name: map['name'] ?? '',
        nameTelugu: map['nameTelugu'] ?? '',
        logo: map['logo'] ?? '',
        active: map['active'] ?? true,
      );
}
