# Stage 4.3 — Release Candidate Report

**Date:** 2026-09-05 · **Flutter 3.44.3 stable · Dart 3.12.2 · Windows 11**
**Scope:** Continue from last completed checkpoint (fix markers + rules deploy + RC4 analyze/live-run) →
fresh analyze → release builds (APK + AAB) → full text/source verification.

---

## 1. `flutter analyze`

| App | Result | Errors |
|-----|--------|--------|
| vkart_customer   | 38 findings (all `info`/`warning`) | 0 |
| vkart_admin      | `No issues found!` (exit 0) | 0 |
| vkart_delivery_partner | 1 warning (`unused_field _expiryCountdown`) | 0 |

Customer sample findings (non-blocking, existing): `avoid_print`, `use_build_context_synchronously`,
unused import in `checkout_screen.dart`, `unused_element _validSelectedLocation` in `home_header.dart`.
Partner: unused field `_expiryCountdown` in `partner_otp_screen.dart`. **0 errors across all 3 apps.**

## 2. `flutter build apk --release` — ✅ PASS (3/3, all exit 0)

| App | Artifact | Size |
|-----|----------|------|
| vkart_customer   | `build\app\outputs\flutter-apk\app-release.apk` | 71.5 MB |
| vkart_admin      | `...\vkart_admin\...\app-release.apk` | 52.2 MB |
| vkart_delivery_partner | `...\vkart_delivery_partner\...\app-release.apk` | 49.2 MB |

## 3. `flutter build appbundle --release` — ✅ PASS (3/3, all exit 0)

| App | Artifact | Size |
|-----|----------|------|
| vkart_customer   | `build\app\outputs\bundle\release\app-release.aab` | 71.2 MB |
| vkart_admin      | `...\app-release.aab` | 52.0 MB |
| vkart_delivery_partner | `...\app-release.aab` | 50.1 MB |

**Environment note (NOT a VKart error):** every AAB build prints
`Release app bundle failed to strip debug symbols from native libraries.`
`flutter doctor` shows the Android toolchain needs `cmdline-tools` + accepted SDK licenses.
Builds still exit 0 and produce valid artifacts. Fix environment-side before Play publishing.

## 4–6. App verification (source inspection)

- **Customer** — `main.dart`: Firebase init + 7 providers + Splash→(Login|Main) route gate; checkout validates
  name → email → selected location → 10-digit phone → session, then `OrderProvider.placeOrder`
  (status `orderPlaced`, cart not cleared on failure); live order stream; session persisted (SharedPreferences).
- **Admin** — `main.dart`: Firebase init + 13 providers + `AuthGate`; email-allowlist OTP login; order snapshot
  stream; `updateOrderStatus` writes `{status, updatedAt}` (rules-whitelist match).
- **Delivery Partner** — Firebase init via `firebase_options.dart` + `AuthGate`; Firestore-authorized OTP;
  order streams + status writes `{status, updatedAt, deliveryNotes?, deliveryPhotoUrl?, unableToDeliverReason?}`
  (rules-whitelist match); `tel:` dialer + Google Maps navigation via url_launcher.
- `INTERNET` permission present in all three `src/main/AndroidManifest.xml`.

## 7. Firebase configuration — ✅

- Project consistent: `vkart-1` everywhere.
- Customer `google-services.json` appId `...754a5c11` == `firebase_options.dart` android appId.
- Admin `google-services.json` carries customer + admin clients; `firebase_options.dart` android appId `...bb4df8f2` matches.
- Firestore rules compiled & deployed (`rc4_rules_deploy.log`: "Deploy complete!"); match `/cart|/wishlist` = owner UID,
  `/orders` owner-create/staff-forward-update/no-delete, `delivery_locations` public read/staff write.
- Note: Delivery Partner registers no Android app of its own; it reuses the admin Android appId in `firebase_options.dart`.
  Works today (config-only Firestore/SMTP), but Stage 4.4/5 should register a dedicated app for package
  `com.example.vkart_delivery_partner`.

## 8. Authentication / session persistence — ✅

- Customer: `AuthService` stores token + userId + name + email in SharedPreferences; `restoreSession()` on init;
  SplashScreen waits for `AuthState` then routes; guest mode supported. Cart/wishlist doc id == signed-in userId.
- Admin: `admin_session_*` SharedPreferences; `restoreSession()` re-validates against the email allowlist, else clears.
- Partner: `partner_auth_service.dart:166 restoreSession()`; auth gate routes to login/dashboard.
- Admin/Partner unauthenticated Firestore writes are covered by `isStaffCaller()` rules (documented structural limitation).

## 9. Order flow — ✅

Checkout → `OrderProvider.placeOrder` builds `OrderModel` (status `orderPlaced`, `deliveryCharge` from `DeliveryConfig`)
 → `OrderRepository` → `FirestoreService.createOrder`. Rules gate create to `userId == auth.uid`.

## 10. Order status synchronization — ✅

- Customer: live `streamOrders(userId)` subscription (provider line 183) updates orders in real time.
- Admin: `getAllOrders().snapshots()`; Partner: assigned/history order streams.
- Forward-only transitions enforced in app (`_statusRank` guard) and in rules (`validOrderUpdate`), plus idempotent same-status.

## 11. Delivery location — ✅

Provider loads `delivery_locations` (active + deliveryAvailable), sorts by displayOrder, persists selection;
selection UI in `home_header.dart` dialog + checkout `Consumer`; checkout blocks placement without a selection.
## 12. ₹499 free-delivery rule — ✅

`DeliveryConfig.freeDeliveryThreshold = 499`, `deliveryCharge = 40`; `deliveryChargeFor()` compares integer paise so
₹499.00 → free, ₹498.99 → ₹40. Single source consumed by cart (`deliveryCharge`, `amountToFreeDelivery`) and all UI strings.

## 13. Release configuration — ✅

Version `1.0.0+1` all apps; release buildType uses **debug signing** (`signingConfigs.getByName("debug")` scaffold TODO) —
expected at this stage; **Stage 4.4 = Production Signing**. Java 17, Flutter SDK compile/target defaults.
Gradle advisory (`firebase_storage` applies Kotlin Gradle Plugin) is informational only.

---

## Non-blocking observations

1. AAB "failed to strip debug symbols" — Android toolchain environment gap (cmdline-tools/licenses); fix in tooling.
2. Partner app reuses admin Android appId (`...bb4df8f2`) — register dedicated Firebase app in a later stage.
3. Analyze hygiene items (0 errors): partner `_expiryCountdown` unused field, customer unused imports,
   `_validSelectedLocation` unused element — clean-up candidates, not blockers.

---

## VERDICT

All application checks pass.

**VKart is ready to move to Stage 4.4 — Production Signing.**