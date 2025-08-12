#!/bin/bash

# Make sure we're in the right directory
cd "$(dirname "$0")"

# Run Flutter with Supabase credentials
flutter run -d chrome --web-port 8080 \
  --dart-define=SUPABASE_URL=https://xgmswifetbmttyrtzjpv.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhnbXN3aWZldGJtdHR5cnR6anB2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQyMDYwMjksImV4cCI6MjA2OTc4MjAyOX0.Cqwsvm9IIU56HVvtyOlBrZBu8PJ4ZO3fDvXOqCHwJ5E