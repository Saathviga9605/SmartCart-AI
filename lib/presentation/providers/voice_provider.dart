import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

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
          onError: (error) {
            debugPrint('Speech error: $error');
            _handleError(error.errorMsg);
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

  /// Parse voice input into grocery items
  /// Handles commands like "add milk", "2 apples", "bread and butter"
  List<Map<String, dynamic>> parseVoiceInput(String text) {
    final List<Map<String, dynamic>> items = [];
    
    if (text.isEmpty) return items;

    // Clean up the text
    String cleanText = text.toLowerCase().trim();
    
    // Remove common prefixes
    cleanText = cleanText.replaceAll(RegExp(r'^(add|get|buy|need)\s+'), '');
    
    // Split by "and" or commas
    final parts = cleanText.split(RegExp(r'\s+and\s+|,\s*'));
    
    for (final part in parts) {
      final trimmedPart = part.trim();
      if (trimmedPart.isEmpty) continue;

      // Try to extract quantity
      final quantityMatch = RegExp(r'^(\d+)\s+(.+)').firstMatch(trimmedPart);
      
      if (quantityMatch != null) {
        items.add({
          'name': quantityMatch.group(2)!.trim(),
          'quantity': int.parse(quantityMatch.group(1)!),
        });
      } else {
        items.add({
          'name': trimmedPart,
          'quantity': 1,
        });
      }
    }

    return items;
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
