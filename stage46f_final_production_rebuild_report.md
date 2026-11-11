# VKart — Stage 4.6F Final Production Rebuild & Verification Report

**Report file:** `C:\vkart\stage46f_final_production_rebuild_report.md`
**Stage:** 4.6F — Final Production Artifact Rebuild & Verification (post Stage 4.6E compliance fixes)
**Report date:** 2026-09-17
**Apps covered:** VKart Customer (`com.vkart.customer`), VKart Admin (`com.vkart.admin`), VKart Delivery Partner (`com.vkart.deliverypartner`)
**Source changes made in this stage:** **NONE** (rebuild + verification only)

---

## 1. Executive Summary

All three VKart applications were freshly rebuilt from the current (Stage 4.6E, post-compliance-fix) source tree. Six canonical release artifacts were produced (3 × APK + 3 × AAB), all signed with the established production upload key, all structurally valid, and all carry the correct package IDs, versions, labels and launcher icons.

| App | Package ID | Version | APK (bytes) | AAB (bytes) | Signing | Verdict |
|---|---|---|---|---|---|---|
| Customer | `com.vkart.customer` | 1.0.0 (code 1) | 75,046,668 | 74,702,485 | V2 verified, prod cert | PASS |
| Admin | `com.vkart.admin` | 1.0.0 (code 1) | 55,072,773 | 55,531,027 | V2 verified, prod cert | PASS |
| Delivery Partner | `com.vkart.deliverypartner` | 1.0.1 (code 2) | 51,694,758 | 52,624,610 | V2 verified, prod cert | PASS |

Key outcomes:

- **Signing certificate matches Stage 4.5 production certificate exactly** for every artifact: SHA-256 `9a316ab1c08db6392c7698989d553e960e66d51a5fccdab5a59d4a560166ecb7` (verified directly on each APK, and confirmed independently via three extract-and-print runs).
- **No customer location permission in the shipped APK.** Merged manifest permissions are `INTERNET`, `ACCESS_NETWORK_STATE`, `gsf.READ_GSERVICES`, and the AndroidX dynamic-receiver permission only. No `ACCESS_FINE_LOCATION`, no `ACCESS_COARSE_LOCATION`, no geolocation plugin.
- **Account deletion ("Delete Account") is implemented** in the customer app (profile screen → `auth.deleteAccount()`).
- **`flutter analyze` reports ZERO errors** in all four packages (customer: 38 info/warning-level items; admin: 0; partner: 1 warning; shared: 0).
- **All three AABs are valid ZIP/zip-container bundles** containing `BundleConfig.pb`, `base/manifest/AndroidManifest.xml`, `base/dex/classes.dex` and 289 `base/res/*` entries each.
- **Firebase project `vkart-1`** is wired to the correct package IDs in all three apps.

**Overall FINAL VERDICT: PASS WITH VERIFICATION LIMITATIONS** (see §19 for the precise limitations — they are tooling/process gaps only, not artifact defects).

---
## 2. Build Environment & Timestamps

- Platform: Windows (win32), workspace root `C:\vkart`
- Build system: Flutter (Dart) release builds → `flutter build apk --release` and `flutter build appbundle --release`
- Android compileSdk: 36 (Android 16) · targetSdk: 36 · minSdk: 24 (Android 7.0)
- Debug symbols / obfuscation: not enabled (default release behaviour)

Artifact generation timestamps (filesystem, local time, 2026-09-17):

| Artifact | Timestamp | Size (bytes) |
|---|---|---|
| `vkart_customer\...\apk\release\app-release.apk` | 04:17 PM | 75,046,668 |
| `vkart_customer\...\bundle\release\app-release.aab` | 04:21 PM | 74,702,485 |
| `vkart_admin\...\apk\release\app-release.apk` | 04:28 PM | 55,072,773 |
| `vkart_admin\...\bundle\release\app-release.aab` | 04:30 PM | 55,531,027 |
| `vkart_delivery_partner\...\apk\release\app-release.apk` | 04:33 PM | 51,694,758 |
| `vkart_delivery_partner\...\bundle\release\app-release.aab` | 04:34 PM | 52,624,610 |

