# Stage 4.4 — Production Signing & Release Configuration

**Date:** 2026-09-06 · **Flutter 3.44.3 stable · Dart 3.12.2 · Windows 11**
**Scope:** Production application IDs, dedicated Firebase Android apps, production keystore/release signing, clean builds, signature verification.

---

## 1. Application IDs

| App | Production Application ID | Previous ID |
|-----|--------------------------|-------------|
| Customer | `com.vkart.customer` | `com.example.vkart_customer` |
| Admin | `com.vkart.admin` | `com.vkart.vkart_admin` |
| Delivery Partner | `com.vkart.deliverypartner` | `com.example.vkart_delivery_partner` |

All three IDs are unique and use the `com.vkart.*` production namespace. No `com.example.*` IDs remain.

## 2. Firebase Mapping

All three apps share the same Firebase backend project **vkart-1** (project number `773093189958`), each with its own dedicated Android app:

| App | Firebase Project | Firebase Android App ID | Package Match |
|-----|-----------------|------------------------|---------------|
| Customer | vkart-1 | `1:773093189958:android:f6c20f579e158afcfb9d47` | `com.vkart.customer` ✅ |
| Admin | vkart-1 | `1:773093189958:android:309fee3dc65d09c3fb9d47` | `com.vkart.admin` ✅ |
| Delivery Partner | vkart-1 | `1:773093189958:android:f7324fb03380b605fb9d47` | `com.vkart.deliverypartner` ✅ |

**Delivery Partner now has its own dedicated Firebase Android app** (previously it reused the admin app ID `...bb4df8f2...`). No cross-app Firebase mapping remains.

Configuration status: **PASS** — `google-services.json` and `firebase_options.dart` updated for all three apps; `google-services` Gradle plugin applied to all three (including the partner app, which previously had none).

## 3. Version

| App | versionName | versionCode |
|-----|-------------|-------------|
| Customer | 1.0.0 | 1 |
| Admin | 1.0.0 | 1 |
| Delivery Partner | 1.0.0 | 1 |

All three apps: `version: 1.0.0+1` (unchanged; valid for first production release).

## 4. Signing Configuration

A single production upload keystore is shared across all three apps:

- **Keystore:** `C:\vkart\keystore\vkart-release.jks` (JKS, alias `vkart`, RSA 4096, SHA256withRSA, valid until 2054)
- **key.properties:** configured in each app's `android/key.properties` (gitignored)
- **Signing config:** `signingConfigs { create("release") { ... } }` reading from `key.properties`; release build uses it with **no debug fallback**

| App | Status |
|-----|--------|
| Customer | PASS |
| Admin | PASS |
| Delivery Partner | PASS |

Passwords are NOT documented in this report.

## 5. APK Builds

`flutter build apk --release` — all three exited 0:

| App | Exit | Artifact | Size |
|-----|------|----------|------|
| Customer | 0 | `vkart_customer/build/app/outputs/flutter-apk/app-release.apk` | 71.5 MB |
| Admin | 0 | `vkart_admin/build/app/outputs/flutter-apk/app-release.apk` | 52.2 MB |
| Delivery Partner | 0 | `vkart_delivery_partner/build/app/outputs/flutter-apk/app-release.apk` | 49.2 MB |

## 6. AAB Builds

`flutter build appbundle --release` — all three exited 0 (Play Store production artifacts):

| App | Exit | Artifact | Size |
|-----|------|----------|------|
| Customer | 0 | `vkart_customer/build/app/outputs/bundle/release/app-release.aab` | 71.2 MB |
| Admin | 0 | `vkart_admin/build/app/outputs/bundle/release/app-release.aab` | 52.0 MB |
| Delivery Partner | 0 | `vkart_delivery_partner/build/app/outputs/bundle/release/app-release.aab` | 50.1 MB |

## 7. Signature Verification

Verified with `apksigner` (APKs) and `jarsigner` (AABs). All six artifacts are signed with the **same production certificate** and are **NOT debug-signed**:

