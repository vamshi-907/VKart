# Stage 4.4.5 — Admin Product Image Handling: FILE UPLOAD → IMAGE URL

## Scope

Changed ONLY product image handling in the Admin app:
FILE UPLOAD → URL INPUT → stored directly in Firestore.
No Cloudinary, no MySQL, no Firebase Storage uploads, no Blaze upgrade, no image
backend, no Base64, no binary data. No changes to auth, orders, checkout,
delivery, categories, brands, subcategories, pricing, Customer app, or Delivery
Partner app.

## 1. Files changed

- `c:\vkart\vkart_admin\lib\repositories\admin_product_repository.dart`
  - Removed `FirebaseStorage` field/imports, `_uploadImages()`, `putFile`,
    `getDownloadURL`, `_referenceFromUrl()`, `_deleteStorageObject()`, and all
    Storage delete/cleanup logic.
  - `addProduct(ProductModel)` — now only a Firestore write; stores image URLs
    directly into the existing `images` list + legacy `image` (first URL).
  - `updateProduct(ProductModel)` — pure Firestore `set(merge: true)`; image
    URLs taken as-is from the form; editing data only leaves images untouched.
  - `deleteProduct(String id)` — Firestore delete only; no Storage cleanup.
- `c:\vkart\vkart_admin\lib\providers\products_provider.dart`
  - `updateProduct(product)` / `deleteProduct(id)` simplified (removed
    `removedImageUrls`/`newImageFiles`/`imageUrls` parameters); removed
    `dart:io` import.
- `c:\vkart\vkart_admin\lib\screens\products\add_product_screen.dart`
  - Replaced image-picker UI with "Product Image URL" fields (+ add/remove,
    up to 5), live `Image.network` previews, non-blocking "preview
    unavailable" state; removed `ImagePicker`/`dart:io`; Save writes
    `images: _imageUrls` and calls `addProduct(product)` (no upload).
- `c:\vkart\vkart_admin\lib\screens\products\edit_product_screen.dart`
  - Same URL-field/preview treatment; existing product URLs pre-filled into
    editable fields; removed `_pickImages`, `_buildEditableImage`,
    `_brokenImageTile`, `_removedExistingImages`, `_newImages`; Save calls
    `updateProduct(updated)` (no upload, no cleanup); Delete calls
    `deleteProduct(id)`.
- `c:\vkart\vkart_admin\pubspec.yaml`
  - Removed `image_picker` dependency (verified unused anywhere in the codebase
    after this change). `firebase_storage` kept — still used by brand/category/
    sub-category/notification/settings repositories.

## 2. Firebase Storage code removed

Product flow now contains ZERO Firebase Storage usage. Removed from
`admin_product_repository.dart`:
- imports (`firebase_core`, `firebase_storage`, `flutter/foundation`, `dart:io`)
- `final FirebaseStorage _storage`
- `_uploadImages()` (`ref().child(...)` → `putFile` → `getDownloadURL`)
- `_referenceFromUrl()` (gs-URL → Reference parsing)
- `_deleteStorageObject()` (best-effort Storage delete)
- Storage cleanup inside `updateProduct` and `deleteProduct`

`firebase_storage` remains a pubspec dependency because the five other repos
(brand, category, sub_category, notification, settings) still upload their own
assets — those flows were explicitly out of scope.
## 3. Image URL field implementation

- Add screen: "Product Image URL" text fields (one by default, "Add Image URL"
  button, remove button per row, max 5). Each field has a small
  `Image.network` preview that shows a spinner while loading and a non-blocking
  "Image preview unavailable" tile on empty/invalid/failed URLs.
- Edit screen: identical URL rows, pre-filled with the existing product's
  stored URLs (`product.images`). At least one non-empty URL required to save.
- Preview failure NEVER blocks saving a non-empty URL.

## 4. Existing Firestore image field preserved

