# Supabase Backend Setup Guide

## 1. Create Supabase Project

1. Go to [https://supabase.com](https://supabase.com)
2. Sign up or login
3. Click "New Project"
4. Configure:
   - **Organization**: Select or create one
   - **Project name**: `korean-admin-services`
   - **Database Password**: Generate a strong password (SAVE THIS!)
   - **Region**: Singapore or Northeast Asia (closest to Korea)
   - **Pricing Plan**: Free tier is fine to start

## 2. Set Up Database Tables

Once your project is created (takes ~2 minutes):

1. Go to **SQL Editor** in the Supabase dashboard
2. Click "New Query"
3. Copy and paste the entire contents of `database_schema.sql`
4. Click "Run" to execute the SQL

This creates:
- `applications` table for form submissions
- `admin_users` table for admin accounts
- `audit_trail` table for tracking changes
- `webhook_logs` table for webhook tracking
- Indexes and security policies

## 3. Get Your API Credentials

1. Go to **Settings** → **API**
2. Copy these values:
   - **Project URL**: `https://[your-project-id].supabase.co`
   - **Anon/Public Key**: For client-side code
   - **Service Role Key**: For server-side/admin operations (KEEP SECRET!)

## 4. Configure Environment Variables

Create `.env` files in both apps:

### For Main App (행정도우미)
Create `/행정도우미/.env`:
```env
SUPABASE_URL=https://[your-project-id].supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
```

### For Admin App
Create `/admin_app/.env`:
```env
SUPABASE_URL=https://[your-project-id].supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
SUPABASE_SERVICE_KEY=your_service_role_key_here
```

## 5. Update App Configuration

### Main App (행정도우미)
The app is already configured to use environment variables through:
- `/행정도우미/lib/config/env.dart`
- `/행정도우미/lib/services/supabase_service.dart`

### Admin App
Similar configuration in:
- `/admin_app/lib/config/env.dart`
- `/admin_app/lib/services/supabase_service.dart`

## 6. Test Database Connection

Run this test script in Supabase SQL Editor:
```sql
-- Test insert
INSERT INTO applications (
    form_data,
    name,
    phone,
    email,
    status
) VALUES (
    '{"step_1": "test", "step_2": "data"}',
    'Test User',
    '010-1234-5678',
    'test@example.com',
    'pending'
);

-- Check if inserted
SELECT * FROM applications;
```

## 7. Enable Realtime (Optional)

For real-time updates in admin panel:

1. Go to **Database** → **Replication**
2. Enable replication for:
   - `applications` table
   - `audit_trail` table

## 8. Set Up Authentication

1. Go to **Authentication** → **Providers**
2. Enable "Email" provider
3. Configure email templates if needed

## 9. Storage Buckets (Optional)

If you need file uploads:

1. Go to **Storage**
2. Create a new bucket called `documents`
3. Set policies as needed

## 10. Webhook Configuration (Optional)

To send notifications to Slack/Discord:

1. Go to **Database** → **Webhooks**
2. Create webhook for `applications` table
3. Set URL to your Slack/Discord webhook endpoint

## Common Issues & Solutions

### CORS Issues
- Add your domains to **Authentication** → **URL Configuration**
- Allowed URLs: `http://localhost:*`, your production domains

### Connection Errors
- Check if project is active (may pause after inactivity on free tier)
- Verify API keys are correct
- Check network/firewall settings

### RLS (Row Level Security) Issues
- Policies are already set up in the schema
- Anon users can INSERT applications
- Authenticated users can view/update

## Testing Checklist

- [ ] Database tables created successfully
- [ ] Can insert test application from SQL editor
- [ ] Environment variables configured in both apps
- [ ] Main app can submit forms
- [ ] Admin app can retrieve applications
- [ ] Admin app can update application status

## Security Notes

⚠️ **IMPORTANT**:
- Never commit `.env` files to Git
- Keep `SUPABASE_SERVICE_KEY` secret
- Use RLS policies for data protection
- Regularly rotate database passwords
- Monitor usage in Supabase dashboard

## Next Steps

After setup:
1. Test form submission from main app
2. Verify data appears in admin panel
3. Test status updates from admin panel
4. Set up production deployment
5. Configure custom domain (optional)

## Support

- Supabase Docs: https://supabase.com/docs
- Discord: https://discord.supabase.com
- GitHub Issues: For app-specific issues