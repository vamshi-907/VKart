# STAGE 4.6D — IMPLEMENTATION DATA AUDIT (Privacy Policy Preparation)

Date: 2026-09-16 · Feature freeze ACTIVE · No source, rules, Firebase, or build changes made in this stage.

Firebase project: `vkart-1` (project number 773093189958)
- Customer: `com.vkart.customer` (1.0.0+1)
- Admin: `com.vkart.admin` (1.0.0+1)
- Delivery Partner: `com.vkart.deliverypartner` (1.0.1+2)

## 1. AUTHENTICATION (verified from source)

| App | Method | Evidence |
|---|---|---|
| Customer | Email + 6-digit OTP sent via Gmail SMTP **directly from the app** (`mailer`). Session token + userId + name + email in device SharedPreferences. OTP in memory only: 5-min expiry, 5 attempts, 30 s resend. No Firebase Auth, no phone OTP. | `customer/lib/services/auth_service.dart` ("session-based via SharedPreferences"), `customer_otp_service.dart`, `config/customer_auth_config.dart`, `config/smtp_config.dart`, `screens/auth/login_screen.dart` (Name + Email only — no phone at login) |
| Admin | Email + 6-digit OTP via Gmail SMTP; **hard-coded allowlist** (`venkatasaivamshi23@gmail.com`, `vsv8639243604@gmail.com`). Session in SharedPreferences; restored admin treated as `role: 'super_admin'`. | `admin/lib/services/admin_auth_service.dart`, `config/admin_auth_config.dart`, `auth/admin_auth_provider.dart` |
| Partner | Email + 6-digit OTP via Gmail SMTP; **single allowlisted email** `maleyrameshbabu113@gmail.com` (`Ramesh Babu`); Firestore `partners/{email}` doc must have `active==true` && `role=='delivery_partner'`; seeded on first authorized login. Session in SharedPreferences. | `partner/lib/services/partner_auth_service.dart`, `smtp_otp_service.dart`, `config/delivery_partner_auth_config.dart` |

**Phone usage:** No app authenticates by phone. Phone is collected only as a **delivery contact number** at Customer checkout.

**SMTP note (pre-existing, documented in code):** Gmail app-password credentials are embedded in all three apps (`SmtpConfig`) with in-code warnings. Flagged under Owner Items; not changed here.

## 2. FIRESTORE DATA — ACTUAL FIELDS WRITTEN

### 2.1 Customer app writes (collections in `customer/lib/services/firestore_service.dart`)
- `users/{uid}`: `uid, displayName, email, photoURL?, language('en'), createdAt, lastLogin, defaultAddressId?` (+ `active` toggled by admin). Evidence: `vkart_shared/lib/src/models/user/user_model.dart` (`toMap`), `auth_service.dart` `updateLastLogin()`.
- `orders/{orderId}`: `orderId` (`VK-YYYYMMDD-xxxxxx`), `customerId`, `userId`, `customerName`, `customerEmail`, `deliveryLocation`, `deliveryLocationEnglish/Telugu`, `phoneNumber` (+ duplicate `customerPhone`), `address{name, phone, village, houseNo:'', landmark:'', pincode:''}`, `items[{productId,name,weight,price,quantity,image}]`, `subtotal, deliveryCharge, grandTotal`, `paymentMethod` ('Cash on Delivery'), `status` ('orderPlaced'), `villageId/villageName/villageNameTelugu`, `assignedPartnerId`, `createdAtMs`. Evidence: `vkart_shared/.../order_model.dart` `toMap()` (lines 174–206), `order_provider.dart` `placeOrder`, `checkout_screen.dart` (name/email/location/10-digit phone validation; COD only).
- `delivery_details/{userId}`: `phoneNumber`, `createdAt`, `updatedAt` (serverTimestamp), persisted at checkout. Evidence: `firestore_service.dart` `saveDeliveryDetails`, `checkout_screen.dart` `_loadDeliveryDetails`.
- `cart/{userId}`: `items[{productId, name, price, quantity, image, weight, category, stock}]`, `updatedAt` (authenticated users; guests local-only). Evidence: `cart_provider.dart` `CartItem.toMap`, `_syncToFirestore`.
- `wishlist/{userId}`: `items[{productId, addedAt?}]`, `updatedAt`. Evidence: `session_upgrade_service.dart`, `firestore_service.dart` `saveWishlist`.
- `addresses/{docId}`: `userId, name, email, phoneNumber, deliveryLocation, address, isDefault, createdAt, updatedAt`. Evidence: `address_provider.dart` `SavedAddress`.
- Local-only (SharedPreferences): session token/userId/name/email, selected delivery location id/name, selected address doc id, legacy per-install `customerId` (never synced). Evidence: `auth_service.dart`, `delivery_location_provider.dart`, `address_provider.dart`, `order_provider.dart` `_getCustomerId`.

