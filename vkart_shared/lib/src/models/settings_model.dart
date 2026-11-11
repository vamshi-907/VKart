class BusinessSettingsModel {
  final String storeName;
  final String storeLogo;
  final String storeBanner;
  final String storeDescription;
  final String ownerName;
  final String businessEmail;
  final String supportEmail;
  final String supportPhone;
  final String whatsappNumber;
  final String gstNumber;
  final String businessAddress;
  final String googleMapsLink;

  // Business Hours
  final String openTime;
  final String closeTime;
  final List<String> workingDays;
  final bool holidayMode;
  final bool maintenanceMode;
  final bool storeOpen;

  // Delivery Settings
  final double freeDeliveryThreshold;
  final double minOrderAmount;
  final double deliveryCharge;
  final double maxDeliveryRadius;
  final String estimatedDeliveryTime;
  final bool expressDelivery;

  // Customer Settings
  final bool guestCheckout;
  final bool registrationRequired;
  final int maxCartItems;
  final int wishlistLimit;

  // App Settings / Socials
  final String appVersion;
  final bool forceUpdate;
  final String maintenanceMessage;
  final Map<String, String> socialLinks;

  BusinessSettingsModel({
    required this.storeName,
    required this.storeLogo,
    required this.storeBanner,
    required this.storeDescription,
    required this.ownerName,
    required this.businessEmail,
    required this.supportEmail,
    required this.supportPhone,
    required this.whatsappNumber,
    required this.gstNumber,
    required this.businessAddress,
    required this.googleMapsLink,
    required this.openTime,
    required this.closeTime,
    required this.workingDays,
    this.holidayMode = false,
    this.maintenanceMode = false,
    this.storeOpen = true,
    required this.freeDeliveryThreshold,
    required this.minOrderAmount,
    required this.deliveryCharge,
    required this.maxDeliveryRadius,
    required this.estimatedDeliveryTime,
    this.expressDelivery = false,
    this.guestCheckout = true,
    this.registrationRequired = false,
    required this.maxCartItems,
    required this.wishlistLimit,
    required this.appVersion,
    this.forceUpdate = false,
    required this.maintenanceMessage,
    required this.socialLinks,
  });

  Map<String, dynamic> toMap() => {
    'storeName': storeName,
    'storeLogo': storeLogo,
    'storeBanner': storeBanner,
    'storeDescription': storeDescription,
    'ownerName': ownerName,
    'businessEmail': businessEmail,
    'supportEmail': supportEmail,
    'supportPhone': supportPhone,
    'whatsappNumber': whatsappNumber,
    'gstNumber': gstNumber,
    'businessAddress': businessAddress,
    'googleMapsLink': googleMapsLink,
    'openTime': openTime,
    'closeTime': closeTime,
    'workingDays': workingDays,
    'holidayMode': holidayMode,
    'maintenanceMode': maintenanceMode,
    'storeOpen': storeOpen,
    'freeDeliveryThreshold': freeDeliveryThreshold,
    'minOrderAmount': minOrderAmount,
    'deliveryCharge': deliveryCharge,
    'maxDeliveryRadius': maxDeliveryRadius,
    'estimatedDeliveryTime': estimatedDeliveryTime,
    'expressDelivery': expressDelivery,
    'guestCheckout': guestCheckout,
    'registrationRequired': registrationRequired,
    'maxCartItems': maxCartItems,
    'wishlistLimit': wishlistLimit,
    'appVersion': appVersion,
    'forceUpdate': forceUpdate,
    'maintenanceMessage': maintenanceMessage,
    'socialLinks': socialLinks,
  };

  factory BusinessSettingsModel.fromMap(Map<String, dynamic> map) => BusinessSettingsModel(
    storeName: map['storeName'] ?? '',
    storeLogo: map['storeLogo'] ?? '',
    storeBanner: map['storeBanner'] ?? '',
    storeDescription: map['storeDescription'] ?? '',
    ownerName: map['ownerName'] ?? '',
    businessEmail: map['businessEmail'] ?? '',
    supportEmail: map['supportEmail'] ?? '',
    supportPhone: map['supportPhone'] ?? '',
    whatsappNumber: map['whatsappNumber'] ?? '',
    gstNumber: map['gstNumber'] ?? '',
    businessAddress: map['businessAddress'] ?? '',
    googleMapsLink: map['googleMapsLink'] ?? '',
    openTime: map['openTime'] ?? '09:00',
    closeTime: map['closeTime'] ?? '21:00',
    workingDays: List<String>.from(map['workingDays'] ?? []),
    holidayMode: map['holidayMode'] ?? false,
    maintenanceMode: map['maintenanceMode'] ?? false,
    storeOpen: map['storeOpen'] ?? true,
    freeDeliveryThreshold: (map['freeDeliveryThreshold'] as num?)?.toDouble() ?? 0,
    minOrderAmount: (map['minOrderAmount'] as num?)?.toDouble() ?? 0,
    deliveryCharge: (map['deliveryCharge'] as num?)?.toDouble() ?? 0,
    maxDeliveryRadius: (map['maxDeliveryRadius'] as num?)?.toDouble() ?? 0,
    estimatedDeliveryTime: map['estimatedDeliveryTime'] ?? '',
    expressDelivery: map['expressDelivery'] ?? false,
    guestCheckout: map['guestCheckout'] ?? true,
    registrationRequired: map['registrationRequired'] ?? false,
    maxCartItems: (map['maxCartItems'] as num?)?.toInt() ?? 100,
    wishlistLimit: (map['wishlistLimit'] as num?)?.toInt() ?? 50,
    appVersion: map['appVersion'] ?? '1.0.0',
    forceUpdate: map['forceUpdate'] ?? false,
    maintenanceMessage: map['maintenanceMessage'] ?? '',
    socialLinks: (map['socialLinks'] as Map?)?.cast<String, String>() ?? {},
  );
}
