# Supabase Setup Guide

## 1. Create Supabase Project

1. Go to [supabase.com](https://supabase.com) and create a new project
2. Note down your project URL and anon key from Settings > API

## 2. Create Database Tables

Run these SQL commands in the Supabase SQL editor:

```sql
-- Create leads table
CREATE TABLE leads (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  form_data JSONB NOT NULL,
  contact_info JSONB NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create audit_trail table
CREATE TABLE audit_trail (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lead_id UUID REFERENCES leads(id) ON DELETE CASCADE,
  action TEXT NOT NULL,
  actor JSONB,
  changes JSONB,
  hash TEXT NOT NULL,
  prev_hash TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_leads_status ON leads(status);
CREATE INDEX idx_leads_created_at ON leads(created_at DESC);
CREATE INDEX idx_audit_trail_lead_id ON audit_trail(lead_id);
CREATE INDEX idx_audit_trail_created_at ON audit_trail(created_at);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_leads_updated_at BEFORE UPDATE ON leads
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

## 3. Set up Row Level Security (RLS)

```sql
-- Enable RLS
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_trail ENABLE ROW LEVEL SECURITY;

-- Create policies for anonymous users to insert leads
CREATE POLICY "Allow anonymous users to insert leads" ON leads
  FOR INSERT TO anon
  WITH CHECK (true);

-- Create policies for authenticated users to view and update leads
CREATE POLICY "Allow authenticated users to view leads" ON leads
  FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "Allow authenticated users to update leads" ON leads
  FOR UPDATE TO authenticated
  USING (true);

-- Audit trail policies
CREATE POLICY "Allow anonymous users to insert audit trail" ON audit_trail
  FOR INSERT TO anon
  WITH CHECK (true);

CREATE POLICY "Allow authenticated users to view audit trail" ON audit_trail
  FOR SELECT TO authenticated
  USING (true);
```

## 4. Configure Environment Variables

### Option 1: Using dart-define (Recommended for development)

```bash
flutter run --dart-define=SUPABASE_URL=your_project_url --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

### Option 2: Create a .env file (Do not commit!)

Create a `.env` file in the project root:

```
SUPABASE_URL=your_project_url
SUPABASE_ANON_KEY=your_anon_key
```

Then update your run configuration to include these variables.

### Option 3: For production builds

```bash
flutter build web --dart-define=SUPABASE_URL=your_project_url --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

## 5. Test the Integration

1. Run the app with your Supabase credentials
2. Complete the wizard flow
3. Submit the form on the contact screen
4. Check your Supabase dashboard to see the new lead entry

## 6. Setting up Webhooks (Optional)

For real-time notifications when new leads are created:

1. Go to Database > Webhooks in your Supabase dashboard
2. Create a new webhook:
   - Name: `new_lead_notification`
   - Table: `leads`
   - Events: `INSERT`
   - URL: Your webhook endpoint (e.g., Zapier, n8n, or custom endpoint)

## 7. Admin Dashboard Access

The admin dashboard will require authentication. Set up Supabase Auth:

1. Enable Email auth in Authentication > Providers
2. Create admin users in Authentication > Users
3. Update RLS policies to restrict dashboard access to authenticated users

## Security Considerations

1. Never commit your Supabase credentials to version control
2. Use environment variables for all sensitive data
3. Implement proper RLS policies for production
4. Consider using Supabase Auth for user management
5. Enable 2FA for your Supabase account

## Troubleshooting

### Connection Issues
- Check that your project URL and anon key are correct
- Ensure your Supabase project is active (not paused)
- Check network connectivity

### Permission Errors
- Review your RLS policies
- Ensure the anon key has the necessary permissions
- Check table permissions in the Supabase dashboard

### Data Not Appearing
- Check the Supabase logs for errors
- Verify the table structure matches the expected schema
- Use the Supabase SQL editor to manually query the tables