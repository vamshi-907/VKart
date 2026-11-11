# Phase 8.0 – VKart Admin Email OTP Authentication

## Status: Complete ✅

## Architecture
Google Sign-In has been fully replaced with a server-side Email OTP system.

- **Client (Flutter)** only:
  - Collects Name + Email, validates format, and checks authorization for fast UI feedback.
  - Forwards requests to Cloud Functions and displays the OTP entry UI.
  - Persists the server-issued session token (never the OTP).
- **Server (Cloud Functions)** does all security-critical work:
  - Authorizes emails (only the 2 super admin emails).
  - Generates a cryptographically secure 6-digit OTP.
  - Stores only the SHA-256 hash of the OTP (never plaintext).
  - Enforces 5-minute expiry and 5-attempt / 10-minute lockout.
  - Emails the OTP via SMTP (Nodemailer) with credentials in env vars.
  - Issues and validates session tokens.

## Steps
- [x] 1. Explore existing auth architecture
- [x] 2. Add `shared_preferences` + `http` dependencies
- [x] 3. Create centralized admin auth config (`lib/config/admin_auth_config.dart`)
- [x] 4. Create Cloud Function OTP service (`functions/otp-service.js`)
- [x] 5. Create Cloud Function SMTP service (`functions/smtp-service.js`)
- [x] 6. Create Cloud Function HTTP endpoints (`functions/index.js`)
- [x] 7. Create OTP repository (`lib/repositories/admin_otp_repository.dart`)
- [x] 8. Update admin auth service (`lib/services/admin_auth_service.dart`)
- [x] 9. Update auth provider (`lib/auth/admin_auth_provider.dart`)
- [x] 10. Redesign login screen (Name + Email + Continue)
- [x] 11. Create OTP screen (6 boxes, timer, resend, paste)
- [x] 12. Update access denied screen
- [x] 13. Update splash screen + auth gate
- [x] 14. Update main.dart routes
- [x] 15. Remove unused Google Sign-In / local OTP client code
- [x] 16. Run `flutter analyze` and fix all issues (0 errors, 0 warnings)

## Deployment (Cloud Functions)
1. `cd vkart_admin/functions && npm install`
2. Configure SMTP credentials (never in Flutter):
   ```
   firebase functions:config:set \
     smtp.host="smtp.gmail.com" \
     smtp.port="587" \
     smtp.user="your-send-account@gmail.com" \
     smtp.pass="your-app-password" \
     smtp.from="VKart Admin <your-send-account@gmail.com>"
   ```
3. `firebase deploy --only functions`
4. Set the base URL in the Flutter app via `--dart-define`:
   ```
   flutter build apk --dart-define=VKART_ADMIN_FUNCTIONS_URL=https://<region>-<project>.cloudfunctions.net
   ```

## Future-Ready
To add another authorized admin email, add it to:
- `functions/otp-service.js` → `AUTHORIZED_ADMIN_EMAILS`
- `lib/config/admin_auth_config.dart` → `authorizedAdminEmails`

No login-flow code needs to change.
