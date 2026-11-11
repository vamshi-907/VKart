# STAGE 4.6E — PRE-PLAY COMPLIANCE REPORT

Date: 2026-09-16 · Feature freeze ACTIVE · Firebase project: `vkart-1` · No production build, no Play Console action.

## 1. FILES INSPECTED (before any modification)

- **Rules**: `vkart_customer/firestore.rules` (full), deployed snapshots `logs/rules_live_0.txt`, `logs/rules_predeploy.txt`, `rules_snapshot.txt`
- **Customer**: `lib/services/auth_service.dart`, `lib/services/firestore_service.dart`, `lib/providers/auth_provider.dart`, `lib/screens/profile/profile_screen.dart`, `lib/screens/cart/checkout_screen.dart`, `lib/providers/cart_provider.dart`, `lib/providers/address_provider.dart`, `lib/providers/delivery_location_provider.dart`, `lib/main.dart`, `android/app/src/main/AndroidManifest.xml`, `pubspec.yaml`, `pubspec.lock`, `.dart_tool/package_config.json`
- **Partner**: `lib/src/repositories/order_repository.dart`, `lib/src/providers/order_provider.dart`, `lib/src/ui/screens/assigned_orders_screen.dart`, `lib/services/partner_auth_service.dart`, `lib/config/delivery_partner_auth_config.dart`
- **Searches (0-hit proofs)**: `package:geolocator|package:geocoding|Geolocator(|Geocoding(` (Dart usage), `getSettings(|saveSettings(` (callers), existing delete helpers, `assignedPartnerId` writes

### Decisive rules facts (verified before implementation)
- `users/{userId}`: `allow delete: if isOwnerUid(userId)` — requires a **Firebase Auth owner** (dormant in every app). Staff-caller update is granted only for the login profile save (`request.resource.data.uid == userId`) or the admin `{'active'}` toggle. Since the customer app has no Firebase Auth session and the **document ID is the session email**, the profile doc can be neither deleted nor meaningfully scrubbed client-side.
- `cart/{userId}`, `wishlist/{userId}`, `delivery_details/{userId}`: `allow read, write: if isStaffCaller() || (isSignedIn() && request.auth.uid == userId)` — `write` includes delete → deletable by the unauthenticated customer app.
- `orders/{orderId}`: `allow delete: if false` (header: "FORWARD-ONLY status, No Deletes").
- `addresses/{addressId}`: grants only to a Firebase-Auth owner — the app cannot read or write them at all.
- `settings/{docId}`: no caller exists in the customer app (0 hits) → no user-owned doc is created there.

## 2. TASK 1 — CUSTOMER ACCOUNT DELETION

### Existing behavior (before this stage)
Sign-out only: cleared 4 SharedPreferences session keys and returned to guest. No deletion of any Firestore data. No Delete Account UI.

### Implementation performed (smallest production-safe mechanism)
1. **UI** (`profile_screen.dart`): danger-zone **"Delete Account"** button (`Icons.delete_forever`, red outline) directly below Sign Out, visible only to authenticated users. It opens a **confirmation dialog** stating deletion is permanent, listing exactly what is deleted (sign-in session on device, saved cart, saved wishlist, delivery contact details) and what is retained (past orders for store records; the customer profile record, removable only by the store owner). **Cancel does nothing**; deletion needs a second deliberate tap on "Delete Permanently" — no single-tap deletion. On success: confirmation snackbar + navigation to `/login`. On failure: error snackbar, session preserved.
2. **Provider** (`auth_provider.dart` → `AuthProvider.deleteAccount()`): on success clears cached userId, user doc, pending OTP state and OTP service state, transitions to `AuthState.guest`; the existing `main.dart` builder then clears cart/wishlist providers via `setUserId(null)` (no stale account data visible). On **partial failure the session is preserved** (`AuthState.authenticated`) so the user can retry, and `errorMessage` names exactly which stores failed.
3. **Orchestrator** (`auth_service.dart` → `AuthService.deleteAccountData()`): sequentially deletes `cart/{uid}`, `wishlist/{uid}`, `delivery_details/{uid}`; collects per-target failures (never silently swallowed); if **any** delete fails it throws the new `AccountDeletionException` listing failed targets **without clearing the session**; only on full success calls `signOut()` and additionally clears the account-scoped `selectedAddressDocId` preference.
4. **Firestore layer** (`firestore_service.dart`): `deleteCart`, `deleteWishlist`, `deleteDeliveryDetails` added beside their save counterparts, each documented with its rules basis.