### 2.2 Delivery location is NOT device location
`DeliveryLocation` = `{id, nameEnglish, nameTelugu, active, deliveryAvailable, displayOrder}` — a **village/town pick-list read from the Firestore `delivery_locations` collection**; selection persisted locally. No GPS read anywhere (see §3). Evidence: `models/delivery_location_model.dart`, `providers/delivery_location_provider.dart`, `fetchDeliveryLocations`.

### 2.3 Admin app reads/writes
- Streams **all** `users` docs; UI shows `displayName`, `email`, `photoURL` (`admin_customer_repository.dart`, `customer_list_screen.dart`).
- `updateCustomerStatus(uid, active)` — writes **only** `{active: bool}` (mirrored by rules `validAdminUserUpdate()`).
- `getCustomerOrderMetrics(uid)` — orders where `customerId == uid` → `orderCount` + `totalSpent`.
- Reads all orders incl. customer block (`order.address.displayText` = name • phone, house, village, landmark, PIN) and `paymentMethod` (`admin/screens/orders/order_details_screen.dart`).
- Writes `audit_logs`: `adminId, adminName, role, module, action, recordId, description, oldData, newData, status, createdAt` (`audit_logger_service.dart`, `audit_log_model.dart`).
- Uploads catalogue images to **Firebase Storage**, stores download URLs in Firestore: brand logos, category icons, sub-category icons, notification assets, business assets (`FirebaseStorage.instance` in `admin_brand/category/sub_category/notification/settings_repository.dart`; product images switched to URL fields in Stage 4.4.5 — `image_picker` removed). **Users never upload images.**
- Rosters: `delivery_partners` docs carry `name, phone, email, photoUrl, employeeId, vehicleType, assignedVillages, active, available` (`delivery_partner_model.dart`).

### 2.4 Partner app reads/writes
- Streams orders — **assignment filter commented out; currently shows ALL orders** ("For now, show all orders so partners can see real data") (`partner/lib/src/repositories/order_repository.dart` lines 7–19).
- Order details UI shows customer name, **phone**, full address, items, prices, bill (`src/ui/screens/order_details_screen.dart`).
- Opens **Google Maps** with the delivery address/coords via `url_launcher` (`src/services/map_service.dart`).
- Writes only `{status, updatedAt, deliveryNotes?, deliveryPhotoUrl?, unableToDeliverReason?}` with a local one-step-forward guard (`src/providers/order_provider.dart`, `updateOrderStatus`).
- `fetchCustomerPhone`: order document first; `delivery_details` fallback (documented owner-only under production rules).

## 3. LOCATION (GPS) — DECLARED BUT NOT USED
- Customer `AndroidManifest.xml` declares `ACCESS_FINE_LOCATION` + `ACCESS_COARSE_LOCATION` ("GPS delivery-address detection (Phase 3)"); pubspec declares `geolocator ^14.0.3` + `geocoding ^5.0.0`; `GeneratedPluginRegistrant.java` registers both plugins.
- **Search of all Dart sources found ZERO usage**: no `package:geolocator` import, no `Geolocator.`, no `getCurrentPosition`, no `placemarkFromCoordinates`, no `package:geocoding`. The address form (`address_screen.dart`) is manual text entry; `_latitude/_longitude` are only carried from a previously saved model, never from a device fix.
- Partner: `geolocator`/`permission_handler` declared but **no Dart usage**; manifest has **no** location permission. Navigation hands the *order address* to the external Google Maps app.
- **Conclusion: no device location is requested, obtained, stored, or transmitted. No location data is collected.** (Declared permissions + dormant plugin remain in the customer APK — see Owner Items.)

## 4. FIREBASE SERVICES ACTUALLY USED
| Service | Customer | Admin | Partner |
|---|---|---|---|
| Firebase Core (project vkart-1) | Yes | Yes | Yes |
| Cloud Firestore | Yes (products/users/orders/cart/wishlist/addresses/delivery_details/delivery_locations/settings) | Yes (all incl. audit_logs, partners, delivery_partners, admins) | Yes (orders, partners) |
| Cloud Storage | Not used in code (bucket config only) | Yes — catalogue image uploads | Not used in code (dependency present) |
| Firebase Auth | Not used at runtime (declared in pubspec; no Dart import; plugin registered only) | Not used (import removed Stage 4.4.2) | Not used at runtime |
| Analytics / Crashlytics / FCM | None | None | None |

