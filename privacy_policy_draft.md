# VKart Privacy Policy — DRAFT (v1, for owner review)

**Status:** DRAFT — items in [SQUARE BRACKETS] must be completed by the store owner before publication.
**Effective date:** [INSERT DATE]
**Last updated:** [INSERT DATE]

This Privacy Policy explains how **VKart** ("we", "us", "our"), operated by **[OWNER / BUSINESS LEGAL NAME]**, handles information in connection with our grocery delivery service and our mobile applications:

- **VKart** (Customer app) — `com.vkart.customer`
- **VKart Admin** (store staff app) — `com.vkart.admin`
- **VKart Delivery Partner** (delivery staff app) — `com.vkart.deliverypartner`

The Admin and Delivery Partner apps are used by authorised VKart staff only.

---

## 1. Information We Collect

### Customer app
When you create an account and place orders, we collect:

| Data | Purpose |
|---|---|
| **Name** | Account creation and order fulfilment |
| **Email address** | Account creation and sign-in verification (we send a one-time code to this address); order communication |
| **Phone number** | Entered at checkout so the store or delivery partner can contact you about your delivery |
| **Delivery location** | The village/town you select from our service list, and any address details you type (house number, landmark, pincode) so we can deliver your order |
| **Order information** | Items, quantities, prices, order totals, payment method (Cash on Delivery), order status, and timestamps |
| **App activity stored in your account** | Saved cart and wishlist items, account status, last sign-in time |
| **On-device data** | Your session details, selected delivery location, and (for guests) a locally generated cart/wishlist — stored only on your device |

### What we do NOT collect
- We do **not** collect your device location (GPS). Delivery addresses are entered or chosen by you.
- We do **not** collect payment-card or other financial information — orders are **Cash on Delivery**.
- We do **not** collect photos, camera or microphone content, contacts, or advertising/analytics identifiers.
- We do **not** use third-party advertising or analytics SDKs.
- You may browse as a guest without an account; a guest cart/wishlist stays on your device.

### Staff apps (Admin / Delivery Partner)
We collect the staff member's **name and email address** to verify and maintain their sign-in. These apps process store and order information (including customer name, phone number, and delivery address on orders) strictly to operate the delivery service. The Admin app also keeps an internal **audit log** of staff actions (staff member, module, action, timestamp, before/after values).

## 2. How We Use Information
- To create and verify your account (one-time email code).
- To process, fulfil, and deliver your orders and contact you about them.
- To maintain your cart, wishlist, and order history across sessions.
- To operate the store: catalogue management, delivery-coverage management, delivery assignment and tracking.
- To keep internal records of staff actions for accountability.
- We do **not** sell your personal information, and we do not share it with third parties for advertising.

## 3. Service Providers (Third Parties)
- **Google Firebase** (Cloud Firestore, Cloud Storage — project vkart-1): hosts our app data, operated by Google LLC under Google's privacy and security terms.
- **Google email (SMTP) service**: delivers sign-in verification emails to your email address.
- **Google Maps**: used only by the Delivery Partner app — when a delivery partner starts navigation, the delivery address is opened in the Google Maps app on the partner's device.

## 4. Who Can See Your Information
- **Authorised VKart store administrators** can view your account profile (name, email, profile photo if present, account status), your orders (including your phone number and delivery address), and order totals.
- **Authorised delivery partners** can view the order details needed for delivery: your name, phone number, delivery address, items, and order amount.
- All staff access uses allowlisted email accounts verified by a one-time code.

## 5. Security
- Access to app data is controlled by Firebase security rules: product catalogue is publicly readable; your user, cart, wishlist, and order data are restricted to you and authorised VKart staff; order-status changes are restricted to a forward-only workflow with limited fields; image storage is read-only to apps and writable only by authorised staff; all other access is denied by default.
- Sign-in uses a 6-digit one-time code (valid 5 minutes, limited attempts) sent to your email; the code is kept only in app memory and is never stored in our database.
- Data is transmitted over encrypted connections (HTTPS/TLS).
- Sessions are stored only on your device.

## 6. Data Retention and Deletion
- We retain your account and order information for as long as your account is active and as needed to keep records of your orders.
- You can sign out at any time, which removes your session information from your device.
- **[OWNER ACTION REQUIRED — Account/data deletion: an in-app account-deletion flow or a web data-deletion request method must be provided and described here before Play publication. Do not publish this section until the mechanism exists.]**
- For deletion or other requests, contact us at **[CONTACT EMAIL]**.

## 7. Children's Privacy
VKart is not directed to children under the age of 13 (or the equivalent minimum age in your jurisdiction), and we do not knowingly collect their personal information.

## 8. Changes to This Policy
We may update this Privacy Policy. Changes will be posted on this page with an updated "Last updated" date.

## 9. Contact Us
**[OWNER / BUSINESS LEGAL NAME]**
[ADDRESS]
Email: [CONTACT EMAIL]
Phone: [CONTACT PHONE]
