# 🛒 SmartCart AI

> **Your Intelligent Shopping Companion** - A portfolio-grade Smart Grocery List App with AI-powered features, premium animations, and clean architecture.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Features

### 🎤 Voice-Powered Input
- **Hands-free grocery management** with speech-to-text
- Real-time transcription with confidence scoring
- Smart parsing of quantities and multiple items
- Beautiful glassmorphic voice overlay with waveform animation

### 🧠 AI-Powered Categorization
- **On-device ML inference** using TensorFlow Lite
- Automatic category prediction for grocery items
- 8 categories: Fruits, Vegetables, Dairy, Meat, Bakery, Beverages, Snacks, Other
- Smart suggestions based on purchase patterns

### 🎨 Premium UI/UX
- **Glassmorphism** and soft neumorphism design
- Pastel-dark hybrid theme for calm yet vibrant aesthetic
- Smooth animations everywhere:
  - Pulse animations on mic button
  - Checkbox animations with haptic feedback
  - Category expand/collapse transitions
  - Swipe-to-delete gestures
  - Hero animations between screens
- Google Fonts (Poppins) for modern typography

### 📱 Core Functionality
- ✅ Add items via voice or manual input
- ✅ Organize by category with expandable cards
- ✅ Mark items as done with animated checkboxes
- ✅ Edit/delete with long-press menu
- ✅ Quantity tracking with stepper
- ✅ Notes for special requirements
- ✅ Pull-to-refresh
- ✅ Offline-first with Hive database

### 📊 Smart Features
- Shopping history tracking
- Analytics and insights
- Frequently bought items
- Category distribution
- Smart suggestions (placeholder for ML)

## 🏗️ Architecture

### Clean Architecture (3-Layer)

```
lib/
├── core/                    # Shared utilities
│   ├── theme/              # Design system
│   ├── animations/         # Reusable animations
│   └── constants/          # App constants
├── data/                    # Data layer
│   ├── models/             # Hive models
│   ├── datasources/        # Local database
│   └── repositories/       # Repository implementations
├── domain/                  # Business logic
│   ├── entities/           # Domain entities
│   ├── usecases/           # Use cases
│   └── repositories/       # Repository interfaces
└── presentation/            # UI layer
    ├── providers/          # State management (Provider)
    ├── screens/            # App screens
    └── widgets/            # Reusable widgets
```

### State Management
- **Provider** for reactive state management
- Clean separation of concerns
- No business logic in widgets
- Efficient rebuilds with Consumer widgets

### Local Database
- **Hive** for fast, lightweight NoSQL storage
- Type-safe with code generation
- Offline-first approach
- Automatic persistence

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0 or higher
- Dart 3.0 or higher
- Android Studio / VS Code
- Android SDK / Xcode (for iOS)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/smartcart-ai.git
cd smartcart-ai
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Generate Hive adapters**
```bash
flutter packages pub run build_runner build
```

4. **Run the app**
```bash
flutter run
```

## 📦 Dependencies

### Core
- `provider: ^6.1.1` - State management
- `hive: ^2.2.3` - Local database
- `hive_flutter: ^1.1.0` - Hive Flutter integration

### Features
- `speech_to_text: ^6.6.0` - Voice input
- `permission_handler: ^11.1.0` - Permissions
- `tflite_flutter: ^0.10.4` - ML inference

### UI/UX
- `google_fonts: ^6.1.0` - Typography
- `lottie: ^3.0.0` - Animations
- `flutter_animate: ^4.5.0` - Micro-interactions

### Utilities
- `uuid: ^4.3.3` - Unique IDs
- `intl: ^0.19.0` - Internationalization

## 🎨 Design System

### Colors
- **Primary**: Soft Indigo/Violet (#6366F1 → #8B5CF6)
- **Accent**: Mint/Teal (#10B981 → #14B8A6)
- **Success**: Soft Green (#34D399)
- **Background**: Slate-900 (#0F172A)

### Typography
- **Font Family**: Poppins
- **Hierarchy**:
  - Display: 24-32px, Bold
  - Title: 16-22px, Semi-bold
  - Body: 12-16px, Regular
  - Label: 10-14px, Medium

### Spacing
- XSmall: 4px
- Small: 8px
- Medium: 16px
- Large: 24px
- XLarge: 32px

## 🧪 ML Pipeline (Placeholder)

### Training
```bash
cd ml
pip install -r requirements.txt
python training/train_classifier.py
```

### Convert to TFLite
```bash
python export/convert_to_tflite.py
```

### Integration
1. Place `.tflite` model in `assets/ml_models/`
2. Update `pubspec.yaml` assets
3. Model loads automatically on app start

## 🔧 Backend API (Placeholder)

### Setup
```bash
cd backend
pip install -r requirements.txt
python app.py
```

### Endpoints
- `GET /health` - Health check
- `POST /api/user/sync` - Sync grocery list
- `GET /api/analytics` - User analytics
- `GET /api/suggestions` - Smart suggestions

## 📱 Screens

### 1. Splash Screen
- Animated logo with shimmer effect
- Smooth fade-in transitions
- Auto-navigation to home

### 2. Home Screen ⭐ (Core)
- Time-based greeting
- Category-grouped items
- Floating mic button with pulse
- Pull-to-refresh
- Empty state with hints

### 3. Voice Input Overlay
- Full-screen glassmorphic design
- Pulsating mic animation
- Real-time transcription
- Waveform visualization
- Confidence indicator

### 4. Add/Edit Item Screen
- Manual item entry
- ML-powered category prediction
- Quantity stepper
- Notes field
- Form validation

### 5. Settings Screen
- Dark/Light theme toggle
- Clear data options
- ML model status
- App information

## 🎯 Key Highlights

### For Portfolio/Resume
✅ **Clean Architecture** - Demonstrates professional code organization  
✅ **State Management** - Provider pattern with reactive UI  
✅ **Animations** - Custom animations and micro-interactions  
✅ **ML Integration** - On-device inference with TFLite  
✅ **Voice Features** - Speech-to-text with smart parsing  
✅ **Premium Design** - Glassmorphism, gradients, shadows  
✅ **Offline-First** - Local database with Hive  
✅ **Scalable** - Backend-ready architecture  

### Code Quality
- 📝 Comprehensive comments explaining decisions
- 🎨 Consistent naming conventions
- 🔧 Modular and reusable components
- 🧪 Production-grade structure
- 📊 Clear separation of concerns

## 🚧 Future Enhancements

- [ ] Cloud sync with backend API
- [ ] Collaborative shopping lists
- [ ] Barcode scanning
- [ ] Price tracking
- [ ] Recipe integration
- [ ] Shopping reminders
- [ ] Multi-language support
- [ ] Dark/Light theme variants
- [ ] Export to PDF
- [ ] Widget for home screen

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Your Name**
- Portfolio: [yourportfolio.com](https://yourportfolio.com)
- LinkedIn: [linkedin.com/in/yourprofile](https://linkedin.com/in/yourprofile)
- GitHub: [@yourusername](https://github.com/yourusername)

## 🙏 Acknowledgments

- Design inspiration from Google Material Design 3
- Animation concepts from Apple Human Interface Guidelines
- ML architecture from TensorFlow Lite examples
- Flutter community for amazing packages

---

<p align="center">Made with ❤️ for smart shopping</p>
<p align="center">⭐ Star this repo if you find it helpful!</p>
