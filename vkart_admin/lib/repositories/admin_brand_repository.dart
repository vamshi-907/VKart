import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:vkart_shared/vkart_shared.dart';

class AdminBrandRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _collection = 'brands';

  Stream<List<BrandModel>> getBrands() {
    return _db
        .collection(_collection)
        .where('active', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BrandModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<String> _uploadLogo(File logo, String name) async {
    final ref = _storage.ref().child(
      'brand_logos/${DateTime.now().millisecondsSinceEpoch}_$name',
    );
    await ref.putFile(logo);
    return await ref.getDownloadURL();
  }

  Future<void> addBrand(BrandModel brand, File? logoFile) async {
    String logoUrl = '';
    if (logoFile != null) {
      logoUrl = await _uploadLogo(logoFile, brand.name);
    }
    final data = brand.toMap()
      ..['logoUrl'] = logoUrl
      ..['createdAt'] = FieldValue.serverTimestamp();
    await _db.collection(_collection).add(data);
  }

  Future<void> updateBrand(BrandModel brand, File? newLogo) async {
    Map<String, dynamic> data = brand.toMap();
    if (newLogo != null) {
      data['logoUrl'] = await _uploadLogo(newLogo, brand.name);
    }
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _db.collection(_collection).doc(brand.id).update(data);
  }

  Future<void> deleteBrand(String brandId) async {
    await _db.collection(_collection).doc(brandId).update({'active': false});
  }
}
