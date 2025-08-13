-- Fix Database Schema for Workflow Issues
-- Run this in Supabase SQL Editor after the initial schema

-- 1. Add missing business fields to applications table
ALTER TABLE applications 
ADD COLUMN IF NOT EXISTS business_type VARCHAR(50),
ADD COLUMN IF NOT EXISTS business_name VARCHAR(255),
ADD COLUMN IF NOT EXISTS service_type VARCHAR(100),
ADD COLUMN IF NOT EXISTS description TEXT,
ADD COLUMN IF NOT EXISTS urgency VARCHAR(50),
ADD COLUMN IF NOT EXISTS budget VARCHAR(100),
ADD COLUMN IF NOT EXISTS location VARCHAR(255),
ADD COLUMN IF NOT EXISTS documents JSONB;

-- 2. Create function to extract fields from form_data JSONB
CREATE OR REPLACE FUNCTION extract_form_fields()
RETURNS TRIGGER AS $$
BEGIN
  -- Extract business information
  IF NEW.form_data ? 'businessType' THEN
    NEW.business_type = NEW.form_data->>'businessType';
  END IF;
  
  IF NEW.form_data ? 'businessName' THEN
    NEW.business_name = NEW.form_data->>'businessName';
  END IF;
  
  IF NEW.form_data ? 'serviceType' THEN
    NEW.service_type = NEW.form_data->>'serviceType';
  END IF;
  
  IF NEW.form_data ? 'description' THEN
    NEW.description = NEW.form_data->>'description';
  END IF;
  
  IF NEW.form_data ? 'urgency' THEN
    NEW.urgency = NEW.form_data->>'urgency';
  END IF;
  
  IF NEW.form_data ? 'budget' THEN
    NEW.budget = NEW.form_data->>'budget';
  END IF;
  
  IF NEW.form_data ? 'location' THEN
    NEW.location = NEW.form_data->>'location';
  END IF;
  
  IF NEW.form_data ? 'documents' THEN
    NEW.documents = NEW.form_data->'documents';
  END IF;
  
  -- Also handle alternative key formats (with underscores)
  IF NEW.form_data ? 'business_type' THEN
    NEW.business_type = NEW.form_data->>'business_type';
  END IF;
  
  IF NEW.form_data ? 'business_name' THEN
    NEW.business_name = NEW.form_data->>'business_name';
  END IF;
  
  IF NEW.form_data ? 'service_type' THEN
    NEW.service_type = NEW.form_data->>'service_type';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. Create trigger to automatically extract fields
DROP TRIGGER IF EXISTS extract_fields_before_insert ON applications;
CREATE TRIGGER extract_fields_before_insert
BEFORE INSERT ON applications
FOR EACH ROW
EXECUTE FUNCTION extract_form_fields();

-- Also run on updates to handle existing data
DROP TRIGGER IF EXISTS extract_fields_before_update ON applications;
CREATE TRIGGER extract_fields_before_update
BEFORE UPDATE ON applications
FOR EACH ROW
WHEN (OLD.form_data IS DISTINCT FROM NEW.form_data)
EXECUTE FUNCTION extract_form_fields();

-- 4. Update existing applications to extract fields
UPDATE applications 
SET 
  business_type = COALESCE(form_data->>'businessType', form_data->>'business_type'),
  business_name = COALESCE(form_data->>'businessName', form_data->>'business_name'),
  service_type = COALESCE(form_data->>'serviceType', form_data->>'service_type'),
  description = COALESCE(form_data->>'description', form_data->>'description'),
  urgency = COALESCE(form_data->>'urgency', form_data->>'urgency'),
  budget = COALESCE(form_data->>'budget', form_data->>'budget'),
  location = COALESCE(form_data->>'location', form_data->>'location')
WHERE form_data IS NOT NULL;

-- 5. Create indexes for new fields
CREATE INDEX IF NOT EXISTS idx_applications_business_type ON applications(business_type);
CREATE INDEX IF NOT EXISTS idx_applications_service_type ON applications(service_type);
CREATE INDEX IF NOT EXISTS idx_applications_urgency ON applications(urgency);

-- 6. Update the application_stats view to include new metrics
DROP VIEW IF EXISTS application_stats;
CREATE VIEW application_stats AS
SELECT 
    COUNT(*) as total_applications,
    COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending_count,
    COUNT(CASE WHEN status = 'in_progress' THEN 1 END) as in_progress_count,
    COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed_count,
    COUNT(CASE WHEN status = 'cancelled' THEN 1 END) as cancelled_count,
    COUNT(CASE WHEN created_at > NOW() - INTERVAL '7 days' THEN 1 END) as last_week_count,
    COUNT(CASE WHEN created_at > NOW() - INTERVAL '30 days' THEN 1 END) as last_month_count,
    -- New statistics
    COUNT(CASE WHEN urgency = 'urgent' THEN 1 END) as urgent_count,
    COUNT(DISTINCT service_type) as service_type_count,
    COUNT(DISTINCT business_type) as business_type_count
FROM applications;

-- 7. Grant permissions on the updated view
GRANT SELECT ON application_stats TO authenticated;
GRANT SELECT ON application_stats TO anon;

-- 8. Create a view for admin dashboard with properly formatted data
CREATE OR REPLACE VIEW admin_applications_view AS
SELECT 
    id,
    name,
    phone,
    email,
    business_type,
    business_name,
    service_type,
    description,
    urgency,
    budget,
    location,
    status,
    priority,
    notification_kakao,
    notification_sms,
    notification_email,
    admin_notes,
    assigned_to,
    created_at,
    updated_at,
    completed_at,
    form_data,
    documents,
    -- Computed fields
    CASE 
        WHEN urgency = 'urgent' THEN 1
        WHEN urgency = 'high' THEN 2
        WHEN urgency = 'normal' THEN 3
        ELSE 4
    END as urgency_order,
    EXTRACT(EPOCH FROM (NOW() - created_at))/3600 as hours_since_created
FROM applications
ORDER BY urgency_order, created_at DESC;

-- 9. Grant permissions on the new view
GRANT SELECT ON admin_applications_view TO authenticated;

-- 10. Add missing audit trail foreign key for proper user tracking
ALTER TABLE audit_trail
DROP CONSTRAINT IF EXISTS audit_trail_admin_id_fkey;

ALTER TABLE audit_trail
ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id);

-- Migrate existing admin_id to user_id if needed
UPDATE audit_trail 
SET user_id = admin_id 
WHERE user_id IS NULL AND admin_id IS NOT NULL;

SELECT 'Database schema fixes applied successfully!' as message;