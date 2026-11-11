class SubCategoryModel {
  final String id;
  final String categoryId;
  final String name;
  final String nameTelugu;

  SubCategoryModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.nameTelugu,
  });

  Map<String, dynamic> toMap() => {
        'categoryId': categoryId,
        'name': name,
        'nameTelugu': nameTelugu,
      };

  factory SubCategoryModel.fromMap(String id, Map<String, dynamic> map) => SubCategoryModel(
        id: id,
        categoryId: map['categoryId'] ?? '',
        name: map['name'] ?? '',
        nameTelugu: map['nameTelugu'] ?? '',
      );
}
