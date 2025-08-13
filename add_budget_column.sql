-- Add missing budget column to applications table
ALTER TABLE applications 
ADD COLUMN IF NOT EXISTS budget VARCHAR(100);

-- Update the view to include budget information in stats if needed
-- This is optional but might be useful for reporting