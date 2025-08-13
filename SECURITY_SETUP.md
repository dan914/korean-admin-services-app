# Security Setup Guide for Korean Admin Services App

## 🔐 Critical Security Measures

### 1. Environment Variables & API Keys

#### Never Commit Sensitive Data
- ❌ NEVER commit `.env` files to Git
- ❌ NEVER hardcode API keys in source code
- ✅ Use environment variables for all secrets

#### Create `.env` files:

**For Main App (`행정도우미/.env`):**
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
```

**For Admin App (`admin_app/.env`):**
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_KEY=your_service_key  # Admin only
```

#### Add to `.gitignore`:
```gitignore
# Environment files
*.env
*.env.local
*.env.production
*.env.development

# API Keys
**/lib/config/env.dart
**/lib/config/secrets.dart
```

### 2. Supabase Row Level Security (RLS)

Run these SQL commands in Supabase:

```sql
-- Enable RLS on all tables
ALTER TABLE applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_trail ENABLE ROW LEVEL SECURITY;

-- Applications table policies
-- Public can only INSERT (submit forms)
DROP POLICY IF EXISTS "Public can insert applications" ON applications;
CREATE POLICY "Public can insert applications" ON applications
    FOR INSERT TO anon
    WITH CHECK (true);

-- Only authenticated admins can view applications
DROP POLICY IF EXISTS "Admins can view applications" ON applications;
CREATE POLICY "Admins can view applications" ON applications
    FOR SELECT TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM admin_users
            WHERE admin_users.id = auth.uid()
            AND admin_users.is_active = true
        )
    );

-- Only authenticated admins can update applications
DROP POLICY IF EXISTS "Admins can update applications" ON applications;
CREATE POLICY "Admins can update applications" ON applications
    FOR UPDATE TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM admin_users
            WHERE admin_users.id = auth.uid()
            AND admin_users.is_active = true
        )
    );

-- Only super admins can delete
DROP POLICY IF EXISTS "Super admins can delete applications" ON applications;
CREATE POLICY "Super admins can delete applications" ON applications
    FOR DELETE TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM admin_users
            WHERE admin_users.id = auth.uid()
            AND admin_users.role = 'super_admin'
            AND admin_users.is_active = true
        )
    );

-- Audit trail - only admins can insert
DROP POLICY IF EXISTS "Admins can insert audit trail" ON audit_trail;
CREATE POLICY "Admins can insert audit trail" ON audit_trail
    FOR INSERT TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM admin_users
            WHERE admin_users.id = auth.uid()
            AND admin_users.is_active = true
        )
    );

-- Audit trail is read-only for everyone else
DROP POLICY IF EXISTS "Admins can view audit trail" ON audit_trail;
CREATE POLICY "Admins can view audit trail" ON audit_trail
    FOR SELECT TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM admin_users
            WHERE admin_users.id = auth.uid()
            AND admin_users.is_active = true
        )
    );
```

### 3. Input Validation & Sanitization

#### Phone Number Validation
```dart
bool isValidKoreanPhone(String phone) {
  // Remove all non-digits
  final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
  
  // Korean phone numbers: 010-XXXX-XXXX or 02-XXXX-XXXX
  final regex = RegExp(r'^(01[0-9]|02|0[3-9][0-9])[0-9]{7,8}$');
  return regex.hasMatch(cleaned);
}
```

#### Email Validation
```dart
bool isValidEmail(String email) {
  final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return regex.hasMatch(email);
}
```

#### Prevent SQL Injection
- ✅ Supabase automatically parameterizes queries
- ✅ Never concatenate user input into queries
- ✅ Use Supabase client methods, not raw SQL

### 4. Authentication Security

#### Admin Authentication Requirements
- Minimum password length: 12 characters
- Require uppercase, lowercase, numbers, and special characters
- Implement 2FA for admin accounts
- Session timeout after 30 minutes of inactivity

#### Implement Session Management
```dart
// Auto-logout after inactivity
Timer? _inactivityTimer;

void _resetInactivityTimer() {
  _inactivityTimer?.cancel();
  _inactivityTimer = Timer(Duration(minutes: 30), () {
    // Auto logout
    supabase.auth.signOut();
    // Navigate to login
  });
}
```

### 5. Rate Limiting