Reused the exact existing schema — NO new field (`imageUrl`/`productImageUrl`/
`imageLink` NOT introduced):
- `images: List<String>` — primary field, stored as-is.
- `image: String` — legacy first-URL field, kept in sync (`images.first`).
- `ProductModel` (vkart_shared) unchanged; `fromMap` already reads `images`
  with fallback to `image`.

## 5. Excel import compatibility — CONFIRMED

`c:\vkart\vkart_customer\tools\import_products.py` maps the Excel header
`"Image URL"` → Firestore `image` (string). `ProductModel.fromMap` reads
`images` first, then falls back to `image`. The Admin form writes both
`images` and `image` in exactly that representation, so Excel-imported
products and Admin-entered products are interchangeable. No import changes
needed.

## 6. Add product (code-verified)

Add Product → URL fields → Save builds `ProductModel(images: _imageUrls, ...)`
→ `addProduct(product)` → `Firestore.add(data)` with `image` =
`images.first`. No upload, no Storage call. `flutter analyze` clean + APK
build pass confirm the path compiles.

## 7. Edit product (code-verified)

Existing URLs pre-filled into editable fields; `_save` computes
`imageUrls = _imageUrls` (non-empty required); `updateProduct(updated)` writes
`images`/`image` + `updatedAt` via `set(merge: true)` — no removal tracking, no
Storage cleanup. Editing only data keeps the URL fields (and therefore the
stored images) unchanged.

## 8. Multiple images

Preserved: the existing schema is already a list; the form now shows one row
per URL with add (max 5) and remove per row. Reorder was not previously
supported by the UI, so none was added.

## 9. Customer image loading

Zero Customer changes required. `vkart_customer` already renders product
images via `Image.network` in
`c:\vkart\vkart_customer\lib\screens\...\product_image.dart` using the stored
URL, and `ProductModel.image`/`images` never changed shape. Existing product
URLs continue working.

## 10. flutter analyze

`flutter analyze` (after `flutter pub get`): **No issues found.**
(Previous pre-existing `unnecessary_import`/`unused_import` lints also
resolved by the cleanup.)

## 11. Remaining manual action

Manual physical-device verification on a REAL Android phone — I cannot execute
it in this environment. Steps:
1. Install the new release APK (`app-release.apk` below).
2. Admin → Add Product → paste a valid direct image URL → save → verify
   product appears, reopen → image URL present + preview works.
3. Edit that product → change URL → save → verify new URL stored.
4. Edit without touching URL → verify URL unchanged.
5. Add multiple URL rows → save → verify all persisted.
6. Delete product → verify delete still works.
7. Open Customer app → the product → verify image loads from the stored URL.

## Builds & verification

- `flutter analyze`: No issues found (0 errors, 0 warnings).
- Production APK:
  `c:\vkart\vkart_admin\build\app\outputs\flutter-apk\app-release.apk`
  54,939,804 bytes, built 9/8/2026 7:59 PM, `APK_EXIT=0`.
  Badging: `com.vkart.admin`, versionCode 1, versionName 1.0.0.
  Signing: Production V2 `CN=VKart...` SHA-256
  `9a316ab1c08db6392c7698989d553e960e66d51a5fccdab5a59d4a560166ecb7`
  (NOT debug-signed).
- Production AAB:
  `c:\vkart\vkart_admin\build\app\outputs\bundle\release\app-release.aab`
  55,398,075 bytes (rebuilt with the new code, 9/8/2026 8:01 PM).
  Signing: Production jar cert `CN=VKart...` SHA-256
  `9A:31:6A:B1:...:66:EC:B7`. Wrapper exit 1 is the KNOWN pre-existing
  "failed to strip debug symbols" toolchain notice (cmdline-tools/licenses),
  not an app defect. NOT uploaded to Google Play.

## Non-goals honored

No Firestore rules changed. No Storage rules changed. No migrations, no
mass update, no rewriting of existing image URLs. Existing documents work
as before.