Evidence: `pubspec.yaml` ×3, `GeneratedPluginRegistrant.java` ×3, `lib/main.dart` (initializeApp only), workspace searches (0 hits for FirebaseAnalytics/firebase_messaging/firebase_crashlytics; `FirebaseAuth` only in historical stage reports).

## 5. IMAGES / FILES
Users (customers/partners) do **not** upload any images or files. Only the Admin app uploads catalogue/branding images to Firebase Storage under rules-constrained prefixes (`products/`, `brand_logos/`, `category_icons/`, `sub_category_icons/`, `notification_assets/`, `business_assets/`; image content-types only, < 10 MB) and stores download URLs in Firestore (`storage.rules`; admin repositories above). `image_picker` removed from Admin in Stage 4.4.5.

## 6. THIRD-PARTY SERVICES / INTEGRATIONS (actual)
1. **Google Firebase** (Cloud Firestore, Cloud Storage, project `vkart-1`) — data hosting (Google LLC).
2. **Gmail SMTP** (`smtp.gmail.com:587`, `mailer`) — OTP login emails in all three apps; recipient name+email transmitted to Google to deliver the mail.
3. **Google Maps (external app)** — Partner only: opens navigation for a delivery address via `url_launcher`. No Maps SDK embedded; no location read.
4. **google_fonts** — static font assets.
No ads, no analytics, no payment gateway, no crash reporting, no push. Payment = **Cash on Delivery only** (no card data anywhere).

## 7. ADMIN / PARTNER ACCESS TO USER DATA
- **Admin** can view: every customer's name, email, photo URL, account timestamps, `active` flag; per-customer order count and total spend; full order records (items, amounts, payment method, customer name, email, phone, delivery address); the admin audit trail of changes. Admin can toggle customer `active` and manage catalogue/rosters.
- **Partner** can currently view **all orders** (not just assigned): customer name, phone, delivery address, items, amounts, status; can advance order status one step forward and attach delivery notes/reason.
- Note: `assigned_orders_screen.dart` calls `listenToAssignedOrders('partner_id_here')` (placeholder id) and the repository intentionally streams all orders — assignment-based scoping is **not implemented** (pre-existing, feature-frozen).

## 8. DATA RETENTION / DELETION (implementation truth)
- **Sign out** clears the local session only; Firestore data remains (`auth_service.dart` `signOut`).
- **Account deletion: NOT IMPLEMENTED** in any app. Nothing deletes `users/{uid}`, orders, cart, wishlist, or delivery_details.
- **Order deletion: NOT IMPLEMENTED** (rules header "No Deletes"; default-deny tail).
- Address deletion exists in `AddressProvider.deleteAddress()`, but the deployed `/addresses` rules require a Firebase-Auth owner match — with no app carrying Firebase Auth these grants never apply, so address persistence/deletion via the app is effectively blocked (pre-existing functional condition, unchanged here).
- Retention policy: none coded; data persists until removed via the Firebase console by the store owner.

## 9. SECURITY MECHANISMS ACTUALLY IMPLEMENTED (no overclaims)
- **App-layer auth**: email allowlists (admin/partner) + 6-digit OTP (5-min expiry, 5 attempts, 30 s resend); sessions on-device (SharedPreferences); partner additionally gated by the Firestore `partners` doc (`active`, `role`).
- **Firestore rules** (`vkart_customer/firestore.rules`, matching deployed snapshots `logs/rules_live_0.txt`, `rules_predeploy.txt`): catalogue/delivery locations/notifications public read + staff write; `users` owner-or-staff with `{'active'}`-only admin toggle validation; `orders` staff create; updates restricted to `status/updatedAt/deliveryNotes/deliveryPhotoUrl/unableToDeliverReason` with **forward-only** transitions; `audit_logs`, `delivery_partners`, `partners` staff-only (partners: no deletes; `admins`: no client writes); default **deny-all** tail.
- **Storage rules**: public read; staff-caller image-only writes (< 10 MB) to fixed prefixes; staff-only delete; default deny.
- **Transport**: TLS (Firebase HTTPS; SMTP 587).
- **Documented structural limitation (from the ruleset itself)**: no app carries a Firebase Auth identity, so "staff" cannot be distinguished from any other unauthenticated caller — staff-granted data (all orders incl. customer contact details; all `users` docs) is readable by any unauthenticated caller that can reach the Firestore API. Acknowledged in the rules header (Stage 4.1/4.3 audit). Stated here so the privacy/security narrative does not overclaim.
- No encryption-at-rest claims beyond Google Firebase defaults; no other security claims.

