# Complete Workflow: Form Submission to Admin Reception

## Overview
This document describes the complete data flow from when a user submits a form in the main app (행정도우미) to when an admin receives and processes it in the admin app.

## Architecture

```
┌─────────────────┐     ┌──────────────┐     ┌─────────────────┐
│   Main App      │────▶│   Supabase   │────▶│   Admin App     │
│  (행정도우미)    │     │   Database   │     │  (Admin Panel)  │
└─────────────────┘     └──────────────┘     └─────────────────┘
     Flutter              PostgreSQL             Flutter Web
```

## Detailed Workflow

### 1. User Fills Out Form (Main App)

**Location**: `행정도우미/lib/screens/` (wizard screens)

The user goes through a 10-step wizard:
1. Service type selection
2. Business type
3. Business details
4. Service specifics
5. Timeline/urgency
6. Budget
7. Location
8. Additional info
9. Document upload
10. Contact information

**Key Files**:
- `wizard_screen.dart` - Main wizard controller
- `contact_screen.dart` - Final step with contact info

### 2. Form Submission Process

**Location**: `행정도우미/lib/screens/contact_screen.dart:232-296`

When user clicks submit:

```dart
// contact_screen.dart
Future<void> _submitForm() async {
  // 1. Validate form
  if (!_formKey.currentState!.validate()) return;
  
  // 2. Collect wizard data
  final wizardState = ref.read(wizardProvider);
  
  // 3. Create application data
  final leadData = {
    'form_data': wizardState.answers,    // All 10 steps
    'name': _formData.name,
    'phone': _formData.phone,
    'email': _formData.email,
    'notification_kakao': _formData.allowKakao,
    'notification_sms': _formData.allowSms,
    'notification_email': _formData.allowEmail,
    'status': 'pending',
  };
  
  // 4. Submit to Supabase
  await SupabaseService().submitLead(...);
}
```

### 3. Data Storage in Supabase

**Location**: `행정도우미/lib/services/supabase_service.dart:31-91`

The `submitLead` method:

```dart
// supabase_service.dart
Future<Map<String, dynamic>> submitLead(...) async {
  // Insert into applications table
  final response = await client
    .from('applications')
    .insert({
      'form_data': processedFormData,  // JSONB column
      'name': contactInfo['name'],
      'phone': contactInfo['phone'],
      'email': contactInfo['email'],
      'notification_kakao': ...,
      'notification_sms': ...,
      'notification_email': ...,
      'status': 'pending',
      'priority': 'normal',
      'source': 'web_form',
    })
    .select()
    .single();
    
  // Create audit trail
  await _createAuditTrail(...);
  
  return response;
}
```

### 4. Database Structure

**Table**: `applications`

```sql
CREATE TABLE applications (
  id UUID PRIMARY KEY,
  form_data JSONB NOT NULL,           -- All wizard answers
  name VARCHAR(100) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  email VARCHAR(255),
  notification_kakao BOOLEAN,
  notification_sms BOOLEAN,
  notification_email BOOLEAN,
  status VARCHAR(20) DEFAULT 'pending',
  priority VARCHAR(20) DEFAULT 'normal',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**RLS Policies**:
- Anonymous users can INSERT (submit forms)
- Authenticated users can SELECT/UPDATE/DELETE (admin operations)

### 5. Admin App Authentication

**Location**: `admin_app/lib/services/auth_service.dart`

Admin users must authenticate with Supabase:

```dart
// Login process
final response = await authService.signInWithPassword(
  email: 'admin@example.com',
  password: 'secure_password',
);
```

### 6. Admin App Data Fetching

**Location**: `admin_app/lib/services/supabase_service.dart:32-56`

```dart
Future<List<Map<String, dynamic>>> getApplications() async {
  // Check authentication
  if (!authService.isAuthenticated) {
    throw Exception('User not authenticated');
  }
  
  // Fetch applications
  final response = await client
    .from('applications')
    .select()
    .order('created_at', ascending: false)
    .range(offset, offset + limit - 1);
    
  return response;
}
```

### 7. Admin App Display

**Location**: `admin_app/lib/screens/applications_screen.dart`

The admin sees:
- List of all applications
- Status badges (pending, in_progress, completed)
- Applicant details
- Action buttons (change status, view details, delete)

**Provider Pattern**:
```dart
// Using Riverpod for state management
final applicationsProvider = FutureProvider((ref) async {
  final service = ref.watch(supabaseServiceProvider);
  return await service.getApplications();
});
```

### 8. Admin Actions

When admin updates status:

```dart
// Update in database
await client.from('applications')
  .update({
    'status': 'in_progress',
    'updated_at': DateTime.now(),
  })
  .eq('id', applicationId);

