import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vkart_shared/vkart_shared.dart';

class AdminAuditRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'audit_logs';

  Stream<List<AuditLogModel>> getAuditLogs() {
    return _db
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AuditLogModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> addLog(AuditLogModel log) async {
    await _db.collection(_collection).add(log.toMap());
  }
}
