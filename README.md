# 💰 Offline Expense Tracker

A beautiful, feature-rich Flutter application for tracking expenses offline with personalized notifications and comprehensive analytics.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)

## ✨ Features

### 🎯 Core Features
- **Offline Expense Tracking** - Track expenses without internet connection
- **Income & Expense Management** - Categorized transaction management
- **Multi-Currency Support** - Support for 10+ currencies (PHP, USD, EUR, etc.)
- **Beautiful Charts & Analytics** - Visual representation of spending patterns
- **Home Widgets** - Quick access to balance and recent transactions

### 🔔 Smart Notifications (v1.2.0)
- **Personalized Low Balance Alerts** - Custom notifications with user's name
- **Customizable Threshold** - Set your own low balance warning amount
- **Custom Messages** - Personalize notification messages with placeholders
- **Smart Notification Logic** - Prevents spam with intelligent triggering

### 🎨 User Experience
- **Animated Splash Screen** - Beautiful app launch experience
- **Material Design 3** - Modern, clean interface
- **Dark/Light Theme Support** - Adapts to system preferences
- **Intuitive Navigation** - Easy-to-use bottom navigation

### ⚙️ Advanced Features
- **First-Time Setup** - Guided user onboarding
- **Version History** - Clickable version information with detailed changelog
- **Data Management** - Export/import and reset functionality
- **Settings Customization** - Comprehensive app configuration


## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.7.2)
- Dart SDK
- Android Studio / VS Code
- Android device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Allain-afk/ExpenseTracker.git
   cd ExpenseTracker
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Release

```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

## 📦 Dependencies

### Core Dependencies
- `flutter` - UI framework
- `provider` - State management
- `sqflite` - Local database
- `shared_preferences` - Local storage
- `intl` - Internationalization

### UI & Animation
- `fl_chart` - Beautiful charts
- `animated_splash_screen` - Splash screen animations
- `flutter_native_splash` - Native splash screen

### Notifications & Widgets
- `flutter_local_notifications` - Local notifications
- `permission_handler` - Permission management
- `home_widget` - Home screen widgets

### Utilities
- `path_provider` - File system paths
- `path` - Path manipulation

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── settings.dart
│   └── transaction.dart
├── providers/                # State management
│   ├── settings_provider.dart
│   └── transaction_provider.dart
├── screens/                  # UI screens
│   ├── splash_screen.dart
│   ├── user_setup_screen.dart
│   ├── main_navigation_screen.dart
│   ├── home_screen.dart
│   ├── add_transaction_screen.dart
│   ├── transactions_screen.dart
│   └── settings_screen.dart
├── services/                 # Business logic
│   ├── notification_service.dart
│   └── widget_service.dart
├── database/                 # Database layer
│   └── database_helper.dart
├── utils/                    # Utilities
└── widgets/                  # Reusable widgets
```

## 📋 Version History

### v1.2.0 (Latest) 🆕
- **New user UI/UX functionalities**
- Added notification system for low budget threshold
- Personalized notifications with user name
- Customizable notification settings
- First-time user setup flow

### v1.0.3
- **App Animation Feature (Splash Screen)**
- Beautiful animated splash screen
- Smooth transitions and loading animations

### v1.0.2
- **UI and UX Improvements**
- Enhanced user interface design
- Better user experience
- Performance optimizations

### v1.0.1
- **App Icon Update**
- New and improved app icon
- Better visual identity

### v1.0.0 (Deprecated)
- **Basic Features for Expense Tracking**
- Core expense tracking functionality
- Transaction management
- Basic reporting features

## 🛠️ Development

### Setting up Development Environment

1. **Install Flutter**
   - Follow the [official Flutter installation guide](https://flutter.dev/docs/get-started/install)

2. **Configure IDE**
   - Install Flutter and Dart plugins for your IDE
   - Configure code formatting and linting

3. **Run in Debug Mode**
   ```bash
   flutter run --debug
   ```

### Code Style
- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter format` for consistent formatting
- Run `flutter analyze` for static analysis

### Testing
```bash
# Run unit tests
flutter test

# Run integration tests
flutter drive --target=test_driver/app.dart
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Developer

**Allain Ralph Legaspi**
- GitHub: [@Allain-afk](https://github.com/Allain-afk)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design for the design system
- All contributors and testers

---

**Made with ❤️ using Flutter**
