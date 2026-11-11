class AuditLogModel {
  final String id;
  final String adminId;
  final String adminName;
  final String role;
  final String module;
  final String action;
  final String recordId;
  final String description;
  final Map<String, dynamic>? oldData;
  final Map<String, dynamic>? newData;
  final bool status;
  final DateTime createdAt;

  AuditLogModel({
    required this.id,
    required this.adminId,
    required this.adminName,
    required this.role,
    required this.module,
    required this.action,
    required this.recordId,
    required this.description,
    this.oldData,
    this.newData,
    this.status = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'adminId': adminId,
    'adminName': adminName,
    'role': role,
    'module': module,
    'action': action,
    'recordId': recordId,
    'description': description,
    'oldData': oldData,
    'newData': newData,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
  };

  factory AuditLogModel.fromMap(String id, Map<String, dynamic> map) => AuditLogModel(
    id: id,
    adminId: map['adminId'] ?? '',
    adminName: map['adminName'] ?? '',
    role: map['role'] ?? '',
    module: map['module'] ?? '',
    action: map['action'] ?? '',
    recordId: map['recordId'] ?? '',
    description: map['description'] ?? '',
    oldData: map['oldData'] as Map<String, dynamic>?,
    newData: map['newData'] as Map<String, dynamic>?,
    status: map['status'] ?? true,
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
  );
}
