-- Add all missing columns to applications table that the Flutter app expects

-- Business-related columns
ALTER TABLE applications 
ADD COLUMN IF NOT EXISTS business_type VARCHAR(100),
ADD COLUMN IF NOT EXISTS business_name VARCHAR(255),
ADD COLUMN IF NOT EXISTS service_type VARCHAR(100),
ADD COLUMN IF NOT EXISTS description TEXT,
ADD COLUMN IF NOT EXISTS urgency VARCHAR(50),
ADD COLUMN IF NOT EXISTS budget VARCHAR(100),
ADD COLUMN IF NOT EXISTS location VARCHAR(255),
ADD COLUMN IF NOT EXISTS documents JSONB;

-- Create indexes for new columns for better query performance
CREATE INDEX IF NOT EXISTS idx_applications_business_type ON applications(business_type);
CREATE INDEX IF NOT EXISTS idx_applications_business_name ON applications(business_name);
CREATE INDEX IF NOT EXISTS idx_applications_service_type ON applications(service_type);
CREATE INDEX IF NOT EXISTS idx_applications_urgency ON applications(urgency);
CREATE INDEX IF NOT EXISTS idx_applications_location ON applications(location);