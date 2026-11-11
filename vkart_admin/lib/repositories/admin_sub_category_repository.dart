import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:vkart_shared/vkart_shared.dart';

class AdminSubCategoryRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _collection = 'sub_categories';

  Stream<List<SubCategoryModel>> getSubCategories() {
    return _db
        .collection(_collection)
        .where('active', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SubCategoryModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<String> _uploadIcon(File icon, String name) async {
    final ref = _storage.ref().child(
      'sub_category_icons/${DateTime.now().millisecondsSinceEpoch}_$name',
    );
    await ref.putFile(icon);
    return await ref.getDownloadURL();
  }

  Future<void> addSubCategory(
    SubCategoryModel subCategory,
    File? iconFile,
  ) async {
    String imageUrl = '';
    if (iconFile != null) {
      imageUrl = await _uploadIcon(iconFile, subCategory.name);
    }
    final data = subCategory.toMap()
      ..['imageUrl'] = imageUrl
      ..['createdAt'] = FieldValue.serverTimestamp();
    await _db.collection(_collection).add(data);
  }

  Future<void> updateSubCategory(
    SubCategoryModel subCategory,
    File? newIcon,
  ) async {
    Map<String, dynamic> data = subCategory.toMap();
    if (newIcon != null) {
      data['imageUrl'] = await _uploadIcon(newIcon, subCategory.name);
    }
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _db.collection(_collection).doc(subCategory.id).update(data);
  }

  Future<void> deleteSubCategory(String subCategoryId) async {
    await _db.collection(_collection).doc(subCategoryId).update({
      'active': false,
    });
  }
}
