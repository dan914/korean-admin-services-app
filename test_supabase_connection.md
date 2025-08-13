# 🧪 Test Supabase Connection

## Quick Test in Supabase Dashboard

1. **Go to SQL Editor**: 
   https://app.supabase.com/project/xgmswifetbmttyrtzjpv/sql

2. **Run this query** to see all applications:
   ```sql
   SELECT id, name, phone, status, created_at 
   FROM applications 
   ORDER BY created_at DESC;
   ```

3. **Expected Result**: You should see at least 1 test record

## Test Apps

### 🎯 Test Main App (Form Submission)
```bash
cd 행정도우미
./run_with_supabase.sh
```
- Open: http://localhost:8080
- Complete the 10-step form
- Submit and check if new record appears in Supabase

### 🎯 Test Admin App (Management Panel)
```bash
cd admin_app
./run_admin.sh
```
- Open: http://localhost:8081
- Login with: admin@example.com / admin1234
- Check if you can see submitted applications

## ✅ Success Indicators

### Main App Working:
- Form submission succeeds
- New record appears in Supabase database
- No console errors

### Admin App Working:
- Dashboard shows statistics
- Applications screen shows real data
- Can update application status
- Changes reflect in database immediately

## 🔧 If Something's Not Working

### Main App Issues:
```bash
# Check if Supabase service is working
cd 행정도우미/lib/services
# Look for supabase_service.dart file
```

### Admin App Issues:
```bash
# Make sure dependencies are installed
cd admin_app
flutter pub get
```

### Database Issues:
```sql
-- Check table exists
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public';

-- Check RLS policies
SELECT * FROM pg_policies WHERE tablename = 'applications';
```

## 📊 Expected Database Schema

Your `applications` table should have these columns:
- `id` (UUID, Primary Key)
- `form_data` (JSONB)
- `name` (VARCHAR)
- `phone` (VARCHAR)
- `email` (VARCHAR)
- `status` (VARCHAR: pending/in_progress/completed/cancelled)
- `created_at` (TIMESTAMPTZ)
- `updated_at` (TIMESTAMPTZ)

## 🎉 Next Steps After Testing

If both apps work:
1. Delete the test record
2. Submit real applications
3. Manage them through admin panel
4. Set up webhooks (optional)
5. Deploy to production