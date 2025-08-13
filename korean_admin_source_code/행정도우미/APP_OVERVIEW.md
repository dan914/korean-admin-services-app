# 행정도우미 App Overview

## Current Implementation Status

The Flutter app for administrative consulting is now set up with the following features:

### ✅ Completed Features

1. **Project Setup**
   - Flutter web support enabled
   - All dependencies installed
   - Runs in offline mode by default

2. **Core Architecture**
   - Multi-step wizard with conditional navigation
   - State management using Riverpod
   - Routing with GoRouter
   - Design system with tokens

3. **Supabase Integration**
   - Lead submission service
   - Audit trail with blockchain-style hashing
   - Offline mode fallback
   - Environment variable configuration

4. **Screens Implemented**
   - Wizard Screen (main flow)
   - Summary Screen (review answers)
   - Contact Screen (collect user info)
   - Success Screen (confirmation)

### 🏃 Running the App

1. **Basic run (offline mode)**:
   ```bash
   flutter run -d chrome
   ```

2. **With Supabase (production mode)**:
   ```bash
   flutter run -d chrome --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key
   ```

3. **Access the app**:
   - Open http://localhost:[port] in your browser
   - The port will be shown in the console output

### 📱 App Flow

1. **Wizard Steps**: Users go through a 10-step questionnaire about their administrative needs
2. **Summary**: Review all answers before proceeding
3. **Contact Info**: Enter name, phone, email, and notification preferences
4. **Submission**: Data is sent to Supabase (or logged in offline mode)
5. **Success**: Confirmation screen with animation

### 🎨 Design System

- Primary Color: #2C61C1 (Blue)
- Body Text: 20pt (accessibility)
- Touch Targets: 48px minimum
- Soft neutral theme with cards and clear hierarchy

### 📁 File Structure

```
lib/
├── main.dart              # App entry & routing
├── config/
│   └── env.dart          # Environment config
├── data/
│   └── steps.dart        # Wizard step definitions
├── providers/
│   └── wizard_provider.dart # State management
├── screens/              # App screens
├── services/
│   ├── draft_service.dart
│   └── supabase_service.dart
├── ui/
│   ├── app_theme.dart
│   └── design_tokens.dart
└── widgets/              # Reusable components
```

### 🔧 Next Steps

1. Add real wizard steps content
2. Implement admin dashboard
3. Add notification webhooks
4. Set up CI/CD
5. Add comprehensive tests
6. Deploy to production

The app is functional and ready for content addition and further development!