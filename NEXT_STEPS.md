# ✅ Supabase Backend Setup - Next Steps

## Current Status
✅ Database tables created successfully
✅ Test record inserted
✅ Main app configured with Supabase credentials
✅ Admin app configured (needs Service Role Key)

## 🔑 ACTION REQUIRED: Get Service Role Key

1. **Go to your Supabase Dashboard**:
   https://app.supabase.com/project/xgmswifetbmttyrtzjpv/settings/api

2. **Find "Service Role Key"** (under Project API keys)
   - It's a long string starting with `eyJ...`
   - ⚠️ Keep this secret - it has full database access!

3. **Add it to admin app**:
   Edit `/admin_app/lib/config/env.dart` and add the key:
   ```dart
   static const String supabaseServiceKey = String.fromEnvironment(
     'SUPABASE_SERVICE_KEY',
     defaultValue: 'YOUR_SERVICE_ROLE_KEY_HERE', // <-- Add here
   );
   ```

## 📱 Testing the Apps

### Test Main App (행정도우미)
```bash
cd 행정도우미
./run_with_supabase.sh
```
- Open http://localhost:8080
- Fill out the form
- Submit and check if it saves to Supabase

### Test Admin App
```bash
cd admin_app
./run_admin.sh
```
- Open http://localhost:8081
- Login with admin credentials
- Check if you can see the submitted applications

## 🔍 Verify in Supabase Dashboard

1. Go to **Table Editor**: 
   https://app.supabase.com/project/xgmswifetbmttyrtzjpv/editor

2. Check the `applications` table for:
   - Test record (already there)
   - New submissions from main app

## 🐛 Troubleshooting

### If Flutter commands don't work:
```bash
# Install Flutter properly
git clone https://github.com/flutter/flutter.git ~/flutter
export PATH="$PATH:~/flutter/bin"
flutter doctor
```

### If apps can't connect to Supabase:
1. Check if Supabase project is active (may pause after inactivity)
2. Verify API keys are correct
3. Check browser console for CORS errors

### To manually test the database:
Go to SQL Editor and run:
```sql
SELECT * FROM applications ORDER BY created_at DESC;
```

## 📈 What's Working Now

1. **Database Structure** ✅
   - applications table
   - admin_users table
   - audit_trail table
   - Statistics view

2. **Main App** ✅
   - Already configured with Supabase URL and Anon Key
   - Ready to submit forms to database

3. **Admin App** ⚠️
   - Needs Service Role Key
   - Once added, will show real-time data

## 🚀 After Adding Service Role Key

The admin app will be able to:
- View all submitted applications
- Update application status
- Delete applications
- See real-time statistics
- Track audit trail

## 📝 Quick Commands Reference

```bash
# Commit and push changes
cd "/Users/yujumyeong/coding projects/행정사"
git add .
git commit -m "Configure Supabase backend integration"
git push

# Run main app
cd 행정도우미 && ./run_with_supabase.sh

# Run admin app
cd admin_app && ./run_admin.sh

# Check database
# Go to: https://app.supabase.com/project/xgmswifetbmttyrtzjpv/editor
```

## ❓ Need Help?

If you encounter issues:
1. Check the Supabase logs: Dashboard → Logs
2. Check browser console for errors
3. Verify all credentials are correct
4. Make sure Supabase project is active