#### Implement rate limiting for form submissions:
```sql
-- Create rate limiting table
CREATE TABLE IF NOT EXISTS rate_limits (
    ip_address INET PRIMARY KEY,
    submission_count INT DEFAULT 0,
    last_reset TIMESTAMPTZ DEFAULT NOW()
);

-- Function to check rate limit
CREATE OR REPLACE FUNCTION check_rate_limit(client_ip INET)
RETURNS BOOLEAN AS $$
DECLARE
    current_count INT;
    last_reset_time TIMESTAMPTZ;
BEGIN
    -- Get current count
    SELECT submission_count, last_reset 
    INTO current_count, last_reset_time
    FROM rate_limits 
    WHERE ip_address = client_ip;
    
    -- If no record, create one
    IF NOT FOUND THEN
        INSERT INTO rate_limits (ip_address, submission_count, last_reset)
        VALUES (client_ip, 1, NOW());
        RETURN TRUE;
    END IF;
    
    -- Reset if more than 1 hour passed
    IF NOW() - last_reset_time > INTERVAL '1 hour' THEN
        UPDATE rate_limits 
        SET submission_count = 1, last_reset = NOW()
        WHERE ip_address = client_ip;
        RETURN TRUE;
    END IF;
    
    -- Check limit (max 10 per hour)
    IF current_count >= 10 THEN
        RETURN FALSE;
    END IF;
    
    -- Increment counter
    UPDATE rate_limits 
    SET submission_count = submission_count + 1
    WHERE ip_address = client_ip;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;
```

### 6. Data Encryption

#### Encrypt sensitive data at rest:
```sql
-- Enable encryption for sensitive columns
-- Supabase automatically encrypts data at rest
-- For additional security, encrypt sensitive fields:

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Example: Encrypt phone numbers
ALTER TABLE applications 
ADD COLUMN phone_encrypted TEXT;

-- Encrypt existing data
UPDATE applications 
SET phone_encrypted = pgp_sym_encrypt(phone, 'your-secret-key');
```

### 7. CORS Configuration

For production, configure CORS properly:

```dart
// In your Flutter web app
// Configure allowed origins in Supabase dashboard
// Settings > API > CORS Allowed Origins
```

### 8. Security Headers

Add security headers for web deployment:

**For Netlify (`netlify.toml`):**
```toml
[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-Content-Type-Options = "nosniff"
    X-XSS-Protection = "1; mode=block"
    Referrer-Policy = "strict-origin-when-cross-origin"
    Content-Security-Policy = "default-src 'self'; script-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net; style-src 'self' 'unsafe-inline';"
```

### 9. Logging & Monitoring

#### Implement security logging:
```sql
-- Create security log table
CREATE TABLE security_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_type VARCHAR(50),
    ip_address INET,
    user_agent TEXT,
    details JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Log failed login attempts
CREATE OR REPLACE FUNCTION log_failed_login(
    email VARCHAR,
    ip INET,
    agent TEXT
) RETURNS VOID AS $$
BEGIN
    INSERT INTO security_logs (event_type, ip_address, user_agent, details)
    VALUES ('failed_login', ip, agent, jsonb_build_object('email', email));
END;
$$ LANGUAGE plpgsql;
```

### 10. Regular Security Audits

#### Weekly Checks:
- [ ] Review failed login attempts
- [ ] Check for unusual activity patterns
- [ ] Monitor rate limit violations
- [ ] Review admin access logs

#### Monthly Checks:
- [ ] Update dependencies
- [ ] Review and rotate API keys
- [ ] Audit admin user accounts
- [ ] Check for security patches

### 11. Data Privacy (GDPR/PIPA Compliance)

#### Korean Personal Information Protection Act (PIPA):
- Obtain explicit consent for data collection
- Provide data deletion options
- Encrypt personal information
- Limit data retention period
- Log all data access

```sql
-- Auto-delete old applications after 1 year
CREATE OR REPLACE FUNCTION delete_old_applications()
RETURNS VOID AS $$
BEGIN
    DELETE FROM applications 
    WHERE created_at < NOW() - INTERVAL '1 year'
    AND status = 'completed';
END;
$$ LANGUAGE plpgsql;

-- Schedule daily cleanup
SELECT cron.schedule('delete-old-applications', '0 2 * * *', 'SELECT delete_old_applications()');
```

### 12. Backup & Recovery

#### Implement regular backups:
```bash
# Daily backup script
#!/bin/bash
pg_dump $DATABASE_URL > backup_$(date +%Y%m%d).sql
# Upload to secure storage
aws s3 cp backup_$(date +%Y%m%d).sql s3://your-backup-bucket/
```

## 🚨 Emergency Response Plan

### If Breach Detected:
1. **Immediately revoke all API keys**
2. **Reset all admin passwords**
3. **Enable maintenance mode**
4. **Review audit logs**
5. **Notify affected users within 72 hours (PIPA requirement)**
6. **Document incident**

### Security Contacts:
- Supabase Support: support@supabase.com
- KISA (Korea Internet & Security Agency): 118

## ✅ Security Checklist

### Before Production:
- [ ] All API keys in environment variables
- [ ] RLS policies enabled and tested
- [ ] Input validation implemented
- [ ] Rate limiting configured
- [ ] HTTPS enforced
- [ ] Admin 2FA enabled
- [ ] Audit logging active
- [ ] Backup system tested
- [ ] Security headers configured
- [ ] CORS properly configured
- [ ] Sensitive data encrypted
- [ ] Session timeout implemented
- [ ] Error messages don't leak information
- [ ] Dependencies updated
- [ ] Security scan completed