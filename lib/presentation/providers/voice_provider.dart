import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../../data/datasources/api_service.dart';

/// Provider for managing voice input state
/// Handles speech-to-text operations and voice command parsing
class VoiceProvider with ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isListening = false;
  bool _isAvailable = false;
  String _recognizedText = '';
  String _status = 'Tap to speak';
  double _confidence = 0.0;

  // Getters
  bool get isListening => _isListening;
  bool get isAvailable => _isAvailable;
  String get recognizedText => _recognizedText;
  String get status => _status;
  double get confidence => _confidence;

  /// Initialize speech recognition
  Future<void> initialize() async {
    try {
      // Request microphone permission
      final permissionStatus = await Permission.microphone.request();
      
      if (permissionStatus.isGranted) {
        _isAvailable = await _speech.initialize(
          onStatus: (status) {
            debugPrint('Speech status: $status');
            _updateStatus(status);
          },
          onError: (dynamic val) {
            debugPrint('Speech error: $val');
            String msg = 'Unknown error';
            try {
              if (val.runtimeType.toString() == 'SpeechRecognitionError') {
                 msg = (val as dynamic).errorMsg;
              } else if (val.toString().contains('Event') || val.toString() == "[object Event]") {
                 msg = 'No speech detected or permission denied';
              } else {
                 msg = val.toString();
              }
            } catch (e) {
              msg = 'Speech error occurred';
            }
            _handleError(msg);
          },
        );
        
        notifyListeners();
      } else {
        _status = 'Microphone permission denied';
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error initializing speech: $e');
      _status = 'Failed to initialize';
      notifyListeners();
    }
  }

  /// Start listening
  Future<void> startListening() async {
    if (!_isAvailable) {
      await initialize();
    }

    if (_isAvailable && !_isListening) {
      _recognizedText = '';
      _status = 'Listening...';
      _isListening = true;
      notifyListeners();

      await _speech.listen(
        onResult: (result) {
          _recognizedText = result.recognizedWords;
          _confidence = result.confidence;
          
          if (result.finalResult) {
            _status = 'Processing...';
          }
          
          notifyListeners();
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          listenMode: stt.ListenMode.confirmation,
        ),
      );
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
      _status = _recognizedText.isEmpty ? 'No speech detected' : 'Done!';
      notifyListeners();
    }
  }

  /// Cancel listening
  Future<void> cancelListening() async {
    if (_isListening) {
      await _speech.cancel();
      _isListening = false;
      _recognizedText = '';
      _status = 'Cancelled';
      notifyListeners();
    }
  }

  /// Parse voice input into grocery items using Backend API
  Future<List<Map<String, dynamic>>> parseVoiceInput(String text) async {
    if (text.isEmpty) return [];

    try {
      final apiService = ApiService();
      final result = await apiService.extractIngredients(text);
      
      final List<dynamic> ingredients = result['ingredients'] ?? [];
      final Map<String, dynamic> categories = Map<String, dynamic>.from(result['categories'] ?? {});
      
      return ingredients.map((name) {
        return {
          'name': name.toString(),
          'quantity': 1, // API currently doesn't parse quantity, defaulting to 1
          'category': categories[name] // heuristic or ML category
        };
      }).toList();
    } catch (e) {
      debugPrint('Error parsing via API: $e');
      return [];
    }
  }

  /// Update status based on speech recognition status
  void _updateStatus(String speechStatus) {
    switch (speechStatus) {
      case 'listening':
        _status = 'Listening...';
        break;
      case 'notListening':
        _isListening = false;
        _status = _recognizedText.isEmpty ? 'Tap to speak' : 'Done!';
        break;
      case 'done':
        _isListening = false;
        _status = 'Done!';
        break;
      default:
        _status = speechStatus;
    }
    notifyListeners();
  }

  /// Handle speech recognition errors
  void _handleError(String error) {
    _isListening = false;
    _status = 'Error: $error';
    notifyListeners();
  }

  /// Reset state
  void reset() {
    _recognizedText = '';
    _status = 'Tap to speak';
    _confidence = 0.0;
    _isListening = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
  }
}
