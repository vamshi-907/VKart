import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vkart_shared/vkart_shared.dart';

class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<OrderModel>> getAssignedOrders(String partnerId) {
    // Note: assignedPartnerId is now persisted in OrderModel.toMap().
    // When full partner assignment is implemented, restore the filter:
    // .where('assignedPartnerId', isEqualTo: partnerId)
    // For now, show all orders so partners can see real data.
    return _firestore
        .collection('orders')
        .orderBy('createdAtMs', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.data()))
            .toList());
  }

  Stream<List<OrderModel>> getHistoryOrders(String partnerId, List<OrderStatus> statuses) {
    // Future: filter by assignedPartnerId when assignment is active.
    return _firestore
        .collection('orders')
        .where('status', whereIn: statuses.map((s) => s.value).toList())
        .orderBy('createdAtMs', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.data()))
            .toList());
  }

  /// Resolves the customer phone number for an assigned order.
  ///
  /// The order document itself carries the phone captured at checkout, so the
  /// phone is sourced from [orderPhone] first. The legacy delivery_details
  /// lookup is kept only as a fallback for callers that don't pass the order
  /// phone (delivery_details is owner-only under production Firestore rules,
  /// so partner apps should always rely on the order document).
  Future<String?> fetchCustomerPhone(String userId, {String? orderPhone}) async {
    if (orderPhone != null && orderPhone.trim().isNotEmpty) {
      return orderPhone.trim();
    }
    try {
      final doc = await _firestore.collection('delivery_details').doc(userId).get();
      if (!doc.exists) return null;
      final data = doc.data();
      return (data?['phoneNumber'] ?? data?['phone'] ?? '').toString();
    } catch (_) {
      return null;
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status,
      {String? notes, String? photoUrl, String? reason}) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status.value,
      'updatedAt': FieldValue.serverTimestamp(),
      ...notes != null ? {'deliveryNotes': notes} : {},
      ...photoUrl != null ? {'deliveryPhotoUrl': photoUrl} : {},
      ...reason != null ? {'unableToDeliverReason': reason} : {},
    });
  }
}