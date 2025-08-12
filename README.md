# 행정도우미 - Korean Administrative Services App

A comprehensive Flutter application for Korean administrative and legal consultation services, featuring a user-friendly wizard interface and separate admin panel.

## 📱 Project Structure

```
행정사/
├── 행정도우미/          # Main client application
│   ├── lib/
│   │   ├── screens/     # UI screens
│   │   ├── providers/   # State management
│   │   ├── models/      # Data models
│   │   ├── services/    # Backend services
│   │   └── widgets/     # Reusable components
│   └── pubspec.yaml
│
├── admin_app/           # Admin panel application
│   ├── lib/
│   │   ├── screens/     # Admin screens
│   │   ├── providers/   # Admin state management
│   │   └── ui/          # Design system
│   └── pubspec.yaml
│
└── ADMIN_ACCESS.md      # Admin access documentation
```

## 🚀 Features

### Main App (행정도우미)
- **Smart Wizard System**: 10-step guided questionnaire for legal consultation
- **Terms & Consent**: Comprehensive legal disclaimers and consent forms
- **Reservation System**: Dual time-slot selection for consultations
- **Contact Information**: Secure collection of user details
- **Memo System**: Additional information capture
- **Mobile-First Design**: Optimized for Android and iOS devices
- **Korean Localization**: Full Korean language support

### Admin App
- **Dashboard**: Real-time statistics and overview
- **Application Management**: View, filter, and manage submissions
- **Webhook Integration**: Automated notifications to Slack/Discord
- **Data Export**: CSV and JSON export capabilities
- **Secure Authentication**: Protected admin access

## 🛠️ Tech Stack

- **Framework**: Flutter 3.5.4+
- **State Management**: Riverpod
- **Navigation**: Go Router
- **Backend**: Supabase (ready for integration)
- **Localization**: Flutter Localizations
- **Database**: SharedPreferences (local), Supabase (cloud-ready)

## 📋 Prerequisites

- Flutter SDK 3.5.4 or higher
- Dart SDK 3.5.4 or higher
- iOS: Xcode 14.0+ (for iOS development)
- Android: Android Studio / VS Code with Flutter extension

## 🔧 Installation

### 1. Clone the repository
```bash
git clone [repository-url]
cd 행정사
```

### 2. Install dependencies for main app
```bash
cd 행정도우미
flutter pub get
```

### 3. Install dependencies for admin app
```bash
cd ../admin_app
flutter pub get
```

## 🏃‍♂️ Running the Apps

### Main App
```bash
cd 행정도우미
flutter run
```

### Admin App
```bash
cd admin_app
flutter run
```

## 🔐 Admin Access

For admin panel access instructions, see [ADMIN_ACCESS.md](ADMIN_ACCESS.md)

**Development Credentials:**
- Email: admin@example.com
- Password: admin1234

⚠️ **Important**: Change these credentials before production deployment!

## 📱 Supported Platforms

- ✅ iOS (10.0+)
- ✅ Android (API 21+)
- ✅ Web (Chrome, Safari, Firefox)
- ✅ macOS (10.14+)
- ✅ Windows (10+)
- ✅ Linux (Ubuntu 20.04+)

## 🌐 Environment Setup

Create a `.env` file in the root directory:
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

## 🧪 Testing

```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

## 📦 Building for Production

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## ⚠️ Security Notes

- Never commit sensitive credentials
- Use environment variables for API keys
- Implement proper authentication before production
- Regular security audits recommended

## 📄 License

This project is proprietary and confidential.

## 👥 Contact

For questions or support, please contact the development team.

## 🙏 Acknowledgments

- Flutter team for the excellent framework
- Riverpod for state management
- All contributors and testers

---

**대표 / 행정사: 유병찬**  
유앤유 행정사 사무소