class AdminModel {
  final String uid;
  final String email;
  final String name;
  final String? photoURL;
  final String role; // 'super_admin', 'admin', 'manager', 'staff'
  final bool active;
  final DateTime createdAt;
  final DateTime lastLogin;

  const AdminModel({
    required this.uid,
    required this.email,
    required this.name,
    this.photoURL,
    required this.role,
    required this.active,
    required this.createdAt,
    required this.lastLogin,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'name': name,
        if (photoURL != null) 'photoURL': photoURL,
        'role': role,
        'active': active,
        'createdAt': createdAt.toIso8601String(),
        'lastLogin': lastLogin.toIso8601String(),
      };

  factory AdminModel.fromMap(String uid, Map<String, dynamic> map) => AdminModel(
        uid: uid,
        email: (map['email'] ?? '').toString(),
        name: (map['name'] ?? '').toString(),
        photoURL: map['photoURL']?.toString(),
        role: (map['role'] ?? 'staff').toString(),
        active: (map['active'] as bool?) ?? false,
        createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
        lastLogin: DateTime.tryParse(map['lastLogin'] ?? '') ?? DateTime.now(),
      );
}
