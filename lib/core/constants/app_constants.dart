/// App-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'SmartCart AI';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Your Intelligent Shopping Companion';

  // Hive Box Names
  static const String groceryBoxName = 'grocery_items';
  static const String settingsBoxName = 'app_settings';
  static const String historyBoxName = 'shopping_history';

  // Hive Type IDs
  static const int groceryItemTypeId = 0;
  static const int categoryTypeId = 1;

  // Settings Keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyMLEnabled = 'ml_enabled';
  static const String keyHapticEnabled = 'haptic_enabled';

  // ML Model
  static const String mlModelPath = 'assets/ml_models/category_classifier.tflite';
  static const String mlLabelsPath = 'assets/ml_models/labels.txt';

  // Animation Assets
  static const String micAnimationPath = 'assets/animations/microphone.json';
  static const String successAnimationPath = 'assets/animations/success.json';
  static const String emptyStateAnimationPath = 'assets/animations/empty_state.json';

  // Greeting Messages
  static const List<String> morningGreetings = [
    'Good morning! 🌅',
    'Rise and shine! ☀️',
    'Morning! Ready to shop? 🛒',
  ];

  static const List<String> afternoonGreetings = [
    'Good afternoon! 👋',
    'Hello there! 🌤️',
    'Afternoon! What\'s on the list? 📝',
  ];

  static const List<String> eveningGreetings = [
    'Good evening! 🌆',
    'Evening! Let\'s plan dinner 🍽️',
    'Hey there! Ready to shop? 🌙',
  ];

  static const List<String> nightGreetings = [
    'Good night! 🌙',
    'Late night shopping? 🌃',
    'Planning ahead? Great! ⭐',
  ];

  // Empty State Messages
  static const String emptyListTitle = 'Your list is empty';
  static const String emptyListSubtitle = 'Tap the mic button to add items with your voice';
  static const String emptyHistoryTitle = 'No shopping history yet';
  static const String emptyHistorySubtitle = 'Complete your first shopping trip to see analytics';

  // Voice Commands
  static const List<String> voiceHints = [
    'Try saying "Add milk"',
    'Say "2 apples"',
    'Try "Add bread and butter"',
  ];

  // Suggestion Messages
  static const List<String> suggestionPrompts = [
    'You often buy these together:',
    'Don\'t forget:',
    'Frequently purchased with:',
    'You might need:',
  ];
}
