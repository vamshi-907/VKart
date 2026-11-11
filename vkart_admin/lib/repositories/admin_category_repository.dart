import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:vkart_shared/vkart_shared.dart';

class AdminCategoryRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _collection = 'categories';

  Stream<List<CategoryModel>> getCategories() {
    return _db
        .collection(_collection)
        .where('active', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CategoryModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<String> _uploadImage(File image, String name) async {
    final ref = _storage.ref().child(
      'category_icons/${DateTime.now().millisecondsSinceEpoch}_$name',
    );
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<void> addCategory(CategoryModel category, File? imageFile) async {
    String imageUrl = '';
    if (imageFile != null) {
      imageUrl = await _uploadImage(imageFile, category.name);
    }

    final data = category.toMap()
      ..['imageUrl'] = imageUrl
      ..['createdAt'] = FieldValue.serverTimestamp();
    await _db.collection(_collection).add(data);
  }

  Future<void> updateCategory(CategoryModel category, File? newImage) async {
    Map<String, dynamic> data = category.toMap();
    if (newImage != null) {
      data['imageUrl'] = await _uploadImage(newImage, category.name);
    }
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _db.collection(_collection).doc(category.id).update(data);
  }

  Future<void> deleteCategory(String categoryId) async {
    await _db.collection(_collection).doc(categoryId).update({'active': false});
  }
}