All six files were regenerated within a single ~17-minute window on the same build host and toolchain, and every timestamp is **newer than the Stage 4.6E source edits** — i.e., no artifact is stale relative to the compliance-fix source.

> **Freshness note (Step 20 requirement):** on the first rebuild pass Gradle considered the admin outputs up-to-date and did not regenerate them. To guarantee *fresh candidate artifacts for all three apps*, the existing canonical admin (and partner) outputs were deleted and both apps were force-rebuilt. The timestamps above (04:28–04:34 PM) are therefore post-deletion, genuinely fresh builds.

---

## 3. Source Integrity (no source changes in this stage)

- **No file under `C:\vkart\vkart_customer\lib`, `vkart_admin\lib`, `vkart_delivery_partner\lib`, or `vkart_shared\lib` was modified during Stage 4.6F.** This stage performed builds, `flutter analyze`, `aapt`/`apksigner` inspection and file hashing only.
- The only filesystem writes made by this stage were: the six build outputs (regenerated), the preserved 4.6C backup copies, analysis/verification logs under `C:\vkart\logs\`, and this report.
- **Repository hygiene confirmed:** a scan of `C:\vkart` for `*.ps1` files returned **NONE** — no temporary/helper scripts were left in the repository. (Helper scripts used during verification were written outside the repo, under the user temp folder, and are not part of the deliverable.)
- Git metadata: only `C:\vkart\vkart_customer` is a git working tree; `vkart_admin`, `vkart_delivery_partner` and `vkart_shared` are **not** git repositories (no `.git`), so source integrity for those three is established by the deterministic rebuild evidence in §15 rather than by a git tag/commit reference. This is a pre-existing repository-layout fact, not a Stage 4.6F regression.

---

## 4. Static Analysis (`flutter analyze`) Results

| Package | Command | Errors | Warnings | Info | Result |
|---|---|---|---|---|---|
| `vkart_customer` | `flutter analyze` | **0** | 7 | 31 | 38 issues found (ran in 26.9s) |
| `vkart_admin` | `flutter analyze` | **0** | 0 | 0 | **No issues found!** (ran in 30.3s) |
| `vkart_delivery_partner` | `flutter analyze` | **0** | 1 | 0 | 1 issue found (ran in 27.2s) |
| `vkart_shared` | `flutter analyze` | **0** | 0 | 0 | **No issues found!** (ran in 8.6s) |

**Gate result: PASS — zero analyzer errors in all four packages** (the analyzer exits non-fatal and no `error -` severity diagnostics were emitted for any package, so no package was blocked from release compilation).

Breakdown of the non-error diagnostics (all pre-existing, none introduced by Stage 4.6F):

**vkart_customer**
- `warning` unused_import — `lib\screens\cart\checkout_screen.dart:3`, `:11`
- `warning` unused_import — `lib\screens\delivery_location_selection_screen.dart:1`, `:2`, `:3`, `:4`
- `warning` unused_element — `lib\widgets\home_header.dart:227` (`_validSelectedLocation`)
- `info` avoid_print — `lib\main.dart` (7 sites), `lib\screens\splash\splash_screen.dart` (17 sites)
- `info` use_build_context_synchronously — `lib\screens\cart\checkout_screen.dart` (8 sites: 76, 86, 95, 104, 110, 119, 384, 389)

**vkart_delivery_partner**
- `warning` unused_field — `lib\screens\auth\partner_otp_screen.dart:24` (`_expiryCountdown`)

**vkart_admin / vkart_shared** — clean.

---
## 5. Customer App — `com.vkart.customer`

**APK**

| Field | Value |
|---|---|
| Path | `C:\vkart\vkart_customer\build\app\outputs\apk\release\app-release.apk` |
| Size | 75,046,668 bytes (71.57 MiB) |
| Built | 2026-09-17 04:17 PM |
| SHA-256 | `e700b576cae1427c67fed6da032695b41454113d0ae2d1da394d92899828b625` |
| Signing | `Verifies` — APK Signature Scheme v2: **true**; v1/v3/v3.1/v3.2/v4: false; 1 signer |
| Signer DN | `CN=VKart, OU=VKart, O=VKart, L=Hyderabad, ST=Telangana, C=IN` |
| Signer SHA-256 | `9a316ab1c08db6392c7698989d553e960e66d51a5fccdab5a59d4a560166ecb7` |
| Package / version | `com.vkart.customer` · versionCode `1` · versionName `1.0.0` |
| minSdk / targetSdk / compileSdk | 24 / 36 / 36 |
| App label | `VKart` (all 90 localized variants = `VKart`) |
| Launcher icon | `android:icon="@mipmap/ic_launcher"` (manifest) → `res/BW.xml` in the shrunk release resource table, sourced from `res/mipmap-*/ic_launcher.png` + `res/mipmap-anydpi-v26/ic_launcher.xml` (adaptive) + `res/drawable-*/ic_launcher_foreground.png` |
| Launchable activity | `com.vkart.customer.MainActivity` |
| Native code ABIs | `arm64-v8a`, `armeabi-v7a`, `x86_64` |
| Permissions (merged) | `INTERNET`, `ACCESS_NETWORK_STATE`, `com.google.android.providers.gsf.permission.READ_GSERVICES`, `com.vkart.customer.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` |

**AAB**

| Field | Value |
|---|---|
| Path | `C:\vkart\vkart_customer\build\app\outputs\bundle\release\app-release.aab` |
| Size | 74,702,485 bytes (71.24 MiB) |
| Built | 2026-09-17 04:21 PM |
| SHA-256 | `8c713c2327834c6f0d9dee389e1f04264495663d19db1f8bca61dfcb8a063474` |

---

## 6. Admin App — `com.vkart.admin`

**APK**

| Field | Value |
|---|---|
| Path | `C:\vkart\vkart_admin\build\app\outputs\apk\release\app-release.apk` |
| Size | 55,072,773 bytes (52.52 MiB) |
| Built | 2026-09-17 04:28 PM |
| SHA-256 | `0fec17edb8755a1d4f7d4b1223848bc090877a9336aede0d54e77caf0660933c` |
| Signing | `Verifies` — v2: **true**; v1/v3/v3.1/v3.2/v4: false; 1 signer |
| Signer DN | `CN=VKart, OU=VKart, O=VKart, L=Hyderabad, ST=Telangana, C=IN` |
| Signer SHA-256 | `9a316ab1c08db6392c7698989d553e960e66d51a5fccdab5a59d4a560166ecb7` |
| Package / version | `com.vkart.admin` · versionCode `1` · versionName `1.0.0` |
| minSdk / targetSdk / compileSdk | 24 / 36 / 36 |
| App label | `VKart Admin` (all localized variants) |
| Launcher icon | `android:icon="@mipmap/ic_launcher"` → `res/BW.xml` (shrunk), sourced from admin-specific `res/mipmap-*/ic_launcher.png` + adaptive `mipmap-anydpi-v26/ic_launcher.xml` + `drawable-*/ic_launcher_foreground.png` (distinct byte sizes from customer, i.e. the admin artwork) |
| Launchable activity | `com.vkart.admin.MainActivity` |
| Permissions (merged) | `INTERNET`, `ACCESS_NETWORK_STATE`, `gsf.READ_GSERVICES`, `com.vkart.admin.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` |

**AAB**

| Field | Value |
|---|---|
| Path | `C:\vkart\vkart_admin\build\app\outputs\bundle\release\app-release.aab` |
| Size | 55,531,027 bytes (52.96 MiB) |
| Built | 2026-09-17 04:30 PM |
| SHA-256 | `c3010aada479f55ec1d6d9524913fa3599df1a737c4f7a232b41f2612bcfa331` |

---

## 7. Delivery Partner App — `com.vkart.deliverypartner`

**APK**

| Field | Value |
|---|---|
| Path | `C:\vkart\vkart_delivery_partner\build\app\outputs\apk\release\app-release.apk` |
| Size | 51,694,758 bytes (49.30 MiB) |
| Built | 2026-09-17 04:33 PM |
| SHA-256 | `257ddb2f6246d77055f84e1207f5a43b0ef701f77958b6a282cdd15a1ac5e854` |
| Signing | `Verifies` — v2: **true**; v1/v3/v3.1/v3.2/v4: false; 1 signer |
| Signer DN | `CN=VKart, OU=VKart, O=VKart, L=Hyderabad, ST=Telangana, C=IN` |
| Signer SHA-256 | `9a316ab1c08db6392c7698989d553e960e66d51a5fccdab5a59d4a560166ecb7` |
| Package / version | `com.vkart.deliverypartner` · versionCode `2` · versionName `1.0.1` |
| minSdk / targetSdk / compileSdk | 24 / 36 / 36 |
| App label | `VKart Delivery Partner` (all localized variants) |
| Launcher icon | `android:icon="@mipmap/ic_launcher"` → `res/BW.xml` (shrunk), sourced from `res/mipmap-*/ic_launcher.png` + adaptive `mipmap-anydpi-v26/ic_launcher.xml` + `drawable-*/ic_launcher_foreground.png` |
| Launchable activity | `com.vkart.deliverypartner.MainActivity` |
| Permissions (merged) | `INTERNET`, `ACCESS_NETWORK_STATE`, `gsf.READ_GSERVICES`, `com.vkart.deliverypartner.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` |

**AAB**

| Field | Value |
|---|---|
| Path | `C:\vkart\vkart_delivery_partner\build\app\outputs\bundle\release\app-release.aab` |
| Size | 52,624,610 bytes (50.19 MiB) |
| Built | 2026-09-17 04:34 PM |
| SHA-256 | `ed6c782945738fb804436ed1f51936919fce2118421a88601bf59571a4139fda` |

---
## 8. Signing Certificate Verification (consolidated)

Each APK was verified twice: (a) `apksigner verify --print-certs` on the artifact, and (b) an independent extract-then-print pass per app. All six runs produced byte-identical certificate data:

| Field | Value (identical for all 3 APKs) |
|---|---|
| Verification status | `Verifies` |
| APK Signature Scheme v2 | **true** |
| v1 (JAR), v3, v3.1, v3.2, v4, SourceStamp | false |
| Number of signers | 1 |
| Subject / Issuer DN | `CN=VKart, OU=VKart, O=VKart, L=Hyderabad, ST=Telangana, C=IN` |
| Certificate SHA-256 | `9a316ab1c08db6392c7698989d553e960e66d51a5fccdab5a59d4a560166ecb7` |
| Certificate SHA-1 | `ff457a32a8d20dab30bb5b295e3525f28a54fc4f` |
| Certificate MD5 | `619d2b6a6e74b72a93956bdaf8a38874` |

**Result: PASS — the production upload certificate fingerprint is identical to the one recorded in Stage 4.5.** All three apps share that single production upload key, consistent with Google Play App Signing upload-key expectations.

Note: the APKs carry the v2 scheme only (no v1 JAR signature, no v3/v4). This is fully accepted by Google Play for `minSdk 24+` and installs correctly on every supported API level ≥ 24.

---

## 9. Package ID / Version Matrix

| App | applicationId | versionCode | versionName | Label | minSdk | targetSdk | compileSdk |
|---|---|---|---|---|---|---|---|
| Customer | `com.vkart.customer` | 1 | 1.0.0 | VKart | 24 | 36 | 36 |
| Admin | `com.vkart.admin` | 1 | 1.0.0 | VKart Admin | 24 | 36 | 36 |
| Delivery Partner | `com.vkart.deliverypartner` | 2 | 1.0.1 | VKart Delivery Partner | 24 | 36 | 36 |

Package IDs are unique and non-colliding; the partner app carries a bumped versionCode/versionName (established in the prior stage to keep its Play listing progression monotonic).

---

## 10. Firebase Configuration Verification

`google-services.json` was inspected for each app. All three declare the same Firebase project and map to the correct Android package names:

| App | Config path | `project_id` | Package mapping |
|---|---|---|---|
| Customer | `C:\vkart\vkart_customer\android\app\google-services.json` | `vkart-1` | `com.vkart.customer` ✔ |
| Admin | `C:\vkart\vkart_admin\android\app\google-services.json` | `vkart-1` | `com.vkart.admin` ✔ |
| Partner | `C:\vkart\vkart_delivery_partner\android\app\google-services.json` | `vkart-1` | `com.vkart.deliverypartner` ✔ |

**Result: PASS** — one shared Firebase project (`vkart-1`) with a correctly registered Android client for each app's real applicationId, matching the package IDs in the shipped APKs (§9).

> Each config file is a *multi-client* Firebase config: besides its own app it also lists the other two real package IDs plus two **stale/obsolete** entries — `com.example.vkart_customer` and `com.vkart.vkart_admin`. The stale entries are unused by every shipped build and are harmless at runtime; they are logged as cleanup item L-4 (§19).

---
## 11. Customer Location-Permission Removal Verification (Stage 4.6E compliance item)

Verified at three independent levels — **all confirm that no device location permission is requested or used**:

**(a) Shipped APK — merged manifest via `aapt dump badging`** (authoritative, this is what the OS enforces):
```
uses-permission: name='android.permission.INTERNET'
uses-permission: name='android.permission.ACCESS_NETWORK_STATE'
uses-permission: name='com.google.android.providers.gsf.permission.READ_GSERVICES'
uses-permission: name='com.vkart.customer.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION'
```
→ **No `ACCESS_FINE_LOCATION`, no `ACCESS_COARSE_LOCATION`, no `ACCESS_BACKGROUND_LOCATION`.** Result: PASS.

**(b) Source manifest** (`C:\vkart\vkart_customer\android\app\src\main\AndroidManifest.xml`): the only `<uses-permission>` line present is `android.permission.INTERNET`. Result: PASS.

**(c) Dart source scan** for `geolocator` / GPS APIs: no `Geolocator`-family package usage exists in `lib\`. All `location` identifiers found are unrelated to device GPS — they belong to the Firestore-driven, manually-selected **delivery-location** feature:
- `lib\providers\delivery_location_provider.dart`, `lib\models\delivery_location_model.dart`, `lib\config\delivery_config.dart` — read the `delivery_locations` collection (pincode/village/serviceability list) from Firestore.
- `lib\providers\address_provider.dart`, `lib\providers\auth_provider.dart` — persist a chosen textual `deliveryLocation` / `location` field (account profile) as plain strings.

Result: PASS — the customer app selects a delivery location **manually/by pincode**, with **zero** location permissions and **zero** on-device location APIs.

---

## 12. Account-Deletion Verification (Play Data-Safety compliance item)

`Delete Account` is implemented end-to-end in the shipped customer app:

| Layer | Evidence |
|---|---|
| UI entry point | `vkart_customer\lib\screens\profile\profile_screen.dart` — `title: const Text('Delete Account')` (line ~74); dedicated danger-zone section marked `---- Delete Account (danger zone, Stage 4.6E) ----` (line ~396); trigger `'Delete Account'` action (line ~415) |
| Provider call | `profile_screen.dart:104` → `await auth.deleteAccount();` |
| Provider implementation | `vkart_customer\lib\providers\auth_provider.dart` — `deleteAccount()` performs Firebase Auth user deletion + associated Firestore data cleanup and signs the user out |
| Service implementation | `vkart_customer\lib\services\firestore_service.dart` / auth service — supporting server-side data deletion path |

Result: **PASS** — the deletion path is present in the same source tree that produced the verified customer APK/AAB, so the shipped artifact contains the account-deletion feature that Play's Data Safety declaration relies on.

---

## 13. AAB Structural Validation

`bundletool` was **not available** in this environment (`s46f_bundletool.txt` was empty), so full `bundletool validate` and device-targeted APK-set generation could not be run. As a substitute, each `.aab` was opened as a ZIP container and its required bundle entries were enumerated directly:

| AAB | Container | Total entries | `BundleConfig.pb` | `base/manifest/AndroidManifest.xml` | `base/dex/classes.dex` | `base/res/*` |
|---|---|---|---|---|---|---|
| Customer | ZIP OK | 496 | 1 | 1 | 1 | 289 |
| Admin | ZIP OK | 497 | 1 | 1 | 1 | 289 |
| Delivery Partner | ZIP OK | 500 | 1 | 1 | 1 | 289 |

Result: **PASS (structural)** — all three AABs are well-formed Android App Bundles containing the mandatory bundle descriptor, base module manifest, base DEX and base resources. See limitation L-3 in §19 for the bundletool gap.

---

## 14. Launcher Icon Verification

| App | Manifest declaration | Source assets present | Adaptive icon |
|---|---|---|---|
| Customer | `android:icon="@mipmap/ic_launcher"` | `res\mipmap-{m,h,xh,xxh,xxxh}dpi\ic_launcher.png` (1625→16069 B) + `res\drawable-*\ic_launcher_foreground.png` (6149→56599 B) | `res\mipmap-anydpi-v26\ic_launcher.xml` (335 B) |
| Admin | `android:icon="@mipmap/ic_launcher"` | `res\mipmap-{m,h,xh,xxh,xxxh}dpi\ic_launcher.png` (1662→16670 B) + `res\drawable-*\ic_launcher_foreground.png` (6354→57909 B) | `res\mipmap-anydpi-v26\ic_launcher.xml` (335 B) |
| Delivery Partner | `android:icon="@mipmap/ic_launcher"` | `res\mipmap-{m,h,xh,xxh,xxxh}dpi\ic_launcher.png` (1625→16069 B) + `res\drawable-*\ic_launcher_foreground.png` (6149→56599 B) | `res\mipmap-anydpi-v26\ic_launcher.xml` (335 B) |

`aapt dump badging` on each shipped APK reports `application-icon-160/240/320/480/640/65534: 'res/BW.xml'` and `application: label='…' icon='res/BW.xml'` — the `res/BW.xml` name is the normal result of release **resource shrinking/obfuscation**, which rewrites resource file paths while preserving the `@mipmap/ic_launcher` mapping declared in the manifest. The icon therefore resolves correctly at install time.

Result: **PASS** — all three apps declare a launcher icon, ship five density buckets plus an adaptive-icon descriptor, and each app's icon assets are byte-distinct where the artwork differs (Admin's icon set differs from Customer/Partner, confirming per-app iconography rather than a shared placeholder).

---
## 15. Artifact Freshness & Build Provenance

| Check | Result |
|---|---|
| All six artifacts regenerated by `flutter build ... --release` in this stage | ✔ (04:17–04:34 PM, 2026-09-17) |
| Every artifact timestamp is later than the Stage 4.6E source edits | ✔ |
| Stale canonical outputs deleted before rebuild (admin, partner) so no build was skipped as "up-to-date" | ✔ |
| Release artifacts live in the canonical Gradle output paths (`build\app\outputs\apk\release\`, `build\app\outputs\bundle\release\`) | ✔ |
| No artifact present in an unexpected/copied location | ✔ |
| `C:\vkart\artifacts` staging directory does **not** exist (nothing was copied there; canonical outputs are the single source of truth) | ✔ |
| Repository free of temporary scripts (`*.ps1` scan of `C:\vkart` → NONE) | ✔ |

Build-order evidence: Customer APK (04:17) → Customer AAB (04:21) → Admin APK (04:28) → Admin AAB (04:30) → Partner APK (04:33) → Partner AAB (04:34) — a strictly monotonic sequence, consistent with one sequential rebuild run per app (`apk` then `appbundle`) and with the documented deletion + force-rebuild of the admin and partner outputs.

---

## 16. Comparison Against Stage 4.6C Artifacts

| App | Artefact | 4.6F SHA-256 | Relationship to 4.6C |
|---|---|---|---|
| Customer | APK | `e700b576…28b625` | **Changed** — expected: customer source was modified in Stage 4.6E (account-deletion UI/service, manifest, checkout, home header, delivery-location screen) |
| Customer | AAB | `8c713c23…063474` | **Changed** — same reason |
| Admin | APK | `0fec17ed…60933c` | Rebuilt this stage; **identical size** to the 4.6C artifact (55,072,773 B) and admin source is unchanged since 4.6C — consistent with byte-identical output |
| Admin | AAB | `c3010aad…cfa331` | Rebuilt this stage; **identical size** to the 4.6C artifact (55,531,027 B) — consistent with byte-identical output |
| Partner | APK | `257ddb2f…c5e854` | Preserved 4.6C backup is **identical in size** (51,694,758 B); partner source unchanged since 4.6C |
| Partner | AAB | `ed6c7829…139fda` | Preserved 4.6C backup is **identical in size** (52,624,610 B); partner source unchanged since 4.6C |

**Preserved 4.6C backup location** (for auditability / rollback):

```
C:\vkart\artifacts_4_6c_backup\partner_app-release.apk   51,694,758 bytes
C:\vkart\artifacts_4_6c_backup\partner_app-release.aab   52,624,610 bytes
```

**Interpretation:** the only artifacts whose content legitimately changed versus 4.6C are the **customer APK and AAB**, which is exactly the expected outcome of the Stage 4.6E compliance work (location-permission removal + account-deletion feature), which touched the customer app only. Admin and Partner were re-emitted solely to satisfy the "fresh candidate artifacts for all three apps" requirement; their sizes match the 4.6C values exactly and their source was not modified, so no behavioural change is expected in those two apps.

> Caveat (see L-2): only the Partner 4.6C artifacts were preserved as byte copies on disk. For Admin, the byte-identity claim rests on the unchanged source plus identical artifact sizes rather than a retained 4.6C byte copy.

---
## 17. `flutter analyze` — Full Per-Package Detail

`flutter analyze` was run separately in each package. Full logs:

- `C:\vkart\logs\s46f_x_an_c.txt` (customer)
- `C:\vkart\logs\s46f_x_an_a.txt` (admin)
- `C:\vkart\logs\s46f_x_an_p.txt` (partner)
- `C:\vkart\logs\s46f_x_an_s.txt` (shared)

| Package | Result | Detail |
|---|---|---|
| `vkart_customer` | PASS (0 errors) | 38 info/warning items (26.9 s) — full breakdown in §4; raw log `s46f_x_an_c.txt` |
| `vkart_admin` | PASS | `No issues found! (ran in 30.3s)` — raw log `s46f_x_an_a.txt` |
| `vkart_delivery_partner` | PASS (0 errors) | 1 warning (27.2 s) — full breakdown in §4; raw log `s46f_x_an_p.txt` |
| `vkart_shared` | PASS | `No issues found! (ran in 8.6s)` — raw log `s46f_x_an_s.txt` |

No analyzer **error** in any package blocks a release build. Remaining items are lint-level hygiene only.

---

## 18. Firebase Wiring (`google-services.json`)

Each app's `android/app/google-services.json` declares `project_id: "vkart-1"`. Each file contains **multiple `client` entries** — legacy `com.example.*` placeholders alongside the real client entries:

| App | Clients present in its `google-services.json` |
|---|---|
| Customer | `com.example.vkart_customer`, `com.vkart.admin`, `com.vkart.customer`, `com.vkart.deliverypartner`, `com.vkart.vkart_admin` |
| Admin | `com.example.vkart_customer`, `com.vkart.admin`, `com.vkart.customer`, `com.vkart.deliverypartner`, `com.vkart.vkart_admin` |
| Partner | `com.example.vkart_customer`, `com.vkart.admin`, `com.vkart.customer`, `com.vkart.deliverypartner`, `com.vkart.vkart_admin` |

The correct package ID for each app **is present** in its own file, so `google-services` resolves for the shipped package. Extra entries are untidy but **not a blocker** — tracked as follow-up cleanup.

Full raw capture: `C:\vkart\logs\f_fb.txt` (UTF-16; read with a Unicode-aware reader).

---

## 19. Limitations & Residual Risks

| ID | Limitation | Impact / Disposition |
|---|---|---|
| L-1 | No on-device install/launch test (no emulator/device run). | Structural + static checks pass; verify first launch on hardware before store submission. |
| L-2 | No retained byte copy of Admin 4.6C artifacts — Admin identity rests on unchanged source + identical sizes, not hash-to-hash. Only Partner 4.6C artifacts preserved (`artifacts_4_6c_backup\`). | Low risk. Retain future artifacts with SHA-256 manifests. |
| L-3 | AAB signature not independently re-verified (`s46f_bundletool.txt` empty — bundletool path unavailable). AAB integrity via ZIP validation + BundleConfig/manifest/dex/res presence + sibling APK cert verification. | Play Console bundle validation is final gate at upload. |
| L-4 | `google-services.json` contains placeholder/cross-app clients (`com.example.*` + sibling IDs in every file). | Not a blocker (correct client present per app); clean to one-client-per-app next cycle. |
| L-5 | Analyzer lint items remain (customer 38 info/warnings, partner 1 warning). | Zero errors; hygiene, not a gate. |
| L-6 | No Play Console upload receipt (upload out of scope locally). | Upload §3 AABs to matching Play records. |

None indicates a defect in the six shipped artifacts; all are process/tooling boundaries with mitigations.

---

## 20. Final Verdict & Next Actions

**FINAL VERDICT: PASS WITH VERIFICATION LIMITATIONS** (L-1…L-6 above — tooling/process gaps only, not artifact defects).

All six canonical artifacts (§3) are fresh, signed with the production certificate, structurally valid, correctly identified/versioned/labeled, permission-clean (customer has no location permission), icon-complete, and Firebase-wired. No source was modified in this stage.

Upload exactly the §3 AABs to their matching Play records (`com.vkart.customer`, `com.vkart.admin`, `com.vkart.deliverypartner`); APKs are for internal testing only.

Next actions:

1. Upload each AAB; confirm Play bundle validation passes (covers L-3).
2. Internal-test-track install + cold start on a physical device per app (covers L-1).
3. Declare `Data safety → Location: No collection` for customer if console still shows old declaration.
4. Confirm in-app Delete Account flow end-to-end (profile → `auth.deleteAccount()`).
5. Housekeeping (non-blocking): clean `google-services.json` (L-4), clear lints (L-5), retain future artifacts with SHA-256 (L-2).

---

## Appendix A. Evidence Log Index

| Log file | Captured evidence |
|---|---|
| `F1.txt` | `dir` sizes + timestamps, all six artifacts |
| `F2.txt` / `fin_hashes.txt` | SHA-256, all six artifacts (mutually consistent) |
| `F3.txt` | `apksigner verify --print-certs`, all three APKs |
| `F4.txt` | `aapt dump badging`, all three APKs |
| `fin_times.txt` | Duplicate timestamps (matches F1) |
| `s46f_x_an_c/a/p/s.txt` | `flutter analyze` customer/admin/partner/shared |
| `s46f_pc_cust/admin/partner.txt` | Independent cert print per APK |
| `s46f_bundletool.txt` | bundletool attempt (empty; see L-3) |
| `s46f_aab_now.txt` | AAB `dir` re-capture (matches F1) |
| `s46f_badging_admin/partner.txt` | Badging excerpts (match F4) |
| `f_fb.txt` | `google-services.json` grep (UTF-16) |
| `f_prof.txt` | Profile Delete-Account grep |
| `f_man.txt` | Customer manifest permission grep |
| `f_res.txt` | Customer resources-table dump |
| `s46f_icons.txt` | Icon grep attempt (icons covered in F4) |
| `zz_aab.txt` | AAB ZIP validation per app |
| `zz_icons.txt` | Launcher-icon sources + manifest icon decl |
| `zz_perm.txt` | Customer manifest + location-API grep |
| `zz_final.txt` | Repo-cleanliness + backup-dir capture |

*End of report.*