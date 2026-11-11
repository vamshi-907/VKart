
class DeliveryPartnerModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String photoUrl;
  final String employeeId;
  final String vehicleType;
  final List<String> assignedVillages;
  final bool active;
  final bool available;

  DeliveryPartnerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.photoUrl,
    required this.employeeId,
    required this.vehicleType,
    required this.assignedVillages,
    this.active = true,
    this.available = true,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'phone': phone,
    'email': email,
    'photoUrl': photoUrl,
    'employeeId': employeeId,
    'vehicleType': vehicleType,
    'assignedVillages': assignedVillages,
    'active': active,
    'available': available,
  };

  factory DeliveryPartnerModel.fromMap(String id, Map<String, dynamic> map) => DeliveryPartnerModel(
    id: id,
    name: map['name'] ?? '',
    phone: map['phone'] ?? '',
    email: map['email'] ?? '',
    photoUrl: map['photoUrl'] ?? '',
    employeeId: map['employeeId'] ?? '',
    vehicleType: map['vehicleType'] ?? '',
    assignedVillages: List<String>.from(map['assignedVillages'] ?? []),
    active: map['active'] ?? true,
    available: map['available'] ?? true,
  );
}
