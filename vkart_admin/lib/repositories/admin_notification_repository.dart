import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:vkart_shared/vkart_shared.dart';

class AdminNotificationRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _collection = 'notifications';

  Stream<List<NotificationModel>> getNotifications() {
    return _db
        .collection(_collection)
        .orderBy('scheduledAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<String> _uploadImage(File image, String title) async {
    final ref = _storage.ref().child(
      'notification_assets/${DateTime.now().millisecondsSinceEpoch}_$title',
    );
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<void> addNotification(
    NotificationModel notification,
    File? imageFile,
  ) async {
    String imageUrl = '';
    if (imageFile != null) {
      imageUrl = await _uploadImage(imageFile, notification.title);
    }

    final data = notification.toMap()
      ..['imageUrl'] = imageUrl
      ..['createdAt'] = FieldValue.serverTimestamp();
    await _db.collection(_collection).add(data);
  }

  Future<void> updateNotification(
    NotificationModel notification,
    File? newImage,
  ) async {
    Map<String, dynamic> data = notification.toMap();
    if (newImage != null) {
      data['imageUrl'] = await _uploadImage(newImage, notification.title);
    }
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _db.collection(_collection).doc(notification.id).update(data);
  }

  Future<void> deleteNotification(String id) async {
    await _db.collection(_collection).doc(id).update({'active': false});
  }
}
