import 'package:vkart_shared/vkart_shared.dart';
import '../repositories/admin_audit_repository.dart';

class AuditLoggerService {
  final AdminAuditRepository _repository = AdminAuditRepository();

  Future<void> logAction({
    required AdminModel admin,
    required String module,
    required String action,
    required String recordId,
    required String description,
    Map<String, dynamic>? oldData,
    Map<String, dynamic>? newData,
  }) async {
    final log = AuditLogModel(
      id: '',
      adminId: admin.uid,
      adminName: admin.name,
      role: admin.role,
      module: module,
      action: action,
      recordId: recordId,
      description: description,
      oldData: oldData,
      newData: newData,
      createdAt: DateTime.now(),
    );
    await _repository.addLog(log);
  }
}
