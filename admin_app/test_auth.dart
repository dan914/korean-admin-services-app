import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://xgmswifetbmttyrtzjpv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhnbXN3aWZldGJtdHR5cnR6anB2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQyMDYwMjksImV4cCI6MjA2OTc4MjAyOX0.Cqwsvm9IIU56HVvtyOlBrZBu8PJ4ZO3fDvXOqCHwJ5E',
  );

  final client = Supabase.instance.client;
  
  print('Testing Supabase connection...');
  print('Supabase URL: ${client.supabaseUrl}');
  
  // Test 1: Try to fetch from applications without auth
  print('\n1. Testing SELECT without authentication:');
  try {
    final response = await client
        .from('applications')
        .select()
        .limit(1);
    print('✅ SELECT succeeded without auth (RLS may allow anon reads)');
    print('Response: $response');
  } catch (e) {
    print('❌ SELECT failed without auth: $e');
  }

  // Test 2: Try to sign in with test credentials
  print('\n2. Testing sign in with admin credentials:');
  try {
    // Note: Replace with actual admin credentials
    final authResponse = await client.auth.signInWithPassword(
      email: 'admin@example.com',
      password: 'Admin123!@#',
    );
    
    if (authResponse.session != null) {
      print('✅ Sign in successful');
      print('User: ${authResponse.user?.email}');
      print('Session: ${authResponse.session?.accessToken?.substring(0, 20)}...');
      
      // Test 3: Try to fetch with auth
      print('\n3. Testing SELECT with authentication:');
      try {
        final response = await client
            .from('applications')
            .select()
            .limit(1);
        print('✅ SELECT succeeded with auth');
        print('Response: $response');
      } catch (e) {
        print('❌ SELECT failed with auth: $e');
      }
      
      // Sign out
      await client.auth.signOut();
      print('\n✅ Signed out successfully');
    }
  } catch (e) {
    print('❌ Sign in failed: $e');
    print('Make sure to create an admin user in Supabase Auth first');
  }
}