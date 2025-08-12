# 행정도우미 - Administrative Agent Consulting App

Flutter MVP implementation of an administrative consulting wizard application.

## Features

- ✅ 10-step wizard with conditional sub-steps
- ✅ Auto-save drafts with deep-link resume capability
- ✅ Soft Neutral design theme with accessibility focus
- ✅ Atomic component library with Widgetbook
- ✅ Lead submission to Supabase
- ✅ Success screen with animations
- ✅ Supabase integration with audit trail
- ✅ Offline mode support
- 🚧 Admin dashboard (pending)
- 🚧 Notification webhooks (pending)

## Design System

- **Primary Color**: #2C61C1
- **Body Text**: 20pt for accessibility
- **Touch Targets**: Minimum 48px
- **Contrast**: AA compliant

## Project Structure

```
lib/
├── main.dart                 # App entry point with routing
├── ui/
│   ├── design_tokens.dart   # Design system tokens
│   └── app_theme.dart       # Flutter theme configuration
├── widgets/                  # Atomic components
│   ├── app_button.dart
│   ├── radio_option.dart
│   ├── step_card.dart
│   ├── progress_bar.dart
│   └── answer_card.dart
├── screens/                  # App screens
│   ├── wizard_screen.dart
│   ├── summary_screen.dart
│   ├── contact_screen.dart
│   └── success_screen.dart
├── data/
│   └── steps.dart           # Wizard step definitions
├── providers/
│   └── wizard_provider.dart # State management
├── services/
│   └── draft_service.dart   # Auto-save functionality
└── widgetbook.dart          # Component showcase
```

## Getting Started

1. Install Flutter SDK (3.22+)

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Supabase (optional):
   - See [SUPABASE_SETUP.md](./SUPABASE_SETUP.md) for detailed setup instructions
   - Run with environment variables:
```bash
flutter run --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key
```

4. Run the app:
```bash
flutter run
```
   Note: The app will run in offline mode if Supabase is not configured.

5. Run Widgetbook:
```bash
flutter run -t lib/widgetbook.dart
```

## State Management

Uses Riverpod for state management with:
- `wizardProvider`: Manages wizard state and navigation
- `autoSaveProvider`: Handles automatic draft saving
- `draftLoaderProvider`: Loads saved drafts on app start

## Draft Auto-Save

- Saves to SharedPreferences on every state change
- Drafts expire after 7 days
- Includes deep-link support for resuming drafts

## Supabase Integration

The app integrates with Supabase for:
- ✅ Lead submission with contact info
- ✅ Audit trail with blockchain-style hashing
- ✅ Offline mode fallback
- 🚧 Draft persistence (coming soon)
- 🚧 Admin dashboard data (coming soon)
- 🚧 Notification webhooks (coming soon)

See [SUPABASE_SETUP.md](./SUPABASE_SETUP.md) for detailed setup instructions.

## Accessibility

- Minimum body text: 20pt
- Touch targets: 48x48dp minimum
- Color contrast: AA compliant
- Supports text scaling up to 1.3x

## Testing

Run tests:
```bash
flutter test
```

Run golden tests:
```bash
flutter test --update-goldens
```

## Build

### iOS
```bash
flutter build ios
```

### Android
```bash
flutter build apk
```

### Web
```bash
flutter build web
```

## Next Steps

1. ~~Complete Supabase integration~~ ✅
2. Implement admin dashboard
3. Add notification webhooks
4. Set up CI/CD with GitHub Actions
5. Add comprehensive test coverage
6. Implement draft persistence to Supabase
7. Add real-time updates for admin dashboard