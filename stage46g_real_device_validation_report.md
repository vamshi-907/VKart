# VKart — Stage 4.6G Real-Device / Internal Validation Report

**Report file:** `C:\vkart\stage46g_real_device_validation_report.md`
**Stage:** 4.6G — Final Real-Device / Internal Validation (runtime validation only)
**Report date:** 2026-09-18
**Feature freeze:** ACTIVE — no source, Firebase, auth, config, or UI changes made in this stage
**Prior stage:** 4.6F — COMPLETE, verdict PASS WITH VERIFICATION LIMITATIONS
**Artifacts under validation:** Stage 4.6F production APKs (no rebuild performed)

---

## 1. Device Information (Step 1 — Device Check)

**Command executed (single attempt, per stop-condition):**

`C:\Users\vamsi\AppData\Local\Android\Sdk\platform-tools\adb.exe devices -l`

**Result:**

```
List of devices attached

(empty — no serial numbers listed)
```

**Finding:** No physical Android device is connected to this build host. There is no emulator
target used in this stage either (out of scope — Step 1 requires a physical device only).

**Android version:** Not recordable — no device present.

**Disposition per stage instructions:** STOP runtime testing and report
**"Physical device unavailable."** No repeated adb retries were performed.

Evidence note: `adb` is NOT on PATH in this environment (bare `adb` fails with
CommandNotFoundException); the full SDK path above was used exactly once. PATH/lookup
captures: `C:\vkart\logs\s46g_path.txt`, `C:\vkart\logs\s46g_which_adb.txt` (empty = not on
PATH), `C:\vkart\logs\s46g_adb_locate.txt` (empty result set for probed install roots).

---

## 2. APK Installation Results (Steps 1-2, 4-5 install gates)

| App | APK path | Installed on device? |
|---|---|---|
| Customer (`com.vkart.customer` 1.0.0+1) | `C:\vkart\vkart_customer\build\app\outputs\apk\release\app-release.apk` | NO — Physical device unavailable. |
| Admin (`com.vkart.admin` 1.0.0+1) | `C:\vkart\vkart_admin\build\app\outputs\apk\release\app-release.apk` | NO — Physical device unavailable. |
| Partner (`com.vkart.deliverypartner` 1.0.1+2) | `C:\vkart\vkart_delivery_partner\build\app\outputs\apk\release\app-release.apk` | NO — Physical device unavailable. |

No install, uninstall, or device-side data operation was performed. No Firebase/backend data
was touched. No existing on-device state exists to preserve or corrupt.

---

## 3. Customer Runtime Results (Step 2) — NOT PERFORMED

**Physical device unavailable.**

Step 2 items 1-20 (launch, launcher icon/label, guest mode, OTP login, home screen,
delivery-location selector + selection, product details, add-to-cart, cart, checkout,
customer info, phone entry, retained location, COD checkout, order creation, Track Order,
location-dialog absence, Settings permission check) were NOT executed. Every item is
**NOT TESTED (no device)** — not pass, not fail.

---

## 4. Customer Account Deletion Results (Step 3) — NOT PERFORMED

**Physical device unavailable.**

Step 3 items 1-15 (test-account login, Profile/Account, Delete Account dialog, permanence
warning, Cancel-then-confirm flow, session clear, guest/login return, relaunch
non-restore, cart/wishlist/delivery cleanup, users-profile-document observation) were NOT
executed. No test account was used, no deletion was triggered, and **no Firestore
document belonging to any user (real or test) was read, written, or deleted** in this stage.

---

## 5. Location Permission Results (Step 6) — STATIC EVIDENCE ONLY

No runtime permission-dialog observation and no Android Settings check were possible
(no device). Static evidence carried forward from Stage 4.6F (NOT re-verified on
hardware in this stage):

- Shipped customer APK merged permissions (`aapt dump badging`, `C:\vkart\logs\F4.txt`):
  `INTERNET`, `ACCESS_NETWORK_STATE`, `READ_GSERVICES`,
  `com.vkart.customer.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` — no FINE/COARSE/BACKGROUND location.
- Source manifest (`C:\vkart\logs\zz_perm.txt`): sole declared permission is `INTERNET`.
- Dart source scan (`C:\vkart\logs\zz_perm.txt`): no Geolocator/GPS API usage; `location`
  identifiers belong to the Firestore-driven manual delivery-location feature.

Required on-device confirmations (no runtime location request; Settings shows no location
permission) remain **OPEN / NOT TESTED**.

---

## 6. Admin Runtime Results (Step 4) — NOT PERFORMED

**Physical device unavailable.**

Step 4 items 1-10 (launch, label/icon, authorized admin login, dashboard, product list,
product detail/edit access, orders, existing order info, logout, relaunch/session) were NOT
executed. No production data was viewed or modified; no test record was created.

---

## 7. Partner Runtime Results (Step 5) — NOT PERFORMED

**Physical device unavailable.**

Step 5 items 1-12 (launch, label/icon, authorized partner login, orders load, phone
display, dialer intent, address display, Maps action, ACCEPT->CONFIRMED transition,
immediate UI refresh, DELIVERED transition, shared Firestore status reflection) were NOT
executed. No test order was used; no order status was changed.

---

## 8. Order Lifecycle Results (Steps 2/5 cross-app) — NOT PERFORMED

