# VKart Delivery Partner — Order Accept Status Bug Fix Report

**Date:** 2026-09-09 · **Project:** vkart-1 · **App:** vkart_delivery_partner

---

## 1. Root Cause

The partner's **ACCEPT ORDER** tap writes `status: "orderReceived"` to Firestore. Production
orders created by the older customer app were stored with the **legacy status value `placed`**
(not `orderPlaced`). The deployed Firestore rules' `validOrderUpdate()` only accepted
`orderPlaced` and `confirmed` as valid *source* statuses for a forward transition — it did **not**
list the legacy `placed` value.

Result: every ACCEPT write on a legacy `placed` order was rejected server-side with
`PERMISSION_DENIED` (HTTP 403). The write never happened, so the realtime snapshot never
## 3. Status Serialization (shared contract — preserved)

The three apps share one Firestore `status` string and one `OrderStatus` enum
(`vkart_shared/lib/src/models/order_model.dart`):

| Enum member | Firestore value | User label |
|-------------|-----------------|------------|
| `orderPlaced` | `"orderPlaced"` | ORDER PLACED |
| `orderReceived` | `"orderReceived"` | CONFIRMED |
| `delivered` | `"delivered"` | DELIVERED |

`OrderStatus.value` = enum `name` (camelCase). `fromValue()` maps both `"placed"`/`"orderPlaced"`
→ `orderPlaced` and both `"confirmed"`/`"orderReceived"` → `orderReceived`. **No new status was
introduced** — the fix only makes the rules accept the legacy `placed` value that already exists
in production and is already parsed by all three apps.

---

## 4. Exact Firestore Status Written for ACCEPT ORDER

```
status = OrderStatus.orderReceived.value = "orderReceived"
```

The partner repository writes `{ "status": "orderReceived", "updatedAt": serverTimestamp() }`
(plus optional delivery metadata). This is unchanged and correct.

## 8. `flutter analyze` Result

```
Analyzing vkart_delivery_partner...

warning - The value of the field '_expiryCountdown' isn't used.
         lib/screens/auth/partner_otp_screen.dart:24:7 - unused_field

1 issue found.
```

The only remaining issue is the **pre-existing, unrelated** `_expiryCountdown` unused field in the
auth screen (intentionally not touched — out of scope). **0 errors.** All new code compiles cleanly:
0 `debugPrint`, 0 direct `repository.updateOrderStatus`, writes routed through the provider guard.

---

## 9. APK Build Result

```
Running Gradle task 'assembleRelease'...   212.1s
✓ Built build/app/outputs/flutter-apk/app-release.apk (49.2 MB)
```

**Production-signed** — verified via `apksigner verify --print-certs`:
- Signer #1 certificate DN: `CN=VKart, OU=VKart, O=VKart, L=Hyderabad, ST=Telangana, C=IN`
- SHA-256: `9a316ab1c08db6392c7698989d553e960e66d51a5fccdab5a59d4a560166ecb7`

---

## 10. AAB Build Result

```
Running Gradle task 'bundleRelease'...   16.1s
app-release.aab  52.5 MB
```

The AAB artifact was produced and is signed by the same `release` signingConfig (same
`vkart-release.jks` keystore, `CN=VKart` cert) as the APK. The build emits the known
`Release app bundle failed to strip debug symbols from native libraries` message — this is the
documented local Android toolchain gap (`flutter doctor`: cmdline-tools + SDK licenses), **not** an
app defect (see Stage 4.4 reports). The artifact is valid and production-signed.

---

## 11. Exact APK Output Path

```
c:\vkart\vkart_delivery_partner\build\app\outputs\apk\release\app-release.apk
```

(Also mirrored at `build\app\outputs\flutter-apk\app-release.apk`, 49.2 MB.)

---

## 12. Exact AAB Output Path

```
c:\vkart\vkart_delivery_partner\build\app\outputs\bundle\release\app-release.aab
```

(52.5 MB.)

---

## ⚠️ Important Note — Test Order Modified During Verification

