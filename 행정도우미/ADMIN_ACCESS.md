# Admin Panel Access Guide

## How to Access the Admin Panel

### Method 1: Hidden Tap Gesture (Recommended for Mobile)
1. Open the app (you'll be on the Terms & Consent screen)
2. **Tap the header bar 5 times quickly** (within 2 seconds)
   - Tap on the "행정도우미" title area at the top
3. A password dialog will appear
4. Enter the password: `admin1234`
5. You'll be redirected to the admin panel

### Method 2: Direct URL (Web/Debug)
- Navigate directly to: `http://localhost:[port]/#/admin`
- This works when running in debug mode or web

### Method 3: Alternative URL Access
You can also add these URLs to your bookmarks:
- Admin Dashboard: `/admin`
- Webhook Settings: `/admin/webhooks`

## Admin Features
- View all submitted applications
- Export data to CSV
- Manage webhook settings
- Track submission statistics

## Security Notes
⚠️ **Important**: The current password (`admin1234`) is for development only.

For production, you should:
1. Change the password to something secure
2. Implement proper authentication (Firebase Auth, Supabase Auth, etc.)
3. Add role-based access control
4. Store passwords securely (never hardcode)
5. Add session management
6. Consider adding 2FA for admin access

## To Change the Admin Password
Edit the password check in:
```
lib/screens/terms_consent_screen.dart
Line 474: if (passwordController.text == 'admin1234')
```

## Additional Security Options
1. **IP Whitelisting**: Restrict admin access to specific IP addresses
2. **Time-based Access**: Allow admin access only during business hours
3. **Audit Logging**: Track all admin actions
4. **Biometric Authentication**: Use fingerprint/face ID on mobile

## Troubleshooting
- If the tap gesture doesn't work, make sure you're tapping quickly enough
- The tap counter resets after 2 seconds of inactivity
- If you forget the password, check this file or the source code