# Admin App Authentication Setup

## Problem Fixed
The admin app was not properly authenticating with Supabase, causing RLS (Row Level Security) to block database queries. The following fixes were implemented:

## Fixes Applied

### 1. Authentication Service Created
- Created `admin_app/lib/services/auth_service.dart` with proper Supabase authentication methods
- Handles sign in, sign out, session management, and auth state

### 2. SupabaseService Updated
- Added authentication checks before all database operations
- Proper error handling for PostgrestException with specific RLS error messages
- Clear error messages when user is not authenticated

### 3. Login Screen Updated
- Replaced hardcoded authentication with Supabase authentication
- Added proper error handling and user feedback
- Updated UI to reflect Supabase login requirements

## Setting Up Admin Users

### Step 1: Create Admin User in Supabase
1. Go to your Supabase Dashboard: https://app.supabase.com
2. Navigate to Authentication → Users
3. Click "Invite User" or "Create User"
4. Enter admin email and password (e.g., admin@example.com / Admin123!@#)
5. Make sure to verify the email if email confirmation is required

### Step 2: Grant Admin Permissions (Optional)
If you want to differentiate admin users from regular users:

```sql
-- Add a role column to auth.users metadata
UPDATE auth.users 
SET raw_user_meta_data = jsonb_set(
  COALESCE(raw_user_meta_data, '{}'::jsonb),
  '{role}',
  '"admin"'
)
WHERE email = 'admin@example.com';
```

### Step 3: Update RLS Policies
Make sure your RLS policies allow authenticated users to perform necessary operations:

```sql
-- Example: Allow authenticated users to SELECT from applications
CREATE POLICY "Authenticated users can view applications" 
ON applications FOR SELECT 
TO authenticated 
USING (true);

-- Example: Allow authenticated admins to UPDATE applications
CREATE POLICY "Admins can update applications" 
ON applications FOR UPDATE 
TO authenticated 
USING (auth.jwt() ->> 'user_metadata' ->> 'role' = 'admin');
```

## Running the Admin App

### Method 1: Using the run script (Recommended)
```bash
cd admin_app
./run_admin.sh
```

### Method 2: Manual Flutter run with environment variables
```bash
cd admin_app
flutter run -d chrome --web-port 8081 \
  --dart-define=SUPABASE_URL=https://xgmswifetbmttyrtzjpv.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your_anon_key_here \
  --dart-define=SUPABASE_SERVICE_KEY=your_service_key_here
```

## Testing Authentication

### Test Script
Run the test script to verify authentication is working:

```bash
cd admin_app
dart run test_auth.dart
```

### Expected Flow
1. User enters Supabase credentials on login screen
2. App authenticates with Supabase
3. Session is created and stored
4. User can access dashboard and perform operations
5. All database queries include authentication headers

## Troubleshooting

### Issue: "User not authenticated" errors
- **Solution**: Ensure you're logged in through the login screen
- Check if session exists: `AuthService().isAuthenticated`

### Issue: RLS policy errors (code 42501)
- **Solution**: Update your RLS policies to allow authenticated users
- Check current policies in Supabase Dashboard → Database → Policies

### Issue: CORS errors on web
- **Solution**: Add your local URLs to Supabase allowed URLs
- Go to Authentication → URL Configuration
- Add: `http://localhost:8081`, `http://localhost:8080`

### Issue: Environment variables not loading
- **Solution**: Use the run script or pass variables via --dart-define
- Do NOT use .env files with String.fromEnvironment

## Security Notes

1. **Never commit real credentials** to version control
2. **Use environment variables** for production deployments
3. **Implement proper RLS policies** for all tables
4. **Use service role keys carefully** - only for admin operations
5. **Rotate keys regularly** in production

## Next Steps

1. Create proper admin users in Supabase Auth
2. Test login with real credentials
3. Verify RLS policies match your security requirements
4. Consider implementing role-based access control (RBAC)
5. Set up audit logging for admin actions