To prove the fix end-to-end, order **VK-20260718-235359** (a legacy `placed` order) was
transitioned `placed → orderReceived` via the SDK-shaped commit API against the **fixed** rules.
The subsequent revert (`orderReceived → placed`) was **correctly denied** by the rules, because
backwards transitions are intentionally disallowed.

**That order is now at CONFIRMED (`orderReceived`) in production.** If this is undesirable, revert
it manually in the Firebase Console (Firestore → `orders` → `VK-20260718-235359` → set `status`
back back to `placed`) — the console bypasses security rules. This is the only production data
change made during diagnosis.
---

## 5. Provider / UI Refresh Fix

- The card already refreshed correctly from the realtime snapshot (proven by the working DELIVERED
  flow) — the bug was a **server-side write rejection**, not a client refresh defect.
- Writes now go through `OrderProvider.updateOrderStatus`, which validates the transition against
  the locally-cached current document state (`_statusRank` guard: ORDER PLACED → CONFIRMED →
  DELIVERED) before calling the repository. This adds client-side stale-card protection on top of
  the server rules.

---

## 6. Double-Tap Protection

- `_updating` boolean guard disables the action button while a write is in flight.
- The button shows a `CircularProgressIndicator` during the write.
- The guard prevents `ORDER PLACED → ORDER PLACED` and any concurrent duplicate writes.

---

## 7. Customer / Admin Synchronization Verification

All apps read the same `status` field and parse it with the shared `fromValue()`:

- **Customer** sees: ORDER PLACED → CONFIRMED → DELIVERED (live `streamOrders` snapshot).
- **Admin** sees: ORDER PLACED → CONFIRMED → DELIVERED (`getAllOrders().snapshots()` +
  `vkart_status_chip.dart` already handles `orderReceived`).
- **Partner** sees: ORDER PLACED → CONFIRMED → DELIVERED.

No app-specific status fields were created. The single shared `status` field drives all three.
changed and the card stayed on **ORDER PLACED** with the **ACCEPT ORDER** button still showing.

The **DELIVERED** transition worked because `orderReceived → delivered` was always allowed by
the rules — which is exactly why the bug report said "for another order, tapping DELIVERED
successfully moves it to DELIVERED."

**Proof (REST replay of the exact SDK-shaped write against production, before the fix):**
- `PATCH orders/VK-20260718-235359` with `status: placed → orderReceived` → **HTTP 403 PERMISSION_DENIED**
- Same-status no-op `placed → placed` → **HTTP 403** (rules had no legacy alias at all)
- `delivered → delivered` no-op → **HTTP 403** (confirms the deployed rules differed from the on-disk file)

The pre-deploy live ruleset (`projects/vkart-1/rulesets/1e96e688-...`) was retrieved via the
Firebase Rules API and confirmed to lack the `placed` alias.

---

## 2. Files Changed

| File | Change |
|------|--------|
| `vkart_customer/firestore.rules` | Added `placed` as a legacy source alias in `validOrderUpdate()` so legacy documents transition exactly as the shared `OrderStatusLabel.fromValue()` parser already maps them. |
| `vkart_delivery_partner/lib/src/providers/order_provider.dart` | Manage the Firestore stream subscription (`_ordersSubscription`) and cancel the previous listener on re-listen so pull-to-refresh never stacks duplicate subscriptions; added `onError` logging. |
| `vkart_delivery_partner/lib/screens/dashboard/partner_dashboard_screen.dart` | Converted `_OrderCard` to a stateful widget; routed status writes through the `OrderProvider.updateOrderStatus` guard (exactly one transition); added double-tap protection (`_updating` guard + loading spinner); removed all temporary `debugPrint` diagnostics; surfaced write failures via `SnackBar`. |
| `vkart_delivery_partner/pubspec.yaml` | Version `1.0.0+1` → `1.0.1+2` (update increment). |

**Not changed (by design):** Customer app, Admin app, authentication, checkout, order creation,
Firestore collections, UI theme, `applicationId` (`com.vkart.deliverypartner`), production signing
config, Firebase project.