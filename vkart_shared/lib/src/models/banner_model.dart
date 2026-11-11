class BannerModel {
  final String id;
  final String title;
  final String titleTelugu;
  final String imageUrl;
  final String bannerType; // 'home', 'offer', etc.
  final String target; // 'category', 'product', 'offer'
  final String targetId;
  final int displayOrder;
  final bool active;
  final bool showInCustomerApp;
  final DateTime startDate;
  final DateTime endDate;

  BannerModel({
    required this.id,
    required this.title,
    required this.titleTelugu,
    required this.imageUrl,
    required this.bannerType,
    required this.target,
    required this.targetId,
    required this.displayOrder,
    this.active = true,
    this.showInCustomerApp = true,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toMap() => {
    'titleEnglish': title,
    'titleTelugu': titleTelugu,
    'imageUrl': imageUrl,
    'bannerType': bannerType,
    'target': target,
    'targetId': targetId,
    'displayOrder': displayOrder,
    'active': active,
    'showInCustomerApp': showInCustomerApp,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'createdAt': DateTime.now().toIso8601String(),
  };

  factory BannerModel.fromMap(String id, Map<String, dynamic> map) => BannerModel(
    id: id,
    title: map['titleEnglish'] ?? '',
    titleTelugu: map['titleTelugu'] ?? '',
    imageUrl: map['imageUrl'] ?? '',
    bannerType: map['bannerType'] ?? 'home',
    target: map['target'] ?? 'home',
    targetId: map['targetId'] ?? '',
    displayOrder: map['displayOrder'] ?? 0,
    active: map['active'] ?? true,
    showInCustomerApp: map['showInCustomerApp'] ?? true,
    startDate: DateTime.tryParse(map['startDate'] ?? '') ?? DateTime.now(),
    endDate: DateTime.tryParse(map['endDate'] ?? '') ?? DateTime.now().add(const Duration(days: 30)),
  );
}
