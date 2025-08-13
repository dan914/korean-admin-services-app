-- Supabase Database Schema for Korean Admin Services App
-- Run this entire script at once in Supabase SQL Editor

-- Clean up existing tables if needed (be careful in production!)
DROP TABLE IF EXISTS webhook_logs CASCADE;
DROP TABLE IF EXISTS audit_trail CASCADE;
DROP TABLE IF EXISTS admin_users CASCADE;
DROP TABLE IF EXISTS applications CASCADE;
DROP VIEW IF EXISTS application_stats CASCADE;

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Main applications/leads table
CREATE TABLE applications (
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

-- Admin users table
CREATE TABLE admin_users (
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
CREATE TABLE audit_trail (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    application_id UUID REFERENCES applications(id) ON DELETE CASCADE,
    admin_id UUID REFERENCES admin_users(id),
    action VARCHAR(50) NOT NULL,
    changes JSONB,
    ip_address INET,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Webhook logs table
CREATE TABLE webhook_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    application_id UUID REFERENCES applications(id) ON DELETE CASCADE,
    webhook_url TEXT NOT NULL,
    payload JSONB NOT NULL,
    response_status INTEGER,
    response_body TEXT,
    success BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_applications_status ON applications(status);
CREATE INDEX idx_applications_created_at ON applications(created_at DESC);
CREATE INDEX idx_applications_phone ON applications(phone);
CREATE INDEX idx_applications_email ON applications(email);
CREATE INDEX idx_applications_reservation_date ON applications(reservation_date);
CREATE INDEX idx_audit_trail_application_id ON audit_trail(application_id);
CREATE INDEX idx_audit_trail_created_at ON audit_trail(created_at DESC);

-- Statistics view for dashboard
CREATE VIEW application_stats AS
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

-- Enable Row Level Security
ALTER TABLE applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_trail ENABLE ROW LEVEL SECURITY;

-- RLS Policies for applications table
CREATE POLICY "Anyone can insert applications" ON applications
    FOR INSERT 
    WITH CHECK (true);

CREATE POLICY "Anyone can view their own application" ON applications
    FOR SELECT 
    USING (true);  -- You might want to restrict this later

CREATE POLICY "Authenticated users can update applications" ON applications
    FOR UPDATE 
    USING (true);

-- Insert a test application to verify everything works
INSERT INTO applications (
    form_data,
    name,
    phone,
    email,
    memo,
    status,
    priority
) VALUES (
    '{
        "step_1": "relief",
        "step_2": "1120000",
        "step_3": "notice",
        "step_4": "penalty",
        "step_5": "1",
        "step_6": "2",
        "step_7": "11",
        "step_8": "week",
        "step_9": "phone",
        "step_10": "fair"
    }'::jsonb,
    'Test User (삭제해도 됨)',
    '010-1234-5678',
    'test@example.com',
    'This is a test application - you can delete this',
    'pending',
    'normal'
);

-- Verify the insert worked
SELECT id, name, phone, status FROM applications LIMIT 1;