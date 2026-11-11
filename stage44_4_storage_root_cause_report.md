# Stage 4.4.4 — Firebase Storage Root Cause & Fix

## Physical Device Failures

New product image:
FAIL — "Failed to add product: [firebase_storage/object-not-found] No object exists at the desired reference."

Existing product image replacement:
FAIL — "Failed to upload product image. Please try again."

Both failures reproduced on the NEW production-signed Admin APK. This is the predicted outcome of the Stage 4.4.3 BLOCKED verdict: no client-side change can create a missing server-side bucket.

## Exact Root Cause

**Cloud Storage for Firebase has never been initialized for project `vkart-1`. The default bucket `vkart-1.firebasestorage.app` does not exist server-side. Every Storage operation against it receives HTTP 404, which the `firebase_storage` SDK maps to `firebase_storage/object-not-found`.**

Evidence (three independent methods, current as of this stage):

1. **Credential-free REST probe** (the exact endpoint and bucket the device SDK uses):
   `GET https://firebasestorage.googleapis.com/v0/b/vkart-1.firebasestorage.app/o?maxResults=1`
   → `HTTP 404 {"error": {"code": 404, "message": "Not Found."}}`
   (log: `c:\vkart\logs\s444_rest_probe2.txt`). Discriminator: an existing bucket with restrictive rules returns 403; an existing bucket with public read returns 200; **a missing bucket returns 404**.
2. **Firebase CLI** (three runs today with valid credentials):
   `Error: Firebase Storage has not been set up on project 'vkart-1'. Go to https://console.firebase.google.com/project/vkart-1/storage and click 'Get Started' to set up Firebase Storage.`
   (logs: `s443_storage_deploy_log.txt`, `s443_storage_deploy_retry_log.txt`, `s444_storage_deploy_log.txt`). Note: the final log also captured a CLI token-expiry notice (`firebase login --reauth`) on one invocation — the verdict does not rest on that run, but on the credential-free REST probe plus the earlier authenticated runs.
3. **Consistency**: Firestore product CRUD (zero Storage dependency) works on-device, while every Storage call fails with a server-response-mapped error. No code-level path/URL/rules bug can produce that exact split.

## Exact Failing Operation

New product:
`await ref.putFile(image);` — line 75 of `c:\vkart\vkart_admin\lib\repositories\admin_product_repository.dart`, inside `_uploadImages()`, reached from `addProduct()` line 50. This is the FIRST and ONLY Storage call in the new-product flow. It throws `FirebaseException(object-not-found)` on the server 404. `getDownloadURL()` (line 76) is unreachable because `putFile` throws first. STEP 8 ruled out: `addProduct()` (lines 49–65) contains **no `delete()` call anywhere** — a new product has no old-image cleanup.

Existing product:
The same line 75 `putFile`, reached from `updateProduct()` line 140 — new images are uploaded FIRST, before the Firestore write (line 163) and before any old-image cleanup (line 174+). The UI's generic "Failed to upload product image" message wraps this same `object-not-found` from the upload. Old-image cleanup runs only AFTER a successful Firestore persist and already tolerates `object-not-found` — it cannot produce the observed failure.


## Firebase Storage

Project:
vkart-1

Storage initialized:
**NO** (confirmed by CLI x3 today and by the credential-free REST 404 probe)

Actual bucket (as configured — not invented):
`vkart-1.firebasestorage.app` — identical in `vkart_admin/lib/firebase_options.dart` (android `storageBucket`), `vkart_admin/android/app/google-services.json` (`project_info.storage_bucket`), and probed directly above. No stale, null, or mismatched bucket found anywhere in the Admin configuration.

Admin application ID:
com.vkart.admin (verified in `android/app/build.gradle.kts` line 32 and in the built APK via `aapt2 dump badging`)

Firebase Admin app:
1:773093189958:android:309fee3dc65d09c3fb9d47 (matches `firebase_options.dart` and `google-services.json` entry for `com.vkart.admin`)

## Storage Rules

Status: file repaired in Stage 4.4.3 (comment-syntax fix, line 14), syntactically valid and deployable, but **NOT yet deployed** — deployment is blocked by Storage initialization itself. Security model unchanged and secure (`staffCaller()` staff-caller writes + `isImageUpload()` constraint on `products/` and other admin prefixes; public read only; nothing public-writable).

STEP 6 note: rules CANNOT be the cause of these failures — a Storage rules denial produces `permission-denied`, never `object-not-found`. No rule was weakened.

## STEP 7 — Storage Reference Verification

