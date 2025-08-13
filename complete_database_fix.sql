-- Complete Database Fix for Korean Admin Services App
-- This script adds all missing columns and fixes potential issues

-- 1. Fix applications table - add missing columns
ALTER TABLE applications 
ADD COLUMN IF NOT EXISTS business_type VARCHAR(100),
ADD COLUMN IF NOT EXISTS business_name VARCHAR(255),
ADD COLUMN IF NOT EXISTS service_type VARCHAR(100),
ADD COLUMN IF NOT EXISTS description TEXT,
ADD COLUMN IF NOT EXISTS urgency VARCHAR(50),
ADD COLUMN IF NOT EXISTS budget VARCHAR(100),
ADD COLUMN IF NOT EXISTS location VARCHAR(255),
ADD COLUMN IF NOT EXISTS documents JSONB;

-- 2. Fix audit_trail table - add missing columns
-- The main app uses 'lead_id' while the database schema has 'application_id'
-- We need to add both columns to support both apps
ALTER TABLE audit_trail
ADD COLUMN IF NOT EXISTS lead_id UUID REFERENCES applications(id) ON DELETE CASCADE,
ADD COLUMN IF NOT EXISTS hash VARCHAR(255),
ADD COLUMN IF NOT EXISTS prev_hash VARCHAR(255);

-- 3. Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_applications_business_type ON applications(business_type);
CREATE INDEX IF NOT EXISTS idx_applications_business_name ON applications(business_name);
CREATE INDEX IF NOT EXISTS idx_applications_service_type ON applications(service_type);
CREATE INDEX IF NOT EXISTS idx_applications_urgency ON applications(urgency);
CREATE INDEX IF NOT EXISTS idx_applications_location ON applications(location);
CREATE INDEX IF NOT EXISTS idx_audit_trail_lead_id ON audit_trail(lead_id);

-- 4. Ensure the application_stats view exists (used by admin dashboard)
-- Drop and recreate to ensure it includes all columns
DROP VIEW IF EXISTS application_stats;
CREATE OR REPLACE VIEW application_stats AS
SELECT 
    COUNT(*) as total_applications,
    COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending_count,
    COUNT(CASE WHEN status = 'in_progress' THEN 1 END) as in_progress_count,
    COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed_count,
    COUNT(CASE WHEN status = 'cancelled' THEN 1 END) as cancelled_count,
    COUNT(CASE WHEN created_at > NOW() - INTERVAL '7 days' THEN 1 END) as last_week_count,
    COUNT(CASE WHEN created_at > NOW() - INTERVAL '30 days' THEN 1 END) as last_month_count,
    COUNT(CASE WHEN urgency = 'urgent' THEN 1 END) as urgent_count
FROM applications;

-- 5. Grant necessary permissions
GRANT SELECT ON application_stats TO anon, authenticated;

-- 6. Enable Realtime for applications table (for live updates in admin panel)
ALTER PUBLICATION supabase_realtime ADD TABLE applications;

-- 7. Ensure auth schema is properly set up for admin authentication
-- Note: Supabase auth is handled automatically, but we ensure the user table exists
-- This is handled by Supabase automatically when using auth.users

-- 8. Add a sample test user for admin panel (ONLY FOR TESTING - REMOVE IN PRODUCTION)
-- Email: admin@test.com
-- Password: admin123456
-- Note: You need to create this user through Supabase Auth dashboard or using the signUp function

COMMENT ON TABLE applications IS 'Main table for storing all application/lead submissions from the Korean admin services form';
COMMENT ON TABLE audit_trail IS 'Tracks all changes to applications for compliance and debugging';
COMMENT ON COLUMN applications.business_type IS 'Type of business from the form wizard';
COMMENT ON COLUMN applications.business_name IS 'Name of the business';
COMMENT ON COLUMN applications.service_type IS 'Type of service requested';
COMMENT ON COLUMN applications.urgency IS 'Urgency level: normal, urgent, etc.';
COMMENT ON COLUMN applications.documents IS 'JSON array of document metadata uploaded with the form';