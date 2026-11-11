import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vkart_shared/vkart_shared.dart';

/// The single, authoritative repository for products.
///
/// All product data — Dashboard count, Product List, Search, Edit and Delete —
/// flows through this one repository. The dashboard count and the product list
/// both come from the same `where('active' == true)` realtime stream, so the
/// numbers always match.
///
/// Product images are URL-based: the repository stores the image URLs it is
/// given directly into the existing Firestore fields and never talks to
/// Firebase Storage.
class AdminProductRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'products';

  /// Real-time stream of active products. This is the EXACT source used by
  /// Product List — the dashboard derives its count from this same stream.
  Stream<List<ProductModel>> streamProducts() {
    return _db
        .collection(_collection)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  /// One-time fetch of active products (used for force refresh flows).
  Future<List<ProductModel>> fetchProducts() async {
    final snapshot = await _db
        .collection(_collection)
        .get();
    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  /// Adds a new product. Product images are URL-based: [product.images]
  /// contains direct image URLs that are stored as-is in the existing
  /// `images` list field, while the legacy `image` string field receives the
  /// first URL (the same representation the Excel import writes). No image
  /// upload is performed.
  Future<void> addProduct(ProductModel product) async {
    final imageUrls = product.images;

    final data = product.toMap()
     ..['name'] = product.name
..['brand'] = product.brand
..['category'] = product.category
..['image'] = imageUrls.isNotEmpty ? imageUrls.first : ''
..['images'] = imageUrls
..['price'] = product.price
..['mrp'] = product.mrp
..['stock'] = product.stock
..['stockStatus'] = product.stock > 0 ? 'InStock' : 'OutOfStock'
..['weight'] = product.weight;

    await _db.collection(_collection).add(data);
  }

  /// Updates an existing product directly in Firestore.
  ///
  /// The final image URL list is taken from [product.images] and stored
  /// as-is (URLs only — no upload, no Storage cleanup). Editing only product
  /// information therefore leaves the stored image URLs untouched.
  Future<void> updateProduct(ProductModel product) async {
    final imageUrls = product.images;

    final data = product.toMap()

      // ---------- Legacy fields ----------
      ..['name'] = product.name
      ..['brand'] = product.brand
      ..['category'] = product.category
      ..['image'] = imageUrls.isNotEmpty ? imageUrls.first : ''
      ..['price'] = product.price
      ..['mrp'] = product.mrp
      ..['stock'] = product.stock
      ..['stockStatus'] = product.stock > 0 ? 'InStock' : 'OutOfStock'
      ..['weight'] = product.weight

      // ---------- New fields ----------
      ..['images'] = imageUrls

      ..['updatedAt'] = FieldValue.serverTimestamp();

    await _db
        .collection(_collection)
        .doc(product.id)
        .set(
          data,
          SetOptions(merge: true),
        );
  }

  /// Permanently removes the product document from Firestore. Images are
  /// URL-based, so no Storage cleanup is involved.
  Future<void> deleteProduct(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
}

