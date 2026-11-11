import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vkart_shared/vkart_shared.dart';

class AdminOrderRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'orders';

  Stream<List<OrderModel>> getAllOrders() {
    return _db
        .collection(_collection)
        .orderBy('createdAtMs', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _db.collection(_collection).doc(orderId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
