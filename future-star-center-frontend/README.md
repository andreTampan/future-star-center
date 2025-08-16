# Future Star Center Admin

Cross-platform Flutter admin app for the Future Star Center child development clinic.

## ✨ Features

- Modern, responsive UI with custom theme based on clinic branding
- Authentication: login, register, password reset, session management
- Provider state management and clean architecture (SOLID principles)
- Persistent storage for tokens and user data
- Robust API integration with Go/Echo backend
- Ready for expansion: patient management, appointments, assessments, etc.

## 🏗️ Project Structure

```
lib/
├── constants/          # App constants and theme
├── models/             # Data models
├── services/           # Business logic layer
├── repositories/       # Data access layer
├── providers/          # State management
├── utils/              # Helper utilities
├── widgets/            # Reusable UI components
├── views/              # UI screens (auth, dashboard, etc.)
└── main.dart           # App entry point
```

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.16+ recommended)
- [Go/Echo backend API](https://github.com/your-org/future-star-center-backend) running on `localhost:8080`

### 1. Install dependencies
```bash
flutter pub get
```

### 2. Run the app
```bash
flutter run -d linux   # or -d chrome, -d android, -d ios
```

### 3. Configure API endpoint
Edit `lib/constants/app_constants.dart` if your backend is not on `localhost:8080`.

## 🔐 Authentication API Endpoints

- `POST   /api/auth/login`
- `POST   /api/auth/register`
- `POST   /api/auth/logout`
- `GET    /api/auth/session`
- `POST   /api/auth/request-password-reset`
- `POST   /api/auth/reset-password`

## 🛠️ Tech Stack

- **Flutter 3.16+** (Material 3, Provider, Google Fonts, Shared Preferences)
- **Go/Echo** backend (see backend repo)
- **MongoDB, Redis** (backend)

## 🎨 Theming & Branding

- Colors and typography extracted from the clinic logo
- Modern, accessible, and responsive design

## 📁 Assets

- Place your logo at `assets/images/future_star_logo.jpg` (not included in this public repository)
- See `assets/images/README_LOGO_PLACEHOLDER.md` for details.

---

## Copyright Notice
The Future Star Center logo and branding are the exclusive property of Future Star Center. Unauthorized use, reproduction, or distribution is strictly prohibited.
- Update `pubspec.yaml` if you add more assets

## 📦 Build & Release for Google Play Store

### 1. Prepare for Release
- Update app name, icon, and package name in `android/app/src/main/AndroidManifest.xml` and `android/app/build.gradle`.
- Set `version` and `versionCode` in `pubspec.yaml`.
- Replace launcher icons in `android/app/src/main/res/mipmap-*`.

### 2. Create a Keystore (first time only)
```bash
keytool -genkey -v -keystore ~/my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-key-alias
```

### 3. Configure Signing
- Create `android/key.properties`:
  ```
  storePassword=your_password
  keyPassword=your_password
  keyAlias=my-key-alias
  storeFile=/path/to/my-release-key.jks
  ```
- Edit `android/app/build.gradle` to use these properties for signing.

### 4. Build the AAB (App Bundle)
```bash
flutter build appbundle --release
```
- The output will be at `build/app/outputs/bundle/release/app-release.aab`.

### 5. Test the Release Build
- Install and test on a real device if possible.

### 6. Upload to Google Play Console
- Register a developer account at https://play.google.com/console
- Create a new app, fill in details, upload screenshots, and upload your `.aab` file.
- Complete the content rating, privacy policy, and store listing.
- Submit for review.

## 🤝 Contributing

Pull requests are welcome! Please follow the existing architecture and style.

## 📄 License

MIT License. See [LICENSE](../LICENSE) for details.

_Made with Flutter & ❤️ for Future Star Center_