No COD order was created, no ACCEPT/CONFIRMED/DELIVERED transition was exercised, and no
cross-app (customer -> admin -> partner) Firestore status propagation was observed.
End-to-end order lifecycle on hardware remains **OPEN / NOT TESTED**.

---

## 9. Errors / Logs Observed (Step 7) — NONE

No runtime session exists, so there are no startup crashes, auth failures, Firestore
permission errors, Storage errors, navigation crashes, deletion errors, order-creation
errors, or status-transition errors to report from this stage. Specifically: **zero new
errors introduced** (no code was changed, no app was launched). Pre-existing
informational logs from earlier stages were deliberately NOT re-opened or acted upon.

---

## 10. Known Existing Limitations (carried forward, NOT re-tested)

1. Partner app streams all orders because assignment is not securely scoped under the
   unauthenticated staff architecture (documented Stage 4.6G limitation — deliberately
   NOT addressed in this stage per instructions).
2. Stage 4.6F limitations L-1..L-6 persist unchanged, notably: no on-device install/launch
   evidence (L-1), no retained Admin 4.6C byte copy (L-2), no independent AAB
   signature re-verification in this environment (L-3), multi-client `google-services.json`
   with stale entries (L-4), residual analyzer lints (L-5), no Play upload receipt (L-6).
3. Runtime behavior on hardware (cold start, navigation, Firestore/Storage paths,
   account-deletion flow, order lifecycle) is unverified until a physical device is available.

---

## 11. Production Artifact Hash Confirmation (Step 8 — no rebuild)

No rebuild was performed. The on-disk Stage 4.6F APKs were re-hashed from their canonical
paths in this stage and match the Stage 4.6F expected values exactly (F2/fin_hashes):

| APK | Full SHA-256 (this stage = 4.6F expected) | Match |
|---|---|---|
| Customer `app-release.apk` | `e700b576cae1427c67fed6da032695b41454113d0ae2d1da394d92899828b625` | YES |
| Admin `app-release.apk` | `0fec17edb8755a1d4f7d4b1223848bc090877a9336aede0d54e77caf0660933c` | YES |
| Partner `app-release.apk` | `257ddb2f6246d77055f84e1207f5a43b0ef701f77958b6a282cdd15a1ac5e854` | YES |

Reference AAB hashes (Stage 4.6F, not installed — recorded for completeness):
Customer `8c713c2327834c6f0d9dee389e1f04264495663d19db1f8bca61dfcb8a063474`,
Admin `c3010aada479f55ec1d6d9524913fa3599df1a737c4f7a232b41f2612bcfa331`,
Partner `ed6c782945738fb804436ed1f51936919fce2118421a88601bf59571a4139fda`.

**Conclusion:** the install candidates on disk ARE the Stage 4.6F verified artifacts —
byte-identical, unmodified since verification. (Device-side hash comparison was impossible
with no device; host-side identity is established.)

---

## 12. Play Upload Status (Step 9)

**NO upload performed.** No Play release created, no testing track started, no Console
action taken — per explicit stage prohibition. AABs remain local-only.

---

## 13. Blockers

**NONE.** No release-blocking runtime defect was discovered (no runtime was possible, and
no static/integrity check failed). There is nothing requiring a source fix, a rebuild, or
a freeze exception.

---

## 14. FINAL VERDICT

**PASS WITH VERIFICATION LIMITATIONS**

Rationale: artifact integrity re-confirmed (hash-identical to Stage 4.6F), zero blockers,
zero changes made under freeze — but all real-device runtime validation (Steps 2-7) could
not be performed because no physical Android device is connected. This is the exact
no-device outcome prescribed by the stage instructions.

**Required follow-up before Play submission:** connect a physical Android device and
execute Steps 2-7 in full (customer journey + deletion flow, admin journey, partner
journey incl. ACCEPT/DELIVERED transitions, permission/Settings checks, crash/log review),
then append a runtime addendum to this report.

*End of Stage 4.6G report. STOP — no Play Console action, no source modification, no rebuild.*

---

## Appendix A. Evidence Log Index (this stage)

| Log file | Captured evidence |
|---|---|
| `C:\vkart\logs\s46g_adb.txt` | `adb devices -l` output — `List of devices attached` + empty list (no device) |
| `C:\vkart\logs\s46g_hash_cust.txt` | Customer APK SHA-256 re-hash (matches 4.6F) |
| `C:\vkart\logs\s46g_hash_admin.txt` | Admin APK SHA-256 re-hash (matches 4.6F) |
| `C:\vkart\logs\s46g_hash_part.txt` | Partner APK SHA-256 re-hash (matches 4.6F) |
| `C:\vkart\logs\s46g_path.txt` | Host PATH capture (adb-not-on-PATH context) |
| `C:\vkart\logs\s46g_which_adb.txt` | `Get-Command adb` — empty (adb not on PATH) |
| `C:\vkart\logs\s46g_adb_locate.txt` | Probed SDK roots lookup (empty result set) |
| `C:\vkart\logs\F2.txt` / `fin_hashes.txt` | Stage 4.6F expected SHA-256 values (comparison baseline) |
| `C:\vkart\logs\F4.txt` | Stage 4.6F badging (permission/label reference) |
| `C:\vkart\logs\zz_perm.txt` | Customer manifest + location-API source scan (permission reference) |

Prior report (untouched): `C:\vkart\stage46f_final_production_rebuild_report.md`.

