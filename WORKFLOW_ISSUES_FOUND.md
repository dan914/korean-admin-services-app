# Workflow Issues Found

## 🔴 Critical Issues

### 1. **Missing Business Data Fields in Database**
The database schema is missing critical business fields that the admin app tries to display:
- `business_type` (개인사업자/법인/개인)
- `business_name` (사업자명)
- `service_type` (사업자등록/법인설립/건축허가 등)
- `description` (상세 설명)

**Current State**: These are stored in the `form_data` JSONB field but admin app can't access them properly
**Impact**: Admin cannot see important application details

### 2. **Field Mapping Mismatch**
- Main app stores wizard data in `form_data` JSONB
- Admin app expects fields at root level (e.g., `app['business_type']`)
- No extraction of nested JSONB data

### 3. **Missing Form Data Display in Admin**
The admin app doesn't display the actual form data from the wizard steps. It only shows:
- Name, phone, email
- Status
- Timestamps
- But NOT the actual service details, business info, etc.

## 🟡 Moderate Issues

### 4. **Incomplete Admin User Setup**
- Database has `admin_users` table but it's not used
- Admin auth goes through Supabase Auth, not the admin_users table
- Mismatch between schema design and implementation

### 5. **Timestamp Field Issues**
- Admin app looks for `app['timestamp']` 
- Database uses `created_at`
- Could cause display issues

### 6. **Reservation Fields Not Populated**
- Database has: `reservation_date`, `first_time_slot`, `second_time_slot`
- Main app doesn't collect or send these fields
- Admin app tries to display them (will show as '-')

## 🟢 Minor Issues

### 7. **Unused Memo Field**
- Database has `memo` field
- Main app doesn't collect it
- Admin displays it but will always be empty

### 8. **Missing IP and User Agent Tracking**
- Database schema includes `ip_address` and `user_agent`
- Main app doesn't capture or send these

## Recommended Fixes

### Fix 1: Add Missing Fields to Database
```sql
ALTER TABLE applications 
ADD COLUMN business_type VARCHAR(50),
ADD COLUMN business_name VARCHAR(255),
ADD COLUMN service_type VARCHAR(100),
ADD COLUMN description TEXT;
```

### Fix 2: Update Main App Submission
```dart
// supabase_service.dart
final response = await client
  .from('applications')
  .insert({
    'form_data': processedFormData,
    'business_type': formData['businessType'],  // Add these
    'business_name': formData['businessName'],
    'service_type': formData['serviceType'],
    'description': formData['description'],
    // ... rest
  });
```

### Fix 3: Update Admin App to Display Form Data
```dart
// applications_screen.dart
// Add section to display form_data contents
if (app['form_data'] != null) {
  final formData = app['form_data'] as Map<String, dynamic>;
  // Display business type: formData['businessType']
  // Display service type: formData['serviceType']
  // etc.
}
```

### Fix 4: Fix Timestamp Field
```dart
// Change from:
_formatDate(app['timestamp'])
// To:
_formatDate(app['created_at'])
```

### Fix 5: Extract Key Fields During Insert
Create a database function to extract key fields from JSONB:
```sql
CREATE OR REPLACE FUNCTION extract_form_fields()
RETURNS TRIGGER AS $$
BEGIN
  NEW.business_type = NEW.form_data->>'businessType';
  NEW.business_name = NEW.form_data->>'businessName';
  NEW.service_type = NEW.form_data->>'serviceType';
  NEW.description = NEW.form_data->>'description';
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER extract_fields_before_insert
BEFORE INSERT ON applications
FOR EACH ROW
EXECUTE FUNCTION extract_form_fields();
```

## Testing Recommendations

1. **Test Data Visibility**:
   - Submit form from main app
   - Check if all business details appear in admin app
   - Verify JSONB data is accessible

2. **Test Field Mapping**:
   - Ensure wizard field names match database expectations
   - Verify admin app can read nested JSONB data

3. **Test Edge Cases**:
   - Submit without optional fields
   - Test with special characters in business names
   - Test with very long descriptions

## Priority Order

1. **HIGH**: Fix field mapping issues (admin can't see application details)
2. **HIGH**: Add missing database fields or fix JSONB extraction
3. **MEDIUM**: Fix timestamp field reference
4. **LOW**: Remove unused fields or implement missing features
5. **LOW**: Add IP/user agent tracking if needed

## Impact Summary

Without these fixes:
- ❌ Admin cannot see what service the user is requesting
- ❌ Admin cannot see business details
- ❌ Admin cannot properly process applications
- ❌ Critical business information is hidden in JSONB

With fixes:
- ✅ Full application details visible to admin
- ✅ Proper field mapping throughout system
- ✅ Complete workflow from submission to processing