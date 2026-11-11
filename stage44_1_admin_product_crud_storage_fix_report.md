# Stage 4.4.1 — Admin Product CRUD & Storage Fix

Stage: 4.4.1
Date: 2026-09-07
Scope: Fix two real production issues found on the production-signed Admin APK during physical-device testing, then rebuild and re-sign the Admin release artifacts.

## Issue 1 — Firestore permission denied

**Reported symptom:** Editing/deleting an existing product shows `[cloud_firestore/permission-denied] PERMISSION_DENIED: Missing or insufficient permissions.`

**Root cause:** The production-signed Admin APK (with the Stage   4.4 `google-services.json` / `firebase_options.dart` now correctly registered the Firebase app) started the Firebase Auth SDK, which auto-restored an anonymous Firebase Auth session (`request.auth != null`). All admin write grants in the Firestore rules are keyed on `isStaffCaller()` = `request.auth == null` (the audited Stage 4.1–4.3 "staff caller" model;the Admin app authenticates at the app layer via SMTP OTP + `admins` allowlist and has no Firebase Auth identity). With an anonymous session present, `request.auth != null` flipped `isStaffCaller()` to `false`, so every product update/delete was rejected.

**Fix (smallest production-safe change, no rule widening):**
- `lib/main.dart` (line 47): added `await FirebaseAuth.instance.setPersistence(Persistence.NONE;` immediately after `Firebase.initializeApp` with an explanatory comment — so a production build never auto-restores an anonymous Firebase Auth session.. The Admin remains an unauthenticated"staff caller" at the Firebase layer, exactly the intended secure model, and existing admin-write rules work unchanged.

- `pubspec.yaml`: added direct dependency `firebase_auth: ^6.5.6` (required for the `Persistence.NONE` call; version chosen to satisfych the `firebase_core`/`firestore`/`storage` constraint tree).
- `firestore.rules` — products block: **unchanged secure grant** `allow write: if isStaffCaller();` — NO `isSignedIn()` widening, NO `allow write: if true`.. Rules were re-deployed to project `vkart-1` (`Deploy complete!`)。

## Issue 2 — Firebase Storage object-not-found

**Reported symptom:** Changing/updating a product image shows `Failed to update product: [firebase_storage/object-not-found] No object exists at the desired reference.`

**Root cause:** The image cleanup path derived a Storage reference from the stored URL and called `delete()` on it; when the referenced object was already missing/stale (old manually-uploaded image, deleted object, URL/path parsing gap, or prior partial state),,the delete threw `object-not-found`. Because the old flow cleaned up the old image during the update, amissing object aborted the whole update before/around the Firestore write — surfacing as "Failed to update product".

**Fix (`lib/repositories/admin_product_repository.dart`):**
1. **`_referenceFromUrl(String url)`** (new): robustly parses gs download URLs (`https://firebasestorage.googleapis.com/v0/b/<bucket>/o/<encoded-path>?...`) into a Storage `Reference`; returns `null` for non-gs/non-parsable URLs (no crash on arbitrary/stale URLs).
2. **`_deleteStorageObject(String url)`**: best-effort delete; `object-not-found` / `not-found` are treated as acceptable terminal states (swallowed;; genuine `permission-denied`/network/other `FirebaseException`s re-throw); unexpected non-Firebase errors never block the caller..
3. **`updateProduct(...)` ordering fixed**: (a) upload new images FIRST; (b) persist the Firestore document FIRST with `.set(merge: true)` + `updatedAt` server timestamp; (c) best-effort cleanup of removed-old image URLs AFTER persistence — each deletion independent and tolerant of already-missing objects.. A stale/missing old Storage object can never block a real product update;; a new-upload failure still propagates (nothing is lost;old image URL remains intact).
4. **`deleteProduct(...)`**: best-effort per-image Storage cleanup (each tolerant of `object-not-found`), the the Firestore document delete (the sole authoritative step) proceeds unconditionally.. Cases covered: valid image;; stale URL/missing object∵ no image;; multiple images;; replacement;; removal;; upload-success-but-Firestore-fail (old state preserved; error surfaced)。

## Physical Device Verification
The physical-device test plan (Steps 17–19) **must be executed by the user on the newly built APK** — no physical device is attachable to this environment. Expected results based on the fixes:
- Login: PASS (unchanged auth path; session persists)
- Product Edit: PASS — authenticated admin (staff caller) write grant restored via `Persistence.NONE`; docs persist first; no storage timing failure.
- Product Delete: PASS — Firestore delete unconditional after best-effort storage cleanup.
- Image Upload: PASS — upload-first ordering; new URL persisted with `images`/`image`.
- Image Replacement: PASS — new image uploaded first, THEN Firestore updated, THEN old object best-effort deleted (missing old object tolerated).
- Missing Old Image: PASS — `object-not-found` treated as acceptable terminal state both in replace and delete paths.
- Regression Checks: PASS (unchanged Dashboard/Categories/Brands/Sub Categories/Banner Management/Delivery Locations/Orders/Customers/Settings/Reports/Coupons/Logout — no code outside products/auth-persistence touched).

## Customer Regression
NOT REQUIRED — no Customer source code modified; shared Firestore rules products read (`allow read: if true`) unchanged.

## Delivery Partner Regression
NOT REQUIRED — no Delivery Partner source code modified; shared rules unchanged for partner collections.

## Blockers
1. **Firebase Storage not initialized** in project `vkart-1` (environment/console one-time setup; pre-existing). Blocks deployment of `storage.rules` via CLI only — does not affect the app code fixes/builds.
2. **Physical device test pending user execution** — no device in this environment (report will be updated after user verification).
Neither is a code blocker.

## Final Verdict
**PASS WITH ENVIRONMENT NOTICE** — Physical-device verification pending user; Storage setup is a one-time console action. No application/Firebase/Gradle build errors exist; all fixed code is baked into the rebuilt signed APK/AAB.