### Exact files changed (Task 1)
`vkart_customer/lib/services/firestore_service.dart` · `vkart_customer/lib/services/auth_service.dart` · `vkart_customer/lib/providers/auth_provider.dart` · `vkart_customer/lib/screens/profile/profile_screen.dart`

### Firestore collections affected
- **Deleted**: `cart/{userId}`, `wishlist/{userId}`, `delivery_details/{userId}` (delivery phone number + timestamps)
- **Untouched**: `users`, `orders`, `order_items`, `addresses`, `products`, `brands`, `categories`, `sub_categories`, `notifications`, `audit_logs`, `delivery_partners`, `partners`, `admins`, `settings`, `delivery_locations`

### Data deleted vs intentionally retained
| Data | Action | Why |
|---|---|---|
| Cart items | Deleted | Customer-owned; rules permit staff-caller delete |
| Wishlist items | Deleted | Same |
| Delivery contact (phone + timestamps) | Deleted | Same — removes the delivery PII the app stores |
| Past orders + order items | **Retained** | Rules: `allow delete: if false`; required for store operations |
| Customer profile record (`users/{uid}`) | **Retained (limitation)** | Rules grant `users` deletes only to a Firebase-Auth owner (dormant); doc ID is the session email — no client-side scrub possible |
| Local session + selected-address reference | Deleted (on-device) | Requirement 10 |
| Addresses, catalogue, admin/partner data, other customers | Untouched | Rules-protected / explicitly excluded |