## 10. COMPARISON TABLE — CUSTOMER / ADMIN / PARTNER

| Aspect | Customer | Admin | Delivery Partner |
|---|---|---|---|
| Auth | Email+OTP (SMTP), session prefs | Email+OTP (allowlist ×2) | Email+OTP (single allowlist) + `partners` doc gate |
| PII collected | Name, email, phone (checkout), delivery village + optional address text, order contents/amounts, timestamps | Own admin name+email (session); audit-log identity | Own partner name+email (session, `partners` doc) |
| PII accessed | Own data only (own orders/cart/wishlist/details) | All customers' profiles (name/email/photo/active), all orders incl. contact+address, metrics | All orders: customer name, phone, full address, items, amounts, status |
| Location (GPS) | Not collected (declared perms unused) | Not collected (no perms) | Not collected; passes order address to Google Maps |
| Images uploaded | None | Catalogue images → Firebase Storage | None |
| Firebase services | Core, Firestore | Core, Firestore, Storage | Core, Firestore |
| Third parties | Firebase, Gmail SMTP | Firebase, Gmail SMTP | Firebase, Gmail SMTP, Google Maps (external) |
| Deletion features | Sign-out only | None | None |
| Manifest permissions | INTERNET, ACCESS_FINE_LOCATION, ACCESS_COARSE_LOCATION (unused) | INTERNET | INTERNET |

## 11. FILES INSPECTED (evidence base)
- **Customer**: `lib/main.dart`; `lib/services/{auth_service, customer_otp_service, firestore_service, session_upgrade_service}.dart`; `lib/config/{customer_auth_config, smtp_config, delivery_config}.dart`; `lib/providers/{auth_provider, order_provider, cart_provider, address_provider, delivery_location_provider}.dart`; `lib/repositories/{order_repository, product_repository}.dart`; `lib/screens/auth/{login_screen, otp_screen}.dart`; `lib/screens/cart/checkout_screen.dart`; `lib/screens/address/address_screen.dart`; `lib/screens/orders/{order_details_screen, order_success_screen}.dart`; `lib/screens/profile/profile_screen.dart`; `lib/models/delivery_location_model.dart`; `firestore.rules`; `storage.rules`; `pubspec.yaml`; `android/app/src/main/AndroidManifest.xml`; `GeneratedPluginRegistrant.java`; `android/app/google-services.json`
- **Shared**: `lib/src/models/{order_model, address_model, delivery_partner_model, audit_log_model}.dart`, `models/user/user_model.dart`, `models/admin/admin_model.dart`, `pubspec.yaml`
- **Admin**: `lib/services/{admin_auth_service, audit_logger_service}.dart`; `lib/auth/admin_auth_provider.dart`; `lib/config/admin_auth_config.dart`; `lib/repositories/admin_customer_repository.dart`; `lib/screens/customer/customer_list_screen.dart`; `lib/screens/orders/order_details_screen.dart`; `pubspec.yaml` (via package index); `AndroidManifest.xml`; storage-upload evidence: `logs/s441_storage_usage.txt`, `stage445_admin_product_image_url_report.md`
- **Partner**: `lib/services/{partner_auth_service, smtp_otp_service}.dart`; `lib/config/delivery_partner_auth_config.dart`; `lib/src/services/map_service.dart`; `lib/src/repositories/order_repository.dart`; `lib/src/providers/order_provider.dart`; `lib/src/ui/screens/{assigned_orders_screen, order_details_screen}.dart`; `pubspec.yaml`; `AndroidManifest.xml`
- **Rules snapshots**: `logs/rules_live_0.txt`, `logs/rules_predeploy.txt`, `rules_snapshot.txt`
- **0-hit search proofs**: geolocator/geocoding Dart usage; `package:firebase_auth` / `package:google_sign_in` imports; `tel:` dialer; FirebaseAnalytics/Crashlytics/Messaging; `ImagePicker` (removed 4.4.5)

## VERDICT: PASS WITH OWNER INPUT
Owner input required before Play publication — see `privacy_policy_draft.md` placeholders and the Owner Items section of the Stage 4.6D response.




