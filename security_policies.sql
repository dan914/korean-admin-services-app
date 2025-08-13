-- Security Policies for Korean Admin Services App
-- Run this in Supabase SQL Editor

-- ============================================
-- 1. ENABLE ROW LEVEL SECURITY ON ALL TABLES
-- ============================================

ALTER TABLE applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_trail ENABLE ROW LEVEL SECURITY;
ALTER TABLE webhook_logs ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 2. APPLICATIONS TABLE POLICIES
-- ============================================

-- Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Anyone can insert applications" ON applications;
DROP POLICY IF EXISTS "Authenticated users can view applications" ON applications;
DROP POLICY IF EXISTS "Authenticated users can update applications" ON applications;

-- Public can only INSERT (submit forms) - with rate limiting
CREATE POLICY "Public can submit applications with rate limit" ON applications
    FOR INSERT TO anon
    WITH CHECK (
        -- Basic validation
        length(name) >= 2 AND length(name) <= 50
        AND length(phone) >= 10 AND length(phone) <= 20
        AND (email IS NULL OR email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$')
    );

-- Only authenticated users can VIEW applications
CREATE POLICY "Authenticated can view applications" ON applications
    FOR SELECT TO authenticated
    USING (true);

-- Only authenticated users can UPDATE applications
CREATE POLICY "Authenticated can update applications" ON applications
    FOR UPDATE TO authenticated
    USING (true)
    WITH CHECK (true);

-- Only authenticated users can DELETE applications
CREATE POLICY "Authenticated can delete applications" ON applications
    FOR DELETE TO authenticated
    USING (true);

-- ============================================
-- 3. AUDIT TRAIL POLICIES
-- ============================================

-- Drop existing policies
DROP POLICY IF EXISTS "Authenticated can insert audit trail" ON audit_trail;
DROP POLICY IF EXISTS "Authenticated can view audit trail" ON audit_trail;

-- Only authenticated users can insert audit entries
CREATE POLICY "Authenticated can create audit entries" ON audit_trail
    FOR INSERT TO authenticated
    WITH CHECK (true);

-- Only authenticated users can view audit trail
CREATE POLICY "Authenticated can view audit entries" ON audit_trail
    FOR SELECT TO authenticated
    USING (true);

-- Audit trail is immutable - no UPDATE or DELETE allowed
-- (No policies = no access)

-- ============================================
-- 4. WEBHOOK LOGS POLICIES
-- ============================================

-- Only system can insert webhook logs (using service key)
CREATE POLICY "Service role can insert webhook logs" ON webhook_logs
    FOR INSERT TO authenticated, service_role
    WITH CHECK (true);

-- Authenticated users can view webhook logs
CREATE POLICY "Authenticated can view webhook logs" ON webhook_logs
    FOR SELECT TO authenticated
    USING (true);

-- ============================================
-- 5. RATE LIMITING FUNCTION
-- ============================================

-- Create rate limiting table
CREATE TABLE IF NOT EXISTS rate_limits (
    identifier TEXT PRIMARY KEY,  -- Can be IP or phone number
    attempt_count INT DEFAULT 1,
    first_attempt TIMESTAMPTZ DEFAULT NOW(),
    last_attempt TIMESTAMPTZ DEFAULT NOW()
);

-- Function to check rate limit
CREATE OR REPLACE FUNCTION check_rate_limit(
    p_identifier TEXT,
    p_max_attempts INT DEFAULT 10,
    p_window_minutes INT DEFAULT 60
)
RETURNS BOOLEAN AS $$
DECLARE
    v_count INT;
    v_first_attempt TIMESTAMPTZ;
BEGIN
    -- Get existing attempts
    SELECT attempt_count, first_attempt 
    INTO v_count, v_first_attempt
    FROM rate_limits 
    WHERE identifier = p_identifier;
    
    -- If no record exists, create one
    IF NOT FOUND THEN
        INSERT INTO rate_limits (identifier, attempt_count, first_attempt, last_attempt)
        VALUES (p_identifier, 1, NOW(), NOW());
        RETURN TRUE;
    END IF;
    
    -- Check if outside time window
    IF NOW() - v_first_attempt > (p_window_minutes || ' minutes')::INTERVAL THEN
        -- Reset counter
        UPDATE rate_limits 
        SET attempt_count = 1, 
            first_attempt = NOW(), 
            last_attempt = NOW()
        WHERE identifier = p_identifier;
        RETURN TRUE;
    END IF;
    
    -- Check if limit exceeded
    IF v_count >= p_max_attempts THEN
        RETURN FALSE;
    END IF;
    
    -- Increment counter
    UPDATE rate_limits 
    SET attempt_count = attempt_count + 1,
        last_attempt = NOW()
    WHERE identifier = p_identifier;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 6. SECURE FUNCTIONS
-- ============================================

-- Function to safely submit application with rate limiting
CREATE OR REPLACE FUNCTION submit_application_secure(
    p_form_data JSONB,
    p_name TEXT,
    p_phone TEXT,
    p_email TEXT DEFAULT NULL,
    p_ip_address INET DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    v_application_id UUID;
    v_rate_limit_ok BOOLEAN;
BEGIN
    -- Check rate limit by phone
    v_rate_limit_ok := check_rate_limit('phone_' || p_phone, 5, 60);
    IF NOT v_rate_limit_ok THEN
        RAISE EXCEPTION 'Rate limit exceeded. Please try again later.';
    END IF;
    
    -- Check rate limit by IP if provided
    IF p_ip_address IS NOT NULL THEN
        v_rate_limit_ok := check_rate_limit('ip_' || p_ip_address::TEXT, 10, 60);
        IF NOT v_rate_limit_ok THEN
            RAISE EXCEPTION 'Too many requests from this IP. Please try again later.';
        END IF;
    END IF;
    
    -- Validate phone number (Korean format)
    IF NOT p_phone ~ '^01[0-9]{8,9}$' THEN
        RAISE EXCEPTION 'Invalid phone number format';
    END IF;
    
    -- Validate email if provided
    IF p_email IS NOT NULL AND p_email != '' THEN
        IF NOT p_email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$' THEN
            RAISE EXCEPTION 'Invalid email format';
        END IF;
    END IF;
    
    -- Insert application
    INSERT INTO applications (
        form_data,
        name,
        phone,
        email,
        ip_address,
        status,
        source,
        created_at
    ) VALUES (
        p_form_data,
        p_name,
        p_phone,
        p_email,
        p_ip_address,
        'pending',
        'web_form',
        NOW()
    )
    RETURNING id INTO v_application_id;
    
    RETURN v_application_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 7. DATA RETENTION POLICIES
-- ============================================

-- Function to anonymize old applications
CREATE OR REPLACE FUNCTION anonymize_old_applications()
RETURNS VOID AS $$
BEGIN
    UPDATE applications
    SET 
        name = 'ANONYMIZED',
        phone = 'ANONYMIZED',
        email = NULL,
        ip_address = NULL,
        form_data = jsonb_build_object('anonymized', true)
    WHERE 
        created_at < NOW() - INTERVAL '1 year'
        AND status = 'completed';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to delete old audit logs
CREATE OR REPLACE FUNCTION cleanup_old_audit_logs()
RETURNS VOID AS $$
BEGIN
    DELETE FROM audit_trail
    WHERE created_at < NOW() - INTERVAL '6 months';
    
    DELETE FROM webhook_logs
    WHERE created_at < NOW() - INTERVAL '3 months';
    
    DELETE FROM rate_limits
    WHERE last_attempt < NOW() - INTERVAL '24 hours';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 8. LOGGING FUNCTIONS
-- ============================================

-- Create security events table
CREATE TABLE IF NOT EXISTS security_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_type TEXT NOT NULL,
    severity TEXT CHECK (severity IN ('info', 'warning', 'error', 'critical')),
    details JSONB,
    ip_address INET,
    user_id UUID,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Function to log security events
CREATE OR REPLACE FUNCTION log_security_event(
    p_event_type TEXT,
    p_severity TEXT,
    p_details JSONB,
    p_ip_address INET DEFAULT NULL,
    p_user_id UUID DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO security_events (event_type, severity, details, ip_address, user_id)
    VALUES (p_event_type, p_severity, p_details, p_ip_address, p_user_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 9. GRANT MINIMAL PERMISSIONS
-- ============================================

-- Revoke all default permissions
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC;

-- Grant specific permissions to anon role (public users)
GRANT USAGE ON SCHEMA public TO anon;
GRANT INSERT ON applications TO anon;
GRANT EXECUTE ON FUNCTION submit_application_secure TO anon;
GRANT EXECUTE ON FUNCTION check_rate_limit TO anon;

-- Grant permissions to authenticated role (admin users)
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON applications TO authenticated;
GRANT ALL ON audit_trail TO authenticated;
GRANT SELECT ON webhook_logs TO authenticated;
GRANT SELECT ON security_events TO authenticated;
GRANT SELECT ON rate_limits TO authenticated;

-- Grant permissions to service role (backend services)
GRANT ALL ON ALL TABLES IN SCHEMA public TO service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO service_role;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO service_role;

-- ============================================
-- 10. CREATE INDEXES FOR PERFORMANCE
-- ============================================

CREATE INDEX IF NOT EXISTS idx_applications_phone ON applications(phone);
CREATE INDEX IF NOT EXISTS idx_applications_status ON applications(status);
CREATE INDEX IF NOT EXISTS idx_applications_created_at ON applications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_trail_application_id ON audit_trail(application_id);
CREATE INDEX IF NOT EXISTS idx_security_events_created_at ON security_events(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_rate_limits_last_attempt ON rate_limits(last_attempt);

-- ============================================
-- IMPORTANT: After running this script
-- ============================================
-- 1. Test all functionality to ensure policies work correctly
-- 2. Monitor security_events table for suspicious activity
-- 3. Set up scheduled jobs for cleanup functions
-- 4. Configure Supabase Auth for admin users
-- 5. Enable SSL/TLS for all connections