Reference construction: `FirebaseStorage.instance.ref().child('products/{millisecondsSinceEpoch}_{originalFileName}')` (repository lines 72–74). Resulting reference: bucket = `vkart-1.firebasestorage.app` (default app's configured bucket), `fullPath` = `products/...`. The reference is well-formed; its target bucket simply does not exist server-side.

## STEP 8/9/10/11 — Ruled Out

- Wrong `delete()` call: add-flow contains no `delete()`; edit-flow deletes only after Firestore success and tolerates not-found. Ruled out.
- `getDownloadURL()`: unreachable — `putFile` throws first (sequential `await`). Ruled out.
- File/URI validity: `object-not-found` is a SERVER response code. A local file-read failure would surface as a local I/O exception class, not a Firebase 404-mapped code; the selected image also renders in the device UI (user-verified). The upload request is well-formed and reaches Firebase's servers. Ruled out.
- Android storage permissions: irrelevant — the request reaches the server; no permission changes made.

## STEP 12 — Debug Logging Decision

Temporary debug logging was deemed **not necessary**: the failing operation and its cause were established conclusively by server-side probes (CLI + credential-free REST), without a code change/rebuild/device cycle. The instruction permits logging "only if necessary". No logging added; nothing to remove before release.

## Fix Applied

**No application code change** (per STEP 14 CASE A and STEP 15). The fix is the external Firebase Console prerequisite:
1. https://console.firebase.google.com/project/vkart-1/storage → **Get Started** (creates default bucket `vkart-1.firebasestorage.app`).
2. `cd C:\vkart\vkart_customer` then `firebase deploy --only storage --project vkart-1` — deploys the already-repaired secure rules. (If the CLI reports `Your credentials are no longer valid`, run `firebase login --reauth` first.)
3. Retest the SAME production APK — no rebuild required (zero Dart code changed in Stages 4.4.3 and 4.4.4).

## Files Changed

- `c:\vkart\stage44_4_storage_root_cause_report.md` (this report). **No source files changed in Stage 4.4.4.** (Stage 4.4.3 changed only `c:\vkart\vkart_customer\storage.rules` line 14 — comment-syntax repair.)

## Analyze

`flutter analyze` (after `flutter clean` + `flutter pub get`, measured today): **0 errors** — 2 pre-existing lint notices, intentionally untouched.

## APK

Path:
`c:\vkart\vkart_admin\build\app\outputs\flutter-apk\app-release.apk` (built today, current inputs)

Size:
55,223,140 bytes (~52.7 MB)

Signing:
Production / NOT DEBUG — `apksigner` V2: `CN=VKart, OU=VKart, O=VKart, L=Hyderabad, ST=Telangana, C=IN`, SHA-256 `9a316ab1c08db6392c7698989d553e960e66d51a5fccdab5a59d4a560166ecb7`; `aapt2`: `com.vkart.admin`, versionCode 1, versionName 1.0.0; explicit exit code **APK_EXIT=0**.

## AAB

Path:
`c:\vkart\vkart_admin\build\app\outputs\bundle\release\app-release.aab` (built today, current inputs)

Size:
55,741,243 bytes (~53.2 MB)

Signing:
Production / NOT DEBUG (jar-signature `CN=VKart…`, verified). Wrapper exit code 1 = documented local toolchain gap (cmdline-tools missing / licenses unaccepted — pre-existing since Stage 4.3); artifact valid. NOT uploaded to Google Play.

## Physical Device Test

App startup:
PASS (user-verified)

Admin login:
PASS (user-verified)

Product edit (no image):
PASS (user-verified)

Product delete:
PASS (user-verified)

NEW PRODUCT + IMAGE:
FAIL (user-verified) — blocked by uninitialized Storage

EXISTING PRODUCT IMAGE REPLACEMENT:
FAIL (user-verified) — blocked by uninitialized Storage

Image persistence:
FAIL/blocked — cannot persist until the bucket exists

## Acceptance Criteria (STEP 18)

A. NEW PRODUCT + IMAGE → CREATE SUCCESS + IMAGE PERSISTS: NOT MET (blocked)
B. EXISTING PRODUCT + NEW IMAGE → UPDATE SUCCESS + NEW IMAGE PERSISTS: NOT MET (blocked)

## Final Verdict

**BLOCKED** — external Firebase Console prerequisite.

**Firebase Storage must be initialized in Firebase Console before the application can upload images.** The Dart/Flutter code is correct, ordered correctly (upload → URL → Firestore → tolerant cleanup), correctly configured (`com.vkart.admin` / `vkart-1` / `vkart-1.firebasestorage.app` / app `…309fee3dc65d09c3fb9d47`), and correctly authorized by the intended rules model. The sole failing operation is `putFile()` receiving HTTP 404 from a bucket that does not exist. No code fix can materialize a server-side bucket; creating it via Console "Get Started" and deploying the repaired rules will make the existing production APK work as-is.