# Admin App Verification Guide

## Step 1: Admin App is Running
✅ The app is now running at: **http://localhost:8082**

## Step 2: Create Admin User in Supabase

1. **Open Supabase Dashboard**
   - Go to: https://app.supabase.com
   - Select your project (xgmswifetbmttyrtzjpv)

2. **Create Admin User**
   - Navigate to: **Authentication** → **Users**
   - Click **"Invite User"** or **"Add User"**
   - Enter:
     - Email: `admin@example.com`
     - Password: `Admin123!@#`
   - Click **Create**

3. **Verify Email (if required)**
   - Check if email confirmation is required
   - If yes, either:
     - Disable email confirmation temporarily in Auth settings
     - Or manually confirm the user in the dashboard

## Step 3: Setup Database (Run SQL)

1. **Open SQL Editor in Supabase**
   - Go to: **SQL Editor** in your Supabase dashboard
   
2. **Run Setup Script**
   - Copy the contents of `setup_admin_user.sql`
   - Paste and run in SQL Editor
   - This will:
     - Create RLS policies for authenticated users
     - Insert test application data
     - Create necessary views and tables

## Step 4: Test Login

1. **Open Admin App**
   - Browser should be open at: http://localhost:8082
   - You should see the login screen

2. **Login with Credentials**
   - Email: `admin@example.com`
   - Password: `Admin123!@#`
   - Click **로그인** (Login)

3. **Expected Result**
   - On successful login, you'll be redirected to the dashboard
   - If login fails, check:
     - User exists in Supabase Auth
     - Password is correct
     - Check browser console for errors (F12)

## Step 5: Verify Dashboard Access

After successful login, you should see:

1. **Dashboard Screen** (`/dashboard`)
   - Statistics cards showing:
     - Total applications (총 신청)
     - Pending (대기 중)
     - In Progress (진행 중)
     - Completed (완료)
   - Recent applications list
   - Chart showing application trends

2. **Navigation Menu**
   - 대시보드 (Dashboard)
   - 신청 관리 (Applications)
   - 웹훅 설정 (Webhooks)
   - 데이터 내보내기 (Export)

## Step 6: Verify Applications Screen

1. **Navigate to Applications**
   - Click **신청 관리** in the menu
   - Or go to: http://localhost:8082/#/applications

2. **You Should See**
   - List of test applications (김철수, 이영희, etc.)
   - Status badges (pending, in_progress, completed)
   - Action buttons for each application

3. **Test Functions**
   - **Change Status**: Click status dropdown and select new status
   - **View Details**: Click on an application row
   - **Search**: Use the search bar to filter applications

## Step 7: Troubleshooting

### If Login Fails:
```javascript
// Check browser console (F12) for errors
// Common issues:
- "Invalid login credentials" → Wrong email/password
- "User not found" → User doesn't exist in Supabase
- "Network error" → Check Supabase URL and keys
```

### If No Data Shows:
1. Check browser console for errors
2. Verify RLS policies are created (run SQL script)
3. Check Network tab for 401/403 errors
4. Ensure you're logged in (check for session)

### Check Authentication Status:
Open browser console (F12) and run:
```javascript
// Check if authenticated
localStorage.getItem('isLoggedIn')
// Should return 'true' if logged in
```

## Step 8: Verify Data Operations

1. **Test Update Operation**
   - Change an application status
   - Should update without errors
   - Check Supabase dashboard to confirm

2. **Test Real-time Updates**
   - Open Supabase dashboard
   - Modify an application directly in database
   - Admin app should reflect changes

## Success Indicators

✅ **Login works** - Can login with Supabase credentials
✅ **Dashboard loads** - Statistics and charts display
✅ **Applications list** - Test data appears in the list
✅ **CRUD operations** - Can update application status
✅ **No console errors** - Browser console is clean

## Next Steps

Once everything is verified:

1. **Create Real Admin Users**
   - Replace test credentials with secure passwords
   - Add role-based permissions if needed

2. **Configure Production**
   - Update environment variables for production
   - Set up proper CORS policies
   - Enable RLS for all tables

3. **Deploy**
   - Build for production: `flutter build web`
   - Deploy to hosting service
   - Update Supabase URLs in production

## Quick Commands

```bash
# Start admin app
cd admin_app
./run_admin.sh  # or use port 8082 if 8081 is busy

# Check logs
# Open browser console (F12) for client-side logs
# Check terminal for Flutter logs

# Restart app
# Press 'r' in terminal for hot reload
# Press 'R' for hot restart
```

## Support

If you encounter issues:
1. Check browser console for errors
2. Verify Supabase connection
3. Ensure RLS policies are configured
4. Check that test data exists in database