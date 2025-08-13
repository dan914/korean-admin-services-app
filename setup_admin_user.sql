-- Setup Admin User and Test Data for Admin App Testing
-- Run this in your Supabase SQL Editor

-- 1. Create an admin user (you'll need to do this via Supabase Auth Dashboard)
-- Go to Authentication → Users → Invite User
-- Email: admin@example.com
-- Password: Admin123!@#

-- 2. Update RLS policies to allow authenticated users to read applications
ALTER POLICY IF EXISTS "Authenticated users can view applications" 
ON applications 
TO authenticated 
USING (true);

-- If the policy doesn't exist, create it
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'applications' 
        AND policyname = 'Authenticated users can view applications'
    ) THEN
        CREATE POLICY "Authenticated users can view applications" 
        ON applications 
        FOR SELECT 
        TO authenticated 
        USING (true);
    END IF;
END $$;

-- 3. Allow authenticated users to update applications
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'applications' 
        AND policyname = 'Authenticated users can update applications'
    ) THEN
        CREATE POLICY "Authenticated users can update applications" 
        ON applications 
        FOR UPDATE 
        TO authenticated 
        USING (true);
    END IF;
END $$;

-- 4. Allow authenticated users to delete applications
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'applications' 
        AND policyname = 'Authenticated users can delete applications'
    ) THEN
        CREATE POLICY "Authenticated users can delete applications" 
        ON applications 
        FOR DELETE 
        TO authenticated 
        USING (true);
    END IF;
END $$;

-- 5. Insert test data for applications
INSERT INTO applications (
    id,
    name,
    email,
    phone,
    business_type,
    business_name,
    description,
    service_type,
    status,
    created_at,
    updated_at
) VALUES 
(
    gen_random_uuid(),
    '김철수',
    'kim@example.com',
    '010-1234-5678',
    '개인사업자',
    '김철수 행정사 사무소',
    '사업자 등록 신청 도움이 필요합니다.',
    '사업자등록',
    'pending',
    NOW() - INTERVAL '5 days',
    NOW() - INTERVAL '5 days'
),
(
    gen_random_uuid(),
    '이영희',
    'lee@example.com',
    '010-2345-6789',
    '법인',
    '(주)테크스타트',
    '법인 설립 관련 서류 준비를 요청드립니다.',
    '법인설립',
    'in_progress',
    NOW() - INTERVAL '3 days',
    NOW() - INTERVAL '2 days'
),
(
    gen_random_uuid(),
    '박민수',
    'park@example.com',
    '010-3456-7890',
    '개인',
    NULL,
    '건축 허가 신청 절차 문의',
    '건축허가',
    'pending',
    NOW() - INTERVAL '1 day',
    NOW() - INTERVAL '1 day'
),
(
    gen_random_uuid(),
    '정수진',
    'jung@example.com',
    '010-4567-8901',
    '개인사업자',
    '정수진 카페',
    '음식점 영업 허가 신청',
    '영업허가',
    'completed',
    NOW() - INTERVAL '10 days',
    NOW() - INTERVAL '1 hour'
),
(
    gen_random_uuid(),
    '최동훈',
    'choi@example.com',
    '010-5678-9012',
    '법인',
    '(주)글로벌무역',
    '수출입 관련 인허가 대행 요청',
    '수출입허가',
    'pending',
    NOW() - INTERVAL '6 hours',
    NOW() - INTERVAL '6 hours'
)
ON CONFLICT (id) DO NOTHING;

-- 6. Create or refresh the application_stats view
CREATE OR REPLACE VIEW application_stats AS
SELECT 
    COUNT(*) as total_applications,
    COUNT(*) FILTER (WHERE status = 'pending') as pending_count,
    COUNT(*) FILTER (WHERE status = 'in_progress') as in_progress_count,
    COUNT(*) FILTER (WHERE status = 'completed') as completed_count,
    COUNT(*) FILTER (WHERE status = 'cancelled') as cancelled_count,
    COUNT(*) FILTER (WHERE created_at >= NOW() - INTERVAL '7 days') as last_week_count
FROM applications;

-- 7. Grant permissions on the view
GRANT SELECT ON application_stats TO authenticated;
GRANT SELECT ON application_stats TO anon;

-- 8. Create audit_trail table if it doesn't exist
CREATE TABLE IF NOT EXISTS audit_trail (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    application_id UUID REFERENCES applications(id) ON DELETE CASCADE,
    action TEXT NOT NULL,
    changes JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id)
);

-- 9. Allow authenticated users to insert audit entries
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'audit_trail' 
        AND policyname = 'Authenticated users can insert audit entries'
    ) THEN
        CREATE POLICY "Authenticated users can insert audit entries" 
        ON audit_trail 
        FOR INSERT 
        TO authenticated 
        WITH CHECK (true);
    END IF;
END $$;

-- 10. Create webhook_settings table if it doesn't exist
CREATE TABLE IF NOT EXISTS webhook_settings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    url TEXT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    events TEXT[] DEFAULT ARRAY['application_created', 'application_updated'],
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 11. Add sample webhook settings
INSERT INTO webhook_settings (name, url, is_active, events) 
VALUES 
    ('Slack Notification', 'https://hooks.slack.com/services/example', true, ARRAY['application_created']),
    ('Email Service', 'https://api.emailservice.com/webhook', false, ARRAY['application_created', 'application_updated'])
ON CONFLICT (id) DO NOTHING;

-- 12. Grant permissions for webhook_settings
GRANT ALL ON webhook_settings TO authenticated;

SELECT 'Setup completed successfully!' as message;