### Limitation (documented, not bypassed)
Full erasure of `users/{email}` requires a server-side mechanism. Minimum secure future options (no change made now):
1. **Preferred:** a Cloud Function (Admin SDK, bypasses rules) exposed as an HTTPS Callable that re-verifies the customer with a fresh email OTP (existing SMTP infrastructure) and then deletes `users/{uid}` (+ optionally lists/deletes that customer's `addresses` docs if rules are later auth-scoped). No rules weakening required.
2. **Alternative:** activate a real Firebase Auth session for the customer at deletion time — the rules **already** contain the forward-compatible grant `allow delete: if isOwnerUid(userId)`, so the app could then delete its own profile doc without any rule change.

Play-policy note: the shipped flow satisfies "in-app account deletion" for all app-stored account data except the profile record; the confirmation dialog and privacy policy must state the profile-record retention until the owner adds the server-side mechanism.

## 3. TASK 2 — UNUSED LOCATION PERMISSIONS REMOVED

**Permissions removed** (`vkart_customer/android/app/src/main/AndroidManifest.xml`):
- `android.permission.ACCESS_FINE_LOCATION` — REMOVED
- `android.permission.ACCESS_COARSE_LOCATION` — REMOVED
- Stale comment "GPS delivery-address detection (Phase 3)." removed; `INTERNET` retained. Final permission set: **INTERNET only**.

**Dependencies removed** (`vkart_customer/pubspec.yaml`): `geolocator: ^14.0.3`, `geocoding: ^5.0.0` (direct deps; both had ZERO Dart usage). `flutter pub get` re-resolved successfully; `geolocator`/`geocoding` no longer appear in `pubspec.lock` or `.dart_tool/package_config.json` (verified). Note: `GeneratedPluginRegistrant.java` is a generated file and still lists the old plugins until the next build regenerates it — expected and harmless (it will drop geolocator/geocoding on the approved rebuild).

**Evidence GPS is not used** (workspace searches, 0 hits in Dart): no `package:geolocator` import, no `Geolocator(` / `getCurrentPosition` / `placemarkFromCoordinates`, no `package:geocoding` import. The address form (`address_screen.dart`) is manual text entry; the delivery location is selected from the Firestore `delivery_locations` collection (`delivery_location_selection_screen.dart` → `delivery_location_provider.dart` → `fetchDeliveryLocations()`), persisted locally in SharedPreferences — unchanged.

**Unchanged**: delivery-location feature, `delivery_config.dart` pricing rules, address screens, partner app (its `geolocator`/`permission_handler` deps are also unused but partner changes were out of scope for Task 2 — noted as optional future cleanup).

## 4. TASK 3 — PARTNER ORDER ACCESS (AUDIT ONLY — NO CHANGE)

**Exact current behavior**: `OrderRepository.getAssignedOrders()` streams **all** orders ordered by `createdAtMs` — the `where('assignedPartnerId', isEqualTo: partnerId)` filter is deliberately commented out ("For now, show all orders so partners can see real data"). The screen passes a **placeholder id** `'partner_id_here'` (`assigned_orders_screen.dart:19`). Partner sees customer name, phone, full address, items and amounts for every order, and can advance status one step forward (rules-validated).

**Why it receives all orders (root cause)**: the frozen architecture has no Firebase Auth identity for staff, so every app is an unauthenticated "staff caller" (`request.auth == null`). The `orders` read grant is `isSignedIn() && resource.data.userId == request.auth.uid) || isStaffCaller()` — a partner (like any unauthenticated caller) reads all orders. Additionally `assignedPartnerId` is written as empty at order placement — assignment is not implemented anywhere, so a client-side filter would show zero orders.

**Exact security limitation**: **server-side per-partner enforcement is impossible in the current architecture.** Firestore rules cannot verify a partner's identity when `request.auth == null`; any client-side filter is a UI convenience, not a security boundary (the Firebase config inside the APK allows any unauthenticated caller to query `orders` directly). No fake client-side security claim is made.

**Secure minimal fix possible now?** No — any restriction would either be client-side (spoofable) or require widening/changing rules for unverifiable identities. Per the task, **partner behavior is left unchanged**.

**Required future architectural fix** (minimum path): (1) issue real staff identities — Firebase Auth custom tokens for the partner (or any authenticated staff identity); (2) populate `assignedPartnerId` at assignment time in the admin app; (3) scope rules: `allow read: if isSignedIn() && (resource.data.assignedPartnerId == request.auth.uid || <admin identity>);` (4) replace the `'partner_id_here'` placeholder with the real session id. Until then, the risk statement stands: the authorized partner email can view all orders, and any unauthenticated caller could read the `orders` collection directly (pre-existing structural limitation, documented in the rules header and Stage 4.1/4.3 audits).

## 5. TASK 4 — FIRESTORE RULES REVIEW

**Result: NO rules changed. `firestore.rules` and `storage.rules` are byte-identical to before this stage.**

Reviewed against all six areas:
- **A. Customer account deletion**: implemented entirely within existing grants (`cart`/`wishlist`/`delivery_details` staff-caller write includes delete). The `users` delete restriction (`isOwnerUid`) was **respected, not bypassed, not weakened** — the limitation is documented in Task 1 instead.
- **B. Customer-owned data**: cart/wishlist/delivery_details grants unchanged; user-profile grant unchanged.
- **C. Orders**: `allow delete: if false`, forward-only `validOrderUpdate()` field validation — all preserved and untouched.
- **D. Partner order access**: no rule change (see Task 3 — no secure server-side change is possible without an identity architecture).
- **E. Existing admin access** (`products`, `users {'active'}` toggle, `audit_logs`, `delivery_partners`, storage uploads): unchanged.
- **F. Existing customer access**: unchanged.
- **Default-deny tail** (`match /{document=**} { allow read, write: if false; }`) — intact.

**Confirmation: no permissive rules introduced; no field validation or status-transition validation removed; the rules were not edited at all.**

## 6. ANALYZE RESULTS

| Project | Result |
|---|---|
| vkart_customer | **0 errors** · 38 pre-existing infos/warnings (avoid_print in `main.dart`/`splash_screen.dart`; unused imports in `checkout_screen.dart`/`delivery_location_selection_screen.dart`; context-across-async-gap infos in `checkout_screen.dart`; unused `_validSelectedLocation` in `home_header.dart`) — **none in files changed by this stage; no new analyzer issues introduced** |
| vkart_admin | **No issues found** |
| vkart_delivery_partner | **0 errors** · 1 pre-existing warning (`unused_field _expiryCountdown` in `lib/screens/auth/partner_otp_screen.dart:24`) — untouched by this stage |
| vkart_shared | **No issues found** |

## 7. FUNCTIONAL VERIFICATION RESULTS

**Account deletion (source-level; runtime smoke test requires the approved rebuild — no build/run in this stage per Task 7):**
1. Deletion action reachable: Delete Account button rendered in `_AuthenticatedProfile` (authenticated users only) — verified in code.
2. Confirmation dialog: `AlertDialog` with permanent-deletion warning, retained-data disclosure, Cancel + "Delete Permanently" — verified in code.
3. Cancel path: `if (confirmed != true ...) return;` — no deletion, no state change — verified.
4. Confirm path: `AuthProvider.deleteAccount()` → `AuthService.deleteAccountData()` → three Firestore deletes — verified.
5. Local session cleared: `signOut()` removes all 4 session keys + `selectedAddressDocId` — verified.
6. Guest/login state: provider → `AuthState.guest`; screen navigates `pushReplacementNamed('/login')`; `main.dart` builder clears cart/wishlist providers — verified.
7. Protected orders untouched: no `orders`/`order_items` delete call exists anywhere; rules additionally deny it — verified.
8. Other customers' data unreachable: every delete targets `cart/{uid}`, `wishlist/{uid}`, `delivery_details/{uid}` keyed by the deleting user's own session id — verified.
9. Failure surfacing: per-target failure collection → `AccountDeletionException` → provider keeps session + sets `errorMessage` naming failed targets → UI error snackbar — verified. No silent swallowing.

**Location:** customer manifest contains exactly one `uses-permission` (INTERNET) — verified via findstr. No `ACCESS_FINE_LOCATION`/`ACCESS_COARSE_LOCATION` remains. Zero geolocator/geocoding Dart imports/calls (search-verified). `pubspec.yaml`, `pubspec.lock`, `package_config.json` contain no geolocator/geocoding entries. The Firestore delivery-location selection path (`delivery_location_selection_screen.dart` → `DeliveryLocationProvider` → `fetchDeliveryLocations`) is untouched and compiles clean.

**Partner:** no change made; access model and limitation documented in Task 3.

## 8. SOURCE CHANGES SUMMARY

Changed (6 files):
1. `vkart_customer/lib/services/firestore_service.dart` — +3 delete methods (+ rules-basis comments)
2. `vkart_customer/lib/services/auth_service.dart` — +`AccountDeletionException`, +`deleteAccountData()`
3. `vkart_customer/lib/providers/auth_provider.dart` — +`deleteAccount()`
4. `vkart_customer/lib/screens/profile/profile_screen.dart` — +Delete Account button/dialog/handler/constructor field
5. `vkart_customer/android/app/src/main/AndroidManifest.xml` — removed 2 location permissions + stale comment
6. `vkart_customer/pubspec.yaml` — removed `geolocator`, `geocoding`

Regenerated: `vkart_customer/pubspec.lock`, `vkart_customer/.dart_tool/package_config.json` (via `flutter pub get`).

Created: this report. Not modified: all Admin/Partner sources, `vkart_shared`, `firestore.rules`, `storage.rules`, Firebase configs, the Stage 4.6C report, Stage 4.6D documents. No temporary scripts, no duplicate files, no placeholder code.

## 9. PRODUCTION ARTIFACT STATUS

**The verified Stage 4.6C artifacts were NOT rebuilt, NOT overwritten, and NOT uploaded in this stage.** No `flutter build apk --release`, no `flutter build appbundle --release`, no `flutter clean` was run. All six 4.6C artifacts remain as verified. A rebuild (with a versionCode bump per Play convention, e.g. Customer 1.0.1+2) is required AFTER owner approval so the shipped APK/AAB contains these compliance changes. Do not publish the current 4.6C artifacts — they pre-date the account-deletion flow and the location-permission removal.

## 10. REMAINING PLAY STORE REQUIREMENTS

1. Owner approval of this stage → rebuild all three artifacts (versionCode bump) → re-run Stage 4.6C verification on the new artifacts.
2. Owner decision on server-side full profile-record erasure (Cloud Function recommended — see Task 1) so account deletion becomes 100% complete; until then the dialog text and privacy policy must disclose the store-retained profile record.
3. Finalize `privacy_policy_draft.md` placeholders (owner name, contact, effective date, hosted URL) and publish the policy.
4. Complete the Play Data Safety form (inputs in `stage46d_privacy_audit_report.md`; location data is NOT collected and the location permission is now removed from the customer app).
5. Partner order-scoping architecture (Task 3) — future stage; Partner listing restricted to the authorized store partner.
6. Optional hygiene (future stages): partner app's unused `geolocator`/`permission_handler`/`firebase_storage`/`google_sign_in`/`firebase_auth` deps; customer app's dormant `google_sign_in`/`firebase_auth`; embedded SMTP credentials (documented risk, out of scope).

## 11. FINAL VERDICT

**PASS WITH OWNER INPUT**

All required compliance changes were completed safely: in-app account deletion implemented strictly within existing rules (protected order history and other customers' data untouched; partial-failure honesty preserved), unused location permissions and dependencies removed with GPS-unused evidence, partner access left unchanged with an explicit no-fake-security statement, and zero Firestore rule changes. Owner input is required for: the full profile-record erasure mechanism, privacy-policy hosting/content, Data Safety submission, and the approved rebuild.





