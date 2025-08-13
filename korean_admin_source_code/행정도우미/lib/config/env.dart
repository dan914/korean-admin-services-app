class Env {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://xgmswifetbmttyrtzjpv.supabase.co',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhnbXN3aWZldGJtdHR5cnR6anB2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQyMDYwMjksImV4cCI6MjA2OTc4MjAyOX0.Cqwsvm9IIU56HVvtyOlBrZBu8PJ4ZO3fDvXOqCHwJ5E',
  );
  
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}