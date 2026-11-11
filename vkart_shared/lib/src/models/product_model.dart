import 'variant_model.dart';

enum StockStatus { inStock, lowStock, outOfStock }

class ProductModel {
  final String id;
  final String name;
  final String nameTelugu;
  final String brandId;
  final String brandName;
  final String categoryId;
  final String categoryName;
  final String subCategoryId;
  final String subCategoryName;
  final String description;
  final String descriptionTelugu;
  final String deliveryTime;
  final double gst;
  final List<String> images;
  final List<VariantModel> variants;
  final bool active;
  final int displayOrder;
  final DateTime createdAt;

  double get price => variants.isNotEmpty ? variants.first.price : 0.0;
  int get stock => variants.fold(0, (sum, item) => sum + item.stock);
  String get image => images.isNotEmpty ? images.first : '';
  String get weight => variants.isNotEmpty ? variants.first.weight : '';
  String get brand => brandName;
  String get category => categoryName;
  double get mrp => variants.isNotEmpty ? variants.first.mrp : 0.0;
  double get savings => mrp > price ? mrp - price : 0.0;
  double get discountPercentage => mrp > 0 ? (savings / mrp) * 100 : 0.0;
  double get discount => savings;
  double get rating => 0.0;
  int get ratingCount => 0;
  int get popularity => 0;

  // App specific flags - adding defaults since they were removed
  bool get bestSeller => false;
  bool get featured => false;
  bool get limitedOffer => false;
  bool get trending => false;
  bool get newArrival => false;
  bool get todaysDeal => false;

  bool get inStock => stock > 0;
  StockStatus get stockStatus => inStock ? StockStatus.inStock : StockStatus.outOfStock;
  String get nameEnglish => name;
  bool get hasTelugu => nameTelugu.isNotEmpty;

  bool get hasDiscount => discountPercentage > 0;
  int get createdAtMs => createdAt.millisecondsSinceEpoch;
  /// Creates a new [ProductModel] with the same fields but with a new
  /// [VariantModel] representing the selected weight/pack size and price.
  ProductModel withVariant(String weight, double price) {
    return ProductModel(
      id: id,
      name: name,
      nameTelugu: nameTelugu,
      brandId: brandId,
      brandName: brandName,
      categoryId: categoryId,
      categoryName: categoryName,
      subCategoryId: subCategoryId,
      subCategoryName: subCategoryName,
      description: description,
      descriptionTelugu: descriptionTelugu,
      deliveryTime: deliveryTime,
      gst: gst,
      images: images,
      variants: [
        VariantModel(
          id: 'default',
          weight: weight,
          mrp: mrp,
          price: price,
          offerPrice: price,
          stock: stock,
          sku: '',
          active: active,
        ),
      ],
      active: active,
      displayOrder: displayOrder,
      createdAt: createdAt,
    );
  }


  ProductModel({
    required this.id,
    required this.name,
    required this.nameTelugu,
    required this.brandId,
    required this.brandName,
    required this.categoryId,
    required this.categoryName,
    required this.subCategoryId,
    required this.subCategoryName,
    required this.description,
    required this.descriptionTelugu,
    required this.deliveryTime,
    required this.gst,
    required this.images,
    this.variants = const [],
    this.active = true,
    this.displayOrder = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
  // ---------- Images ----------
  List<String> imageList = [];

  if (map['images'] != null) {
    imageList = List<String>.from(map['images']);
  } else if (map['image'] != null &&
      map['image'].toString().isNotEmpty) {
    imageList = [map['image']];
  }

  // ---------- Variants ----------
  List<VariantModel> variantList = [];

  if (map['variants'] != null) {
    variantList = (map['variants'] as List)
        .map((e) => VariantModel.fromMap('', Map<String, dynamic>.from(e)))
        .toList();
  } else {
    // Legacy Firestore schema support
    variantList = [
      VariantModel(
        id: '',
        weight: map['weight']?.toString() ?? '',
        mrp: (map['mrp'] as num?)?.toDouble() ?? 0,
        price: (map['price'] as num?)?.toDouble() ?? 0,
        offerPrice: (map['price'] as num?)?.toDouble() ?? 0,
        stock: (map['stock'] as num?)?.toInt() ??
            (map['stockStatus'] == 'InStock' ? 999 : 0),
        sku: map['sku']?.toString() ?? '',
        active: map['active'] ?? true,
      ),
    ];
  }

  return ProductModel(
    id: id,

    // Name
    name: map['nameEnglish'] ??
        map['name'] ??
        '',

    nameTelugu: map['nameTelugu'] ?? '',

    // Brand
    brandId: map['brandId'] ?? '',
    brandName: map['brandName'] ??
        map['brand'] ??
        '',

    // Category
    categoryId: map['categoryId'] ?? '',
    categoryName: map['categoryName'] ??
        map['category'] ??
        '',

    // Sub Category
    subCategoryId: map['subCategoryId'] ?? '',
    subCategoryName: map['subCategoryName'] ?? '',

    // Description
    description: map['descriptionEnglish'] ??
        map['description'] ??
        '',

    descriptionTelugu: map['descriptionTelugu'] ?? '',

    // Delivery
    deliveryTime: map['deliveryTime'] ?? '',

    gst: (map['gst'] as num?)?.toDouble() ?? 0,

    images: imageList,

    variants: variantList,

    active: map['active'] ?? true,

    displayOrder: map['displayOrder'] ?? 0,

    createdAt: map['createdAt'] is String
        ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
        : DateTime.now(),
  );
}

  Map<String, dynamic> toMap() => {
        'id': id,
        'nameEnglish': name,
        'nameTelugu': nameTelugu,
        'brandId': brandId,
        'brandName': brandName,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'subCategoryId': subCategoryId,
        'subCategoryName': subCategoryName,
        'descriptionEnglish': description,
        'descriptionTelugu': descriptionTelugu,
        'deliveryTime': deliveryTime,
        'gst': gst,
        'images': images,
        'variants': variants.map((v) => v.toMap()).toList(),
        'active': active,
        'displayOrder': displayOrder,
        'createdAt': createdAt.toIso8601String(),
      };
}
