class CategoryModel {
  final String id;
  final String name;
  final String nameTelugu;
  final String icon;
  final int displayOrder;
  final bool active;

  CategoryModel({
    required this.id,
    required this.name,
    required this.nameTelugu,
    required this.icon,
    required this.displayOrder,
    required this.active,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'nameTelugu': nameTelugu,
        'icon': icon,
        'displayOrder': displayOrder,
        'active': active,
      };

  factory CategoryModel.fromMap(String id, Map<String, dynamic> map) => CategoryModel(
        id: id,
        name: map['name'] ?? '',
        nameTelugu: map['nameTelugu'] ?? '',
        icon: map['icon'] ?? '',
        displayOrder: map['displayOrder'] ?? 0,
        active: map['active'] ?? true,
      );
}
