-- Supabase Database Schema for Korean Admin Services App
-- Created: 2025-08-13

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Main applications/leads table
CREATE TABLE IF NOT EXISTS applications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Wizard form data (JSON to store all 10 steps)
    form_data JSONB NOT NULL,
    
    -- Contact Information
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(255),
    
    -- Notification Preferences
    notification_kakao BOOLEAN DEFAULT false,
    notification_sms BOOLEAN DEFAULT false,
    notification_email BOOLEAN DEFAULT false,
    
    -- Reservation Details
    reservation_date DATE,
    first_time_slot VARCHAR(50),
    second_time_slot VARCHAR(50),
    
    -- Additional Information
    memo TEXT,
    
    -- Status Management
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
    priority VARCHAR(20) DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
    
    -- Tracking
    source VARCHAR(50) DEFAULT 'web_form',
    ip_address INET,
    user_agent TEXT,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    
    -- Admin notes
    admin_notes TEXT,
    assigned_to VARCHAR(255)
);

-- Create indexes for better query performance
CREATE INDEX idx_applications_status ON applications(status);
CREATE INDEX idx_applications_created_at ON applications(created_at DESC);
CREATE INDEX idx_applications_phone ON applications(phone);
CREATE INDEX idx_applications_email ON applications(email);
CREATE INDEX idx_applications_reservation_date ON applications(reservation_date);

-- Admin users table
CREATE TABLE IF NOT EXISTS admin_users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100),
    role VARCHAR(50) DEFAULT 'admin' CHECK (role IN ('admin', 'super_admin', 'viewer')),
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Audit trail table for tracking changes
CREATE TABLE IF NOT EXISTS audit_trail (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    application_id UUID REFERENCES applications(id) ON DELETE CASCADE,
    admin_id UUID REFERENCES admin_users(id),
    action VARCHAR(50) NOT NULL,
    changes JSONB,
    ip_address INET,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for audit trail
CREATE INDEX idx_audit_trail_application_id ON audit_trail(application_id);
CREATE INDEX idx_audit_trail_created_at ON audit_trail(created_at DESC);

-- Webhook logs table (for tracking webhook deliveries)
CREATE TABLE IF NOT EXISTS webhook_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    application_id UUID REFERENCES applications(id) ON DELETE CASCADE,
    webhook_url TEXT NOT NULL,
    payload JSONB NOT NULL,
    response_status INTEGER,
    response_body TEXT,
    success BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Statistics view for dashboard
CREATE OR REPLACE VIEW application_stats AS
SELECT 
    COUNT(*) as total_applications,
    COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending_count,
    COUNT(CASE WHEN status = 'in_progress' THEN 1 END) as in_progress_count,
    COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed_count,
    COUNT(CASE WHEN status = 'cancelled' THEN 1 END) as cancelled_count,
    COUNT(CASE WHEN created_at > NOW() - INTERVAL '7 days' THEN 1 END) as last_week_count,
    COUNT(CASE WHEN created_at > NOW() - INTERVAL '30 days' THEN 1 END) as last_month_count
FROM applications;

-- Function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_applications_updated_at BEFORE UPDATE ON applications
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_admin_users_updated_at BEFORE UPDATE ON admin_users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security (RLS) Policies
ALTER TABLE applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_trail ENABLE ROW LEVEL SECURITY;

-- Public can insert applications (for form submission)
CREATE POLICY "Anyone can insert applications" ON applications
    FOR INSERT TO anon
    WITH CHECK (true);

-- Only authenticated users can view applications
CREATE POLICY "Authenticated users can view applications" ON applications
    FOR SELECT TO authenticated
    USING (true);

-- Only authenticated users can update applications
CREATE POLICY "Authenticated users can update applications" ON applications
    FOR UPDATE TO authenticated
    USING (true);

-- Sample admin user (REMOVE IN PRODUCTION)
-- Password: admin1234 (you should hash this properly in production)
INSERT INTO admin_users (email, password_hash, name, role)
VALUES ('admin@example.com', 'admin1234_hash', 'Admin User', 'super_admin')
ON CONFLICT (email) DO NOTHING;

-- Grant permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT SELECT ON application_stats TO anon, authenticated;
GRANT INSERT ON applications TO anon;
GRANT ALL ON applications TO authenticated;
GRANT ALL ON admin_users TO authenticated;
GRANT ALL ON audit_trail TO authenticated;
GRANT ALL ON webhook_logs TO authenticated;