# 🚀 SmartCart AI - Quick Start Guide

Get the app running in 5 minutes!

## Prerequisites

- Flutter SDK 3.0+ ([Install Flutter](https://docs.flutter.dev/get-started/install))
- Dart 3.0+
- Android Studio or VS Code
- Android SDK (for Android) or Xcode (for iOS)

## Installation Steps

### 1. Clone & Navigate

```bash
cd SMARTPANTRY
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Generate Code (Hive Adapters)

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

This generates:
- `grocery_item_model.g.dart`
- `category_model.g.dart`

### 4. Run the App

```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For Web
flutter run -d chrome
```

## 🎯 First Launch

When you first run the app:

1. **Splash Screen** appears (2.5s)
2. **Home Screen** loads with empty state
3. Tap the **floating mic button** to try voice input
4. Or tap the **+ button** to add items manually

## 🎤 Testing Voice Input

### Grant Permissions

On first voice input:
- Android: Microphone permission dialog
- iOS: Microphone permission dialog

### Try These Commands

```
"Add milk"
"2 apples"
"bread and butter"
"Add chicken, rice, and tomatoes"
```

The app will:
1. Transcribe your speech
2. Parse items and quantities
3. Predict categories using ML
4. Add to your list

## 🧪 Testing Features

### Add Items
- **Voice**: Tap mic button → Speak → Items added automatically
- **Manual**: Tap + button → Fill form → Save

### Manage Items
- **Mark Done**: Tap checkbox
- **Edit**: Long-press item → Edit
- **Delete**: Swipe left or long-press → Delete

### Categories
- Items auto-grouped by category
- Tap category header to expand/collapse
- Each category has unique color and icon

### Settings
- Tap settings icon (top right)
- Toggle dark/light theme
- Clear all items
- View app info

## 📱 Supported Platforms

✅ **Android** (API 21+)  
✅ **iOS** (iOS 12+)  
⚠️ **Web** (Voice input limited)  
⚠️ **Desktop** (Not optimized)

## 🐛 Troubleshooting

### Build Runner Fails

```bash
flutter clean
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Hive Error

```bash
# Delete app data and reinstall
flutter clean
flutter run
```

### Voice Input Not Working

1. Check microphone permissions in device settings
2. Ensure device has internet (for speech-to-text)
3. Try on physical device (emulator may have issues)

### Missing Dependencies

```bash
flutter doctor
flutter pub get
```

## 🔧 Development Tips

### Hot Reload

Press `r` in terminal for hot reload  
Press `R` for hot restart

### Debug Mode

```bash
flutter run --debug
```

### Release Build

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release
```

### View Logs

```bash
flutter logs
```

## 📂 Project Structure

```
lib/
├── main.dart              # App entry point
├── core/                  # Theme, animations, constants
├── data/                  # Models, database, repositories
├── domain/                # Business logic
└── presentation/          # UI (screens, widgets, providers)
```

## 🎨 Customization

### Change Theme Colors

Edit [app_colors.dart](file:///d:/SMARTPANTRY/lib/core/theme/app_colors.dart):

```dart
static const Color primaryMain = Color(0xFF8B5CF6); // Your color
```

### Add New Category

Edit [category_model.dart](file:///d:/SMARTPANTRY/lib/data/models/category_model.dart):

```dart
enum GroceryCategory {
  // ... existing
  yourCategory,
}
```

### Modify Animations

Edit [animation_constants.dart](file:///d:/SMARTPANTRY/lib/core/animations/animation_constants.dart):

```dart
static const Duration durationNormal = Duration(milliseconds: 300);
```

## 📚 Learn More

- [Full README](file:///d:/SMARTPANTRY/README.md)
- [Implementation Walkthrough](file:///C:/Users/HP/.gemini/antigravity/brain/17042ded-b528-4344-9812-8b84aec4e720/walkthrough.md)
- [ML Pipeline Guide](file:///d:/SMARTPANTRY/ml/README.md)

## 🆘 Need Help?

- Check [Flutter Docs](https://docs.flutter.dev/)
- Review code comments (every file is documented)
- Check provider implementations for state management examples

## ✅ Verification Checklist

After setup, verify:

- [ ] App launches without errors
- [ ] Splash screen shows
- [ ] Home screen loads
- [ ] Can add items manually
- [ ] Voice input works (on device)
- [ ] Items grouped by category
- [ ] Checkbox animations work
- [ ] Swipe to delete works
- [ ] Settings screen accessible
- [ ] Theme toggle works

## 🎉 You're Ready!

Start building your grocery list with voice commands and enjoy the premium UI experience!

---

**Next Steps:**
1. Explore the codebase
2. Try all features
3. Customize colors/theme
4. Add your own features
5. Deploy to app stores

Happy coding! 🚀
