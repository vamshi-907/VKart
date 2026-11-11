/// Business rules for VKart's delivery operation, kept in one place so
/// store-side changes (new threshold, new fee) are single-line edits.
///
/// Serviceable villages are NOT defined here — they live entirely in the
/// Firestore `delivery_locations` collection (Phase 3.1), so this file holds
/// only the pricing rules.
class DeliveryConfig {
  DeliveryConfig._(); // no instances — constants only

  /// Orders below this subtotal pay [deliveryCharge]; at or above it,
  /// delivery is free.
  static const double freeDeliveryThreshold = 499;

  /// Flat delivery fee for small orders.
  static const double deliveryCharge = 40;

  /// Delivery fee for a given items subtotal.
  static double deliveryChargeFor(double subtotal) {
    if (subtotal <= 0) return 0; // empty cart owes nothing
    // Compare in integer paise so ₹499.00 is reliably free and ₹498.99
    // reliably pays — no floating-point boundary surprises.
    final subtotalPaise = (subtotal * 100).round();
    final thresholdPaise = (freeDeliveryThreshold * 100).round();
    return subtotalPaise >= thresholdPaise ? 0 : deliveryCharge;
  }
}
