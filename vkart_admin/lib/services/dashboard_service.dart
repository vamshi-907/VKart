import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<int> getCollectionCount(String collectionName) async {
    final snapshot = await _db.collection(collectionName).count().get();
    return snapshot.count ?? 0;
  }
}
