/// A delivery address with optional GPS coordinates.
///
/// Coordinates are nullable: an address typed fully by hand has none, and the
/// app then falls back to pincode matching for serviceability.
class AddressModel {
  final String name;
  final String phone;
  final String village;
  final String houseNo;
  final String landmark;
  final String pincode;
  final double? latitude;
  final double? longitude;

  const AddressModel({
    required this.name,
    required this.phone,
    required this.village,
    required this.houseNo,
    required this.landmark,
    this.pincode = '',
    this.latitude,
    this.longitude,
  });

  bool get hasCoordinates => latitude != null && longitude != null;

  bool get isComplete =>
      name.trim().isNotEmpty &&
      phone.trim().isNotEmpty &&
      village.trim().isNotEmpty;

  /// Multi-line display form used on checkout and order screens.
  String get displayText {
    final lines = <String>[
      "$name • $phone",
      [
        if (houseNo.trim().isNotEmpty) houseNo.trim(),
        if (village.trim().isNotEmpty) village.trim(),
      ].join(', '),
      if (landmark.trim().isNotEmpty) landmark.trim(),
      if (pincode.trim().isNotEmpty) "PIN $pincode",
    ];
    return lines.where((l) => l.isNotEmpty).join('\n');
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'phone': phone,
        'village': village,
        'houseNo': houseNo,
        'landmark': landmark,
        'pincode': pincode,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };

  factory AddressModel.fromMap(Map<String, dynamic> map) => AddressModel(
        name: (map['name'] ?? '').toString(),
        phone: (map['phone'] ?? '').toString(),
        village: (map['village'] ?? '').toString(),
        houseNo: (map['houseNo'] ?? '').toString(),
        landmark: (map['landmark'] ?? '').toString(),
        pincode: (map['pincode'] ?? '').toString(),
        latitude: (map['latitude'] as num?)?.toDouble(),
        longitude: (map['longitude'] as num?)?.toDouble(),
      );
}
