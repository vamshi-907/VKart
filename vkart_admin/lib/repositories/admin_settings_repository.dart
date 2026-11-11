import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:vkart_shared/vkart_shared.dart';

class AdminSettingsRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _collection = 'settings';
  final String _docId = 'business';

  Stream<BusinessSettingsModel> getSettings() {
    return _db.collection(_collection).doc(_docId).snapshots().map((doc) {
      if (!doc.exists) {
        // Return a default model if document doesn't exist
        return BusinessSettingsModel(
          storeName: '',
          storeLogo: '',
          storeBanner: '',
          storeDescription: '',
          ownerName: '',
          businessEmail: '',
          supportEmail: '',
          supportPhone: '',
          whatsappNumber: '',
          gstNumber: '',
          businessAddress: '',
          googleMapsLink: '',
          openTime: '09:00',
          closeTime: '21:00',
          workingDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
          holidayMode: false,
          maintenanceMode: false,
          storeOpen: true,
          freeDeliveryThreshold: 0,
          minOrderAmount: 0,
          deliveryCharge: 0,
          maxDeliveryRadius: 0,
          estimatedDeliveryTime: '',
          expressDelivery: false,
          guestCheckout: true,
          registrationRequired: false,
          maxCartItems: 100,
          wishlistLimit: 50,
          appVersion: '1.0.0',
          forceUpdate: false,
          maintenanceMessage: '',
          socialLinks: {},
        );
      }
      return BusinessSettingsModel.fromMap(doc.data()!);
    });
  }

  Future<String> _uploadImage(File image, String name) async {
    final ref = _storage.ref().child(
      'business_assets/${DateTime.now().millisecondsSinceEpoch}_$name',
    );
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<void> updateSettings(
    BusinessSettingsModel settings, {
    File? logoFile,
    File? bannerFile,
  }) async {
    String logoUrl = settings.storeLogo;
    String bannerUrl = settings.storeBanner;

    if (logoFile != null) {
      logoUrl = await _uploadImage(logoFile, 'logo');
    }
    if (bannerFile != null) {
      bannerUrl = await _uploadImage(bannerFile, 'banner');
    }

    final data = settings.toMap()
      ..['storeLogo'] = logoUrl
      ..['storeBanner'] = bannerUrl
      ..['updatedAt'] = FieldValue.serverTimestamp();

    await _db.collection(_collection).doc(_docId).set(data);
  }
}
