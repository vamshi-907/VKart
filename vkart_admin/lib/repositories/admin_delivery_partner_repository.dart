import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vkart_shared/vkart_shared.dart';

class AdminDeliveryPartnerRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'delivery_partners';

  Stream<List<DeliveryPartnerModel>> getDeliveryPartners() {
    return _db
        .collection(_collection)
        .where('active', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => DeliveryPartnerModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }
}
