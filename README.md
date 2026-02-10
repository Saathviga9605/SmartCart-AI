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

Follow these steps to set up and run the project on your local machine.

### 1. Prerequisites
- **Flutter SDK**: 3.0 or higher
- **Python**: 3.9 or higher
- **Git**

### 2. Backend Setup (Python)
The backend handles AI ingredient extraction and smart recommendations.

```bash
# Navigate to backend directory
cd backend

# Create a virtual environment
python -m venv venv

# Activate virtual environment
# On Windows:
venv\Scripts\activate
# On Mac/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run the backend server
python app.py
```
> [!NOTE]
> The backend runs on `http://localhost:5000` by default. Keep this terminal running.

### 3. Frontend Setup (Flutter)
The frontend is the mobile application.

```bash
# Return to the root directory (if you're in /backend)
cd ..

# Install Flutter dependencies
flutter pub get

# Generate data models (Hive)
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app (Chrome/Android/iOS)
flutter run -d chrome
```

---

## 🏗️ Architecture
### Frontend (Flutter)
- **State Management**: Provider
- **Local Database**: Hive (Offline-first)
- **Design**: Material 3 with Custom Glassmorphic components
- **ML**: TFLite for on-device categorization

### Backend (Flask)
- **Intelligence**: Custom NLP for ingredient extraction
- **Recommendations**: Association-rule mining and ML-based project picks
- **Dataset**: Enriched 400+ item grocery database

---

## ✨ Highlights
- 🎤 **Voice-to-List**: Instant item addition via voice with automatic quantity sensing.
- 🧪 **AI Smart Picks**: Context-aware suggestions based on what's currently in your cart.
- 🥘 **Recipe Matching**: Dynamic recipes that adapt based on your grocery list.
- 📊 **Quick History**: One-tap re-add from previous shopping trips.
- 🔢 **Direct Quantity Edit**: Quickly adjust item counts directly from the main list.