// Create audit trail
await client.from('audit_trail').insert({
  'application_id': applicationId,
  'action': 'status_updated',
  'changes': {'status': 'in_progress'},
});
```

## Data Flow Summary

```
1. User fills form → wizardProvider stores answers
2. Submit button → collect all data
3. SupabaseService.submitLead() → INSERT to database
4. Supabase applies RLS policies
5. Admin logs in → creates authenticated session
6. Admin app fetches → SELECT with auth token
7. Data displayed in admin dashboard
8. Admin updates → UPDATE with audit trail
```

## Key Components

### Main App
- **Wizard State**: `providers/wizard_provider.dart`
- **Submission**: `screens/contact_screen.dart`
- **Supabase Client**: `services/supabase_service.dart`

### Database
- **Table**: `applications`
- **View**: `application_stats`
- **Audit**: `audit_trail`
- **RLS**: Row Level Security policies

### Admin App
- **Auth**: `services/auth_service.dart`
- **Data Fetch**: `services/supabase_service.dart`
- **Display**: `screens/applications_screen.dart`
- **State**: `providers/supabase_application_provider.dart`

## Security Flow

1. **Main App**: Uses `anon` key (public)
   - Can only INSERT new applications
   - Cannot read or modify existing data

2. **Admin App**: Uses authenticated session
   - Must login with email/password
   - Gets JWT token with user claims
   - Can SELECT/UPDATE/DELETE based on RLS

3. **RLS Policies**:
   ```sql
   -- Anon can submit
   CREATE POLICY "anon_insert" ON applications
   FOR INSERT TO anon WITH CHECK (true);
   
   -- Authenticated can manage
   CREATE POLICY "auth_select" ON applications
   FOR SELECT TO authenticated USING (true);
   ```

## Testing the Workflow

### 1. Submit Test Application (Main App)
```bash
# Run main app
cd 행정도우미
flutter run -d chrome --web-port 8080
```
- Fill out the wizard
- Submit with test contact info

### 2. Verify in Database
- Go to Supabase Dashboard
- Check `applications` table
- New row should appear with status='pending'

### 3. Check in Admin App
```bash
# Run admin app
cd admin_app
./run_admin.sh
```
- Login with admin credentials
- Go to Applications screen
- New submission should be visible

### 4. Update Status
- Click status dropdown
- Change to 'in_progress'
- Check audit_trail table for record

## Troubleshooting

### Application Not Showing in Admin
1. Check RLS policies allow authenticated SELECT
2. Verify admin is logged in (check session)
3. Check browser console for 401/403 errors

### Submission Fails
1. Check Supabase URL and anon key
2. Verify RLS allows anon INSERT
3. Check network connectivity

### Admin Can't Update
1. Ensure authenticated session exists
2. Check UPDATE policy for authenticated role
3. Verify no constraint violations

## Environment Variables

### Main App
```dart
// 행정도우미/lib/config/env.dart
SUPABASE_URL=https://xgmswifetbmttyrtzjpv.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...
```

### Admin App
```dart
// admin_app/lib/config/env.dart
SUPABASE_URL=https://xgmswifetbmttyrtzjpv.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...
SUPABASE_SERVICE_KEY=eyJhbGc... (optional)
```

## Real-time Updates (Future Enhancement)

Supabase supports real-time subscriptions:

```dart
// Listen for new applications
client
  .from('applications')
  .stream(primaryKey: ['id'])
  .listen((List<Map<String, dynamic>> data) {
    // Update UI with new data
  });
```

This would allow the admin app to automatically refresh when new applications are submitted.