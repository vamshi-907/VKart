import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vkart_shared/vkart_shared.dart';

class AdminCustomerRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'users';

  Stream<List<UserModel>> getCustomers() {
    return _db
        .collection(_collection)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<void> updateCustomerStatus(String uid, bool active) async {
    await _db.collection(_collection).doc(uid).update({'active': active});
  }

  Future<Map<String, dynamic>> getCustomerOrderMetrics(String uid) async {
    final orders = await _db
        .collection('orders')
        .where('customerId', isEqualTo: uid)
        .get();
    double totalSpent = 0;
    for (var doc in orders.docs) {
      totalSpent += (doc.data()['grandTotal'] as num?)?.toDouble() ?? 0;
    }
    return {'orderCount': orders.size, 'totalSpent': totalSpent};
  }
}