- **Certificate DN:** `CN=VKart, OU=VKart, O=VKart, L=Hyderabad, ST=Telangana, C=IN`
- **SHA-256 fingerprint:** `9A:31:6A:B1:C0:8D:B6:39:2C:76:98:98:9D:55:3E:96:0E:66:D5:1A:5F:CC:DA:B5:A5:9D:4A:56:01:66:EC:B7`
- **Algorithm:** SHA256withRSA, 4096-bit key
- **Valid:** 2026-09-05 → 2054-01-21

| App | APK signed | AAB signed | Not debug |
|-----|-----------|-----------|-----------|
| Customer | PASS | PASS | PASS |
| Admin | PASS | PASS | PASS |
| Delivery Partner | PASS | PASS | PASS |

## 8. Security

- `key.properties` — gitignored (present in each `android/.gitignore`)
- `*.jks` / `*.keystore` — gitignored
- `keystore/` directory — gitignored (root `.gitignore`)
- Signing passwords — **not exposed** in report, terminal, or source
- No private keys committed
- SMTP credentials (`lib/config/smtp_config.dart`) — already gitignored (pre-existing)
- Service account / Firebase admin credentials — not present in workspace
- **Workspace is NOT a git repository** (no `.git`); root `.gitignore` added proactively so secrets are excluded when version control is initialized

## 9. Analyze

`flutter analyze` after configuration changes — **0 errors** in all three apps:

| App | Result |
|-----|--------|
| Customer | 0 errors (38 pre-existing info/warnings unrelated to signing) |
| Admin | 0 errors (No issues found) |
| Delivery Partner | 0 errors (1 pre-existing warning: unused `_expiryCountdown` field) |

No new analyze issues introduced by Stage 4.4 changes.

## 10. Environment Notices

- **AAB "strip debug symbols" warning** appears on every AAB build. This is an **environment/toolchain notice**, not a build failure — `flutter doctor` shows the Android toolchain needs `cmdline-tools` and accepted SDK licenses. All AAB builds still exit 0 and produce valid, signed artifacts. Fix is environment-side (install cmdline-tools + `flutter doctor --android-licenses`), recommended before Play publishing.
- **KGP advisory** (`firebase_storage` applies Kotlin Gradle Plugin) — informational only; builds succeed.
- These do not block production signing.

## 11. Changes Made

Production-signing and production-configuration changes only:

1. Registered 3 dedicated Firebase Android apps in project `vkart-1` via `firebase apps:create android`.
2. Downloaded each app's `google-services.json` via `firebase apps:sdkconfig`.
3. Created production keystore `C:\vkart\keystore\vkart-release.jks` (alias `vkart`).
4. Created `android/key.properties` for each app (gitignored).
5. Updated each `android/app/build.gradle.kts`: `namespace`, `applicationId` → production IDs; added `signingConfigs.release` + release `signingConfig`; added `key.properties` loading.
6. Moved each `MainActivity.kt` to the new package directory + updated `package` declaration.
7. Added `com.google.gms.google-services` plugin to the partner app's `build.gradle.kts` + `settings.gradle.kts`.
8. Updated `firebase_options.dart` Android `appId` in all three apps to the dedicated Firebase app IDs.
9. Added root `.gitignore` with secret-protection rules.

No application features, business logic, UI, checkout, order status, delivery pricing, or authentication flow were changed.

## 12. Final Verdict

**PASS WITH ENVIRONMENT NOTICE**

All application checks pass. Production signing is configured and verified for all three apps. The only outstanding item is an environment/toolchain notice (AAB symbol-stripping / cmdline-tools + SDK licenses) that should be resolved before Play Store publishing but does not block signing or artifact production.

---

**Artifacts ready for Play Store (do not upload yet — Stage 4.5/4.6):**
- `vkart_customer/build/app/outputs/flutter-apk/app-release.apk`
- `vkart_customer/build/app/outputs/bundle/release/app-release.aab`
- `vkart_admin/build/app/outputs/flutter-apk/app-release.apk`
- `vkart_admin/build/app/outputs/bundle/release/app-release.aab`
- `vkart_delivery_partner/build/app/outputs/flutter-apk/app-release.apk`
- `vkart_delivery_partner/build/app/outputs/bundle/release/app-release.aab`