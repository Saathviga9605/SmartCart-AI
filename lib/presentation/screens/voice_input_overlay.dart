import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/animations/custom_animations.dart';
import '../providers/voice_provider.dart';
import '../providers/grocery_provider.dart';
import '../providers/ml_inference_provider.dart';
import '../providers/smartpantry_provider.dart';
import '../providers/recipe_provider.dart';

/// Voice Input Overlay - Full-screen glassmorphic voice interface
/// Premium voice interaction with real-time feedback
class VoiceInputOverlay extends StatefulWidget {
  const VoiceInputOverlay({super.key});

  @override
  State<VoiceInputOverlay> createState() => _VoiceInputOverlayState();
}

class _VoiceInputOverlayState extends State<VoiceInputOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  VoiceProvider? _voiceProvider;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();

    // Start listening automatically
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _voiceProvider = context.read<VoiceProvider>();
      _voiceProvider?.startListening();
      
      // Auto-process listener
      _voiceProvider?.addListener(_onVoiceUpdate);
    });
  }

  void _onVoiceUpdate() {
    final voiceProvider = context.read<VoiceProvider>();
    // If it was listening but now it's done and there's text, auto-process
    if (!voiceProvider.isListening && 
        voiceProvider.recognizedText.isNotEmpty && 
        (voiceProvider.status == 'Done!' || voiceProvider.status == 'Processing...')) {
      _handleClose();
    }
  }

  @override
  void dispose() {
    _voiceProvider?.removeListener(_onVoiceUpdate);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleClose() async {
    if (_isClosing) return;
    _isClosing = true;

    final voiceProvider = context.read<VoiceProvider>();
    
    if (voiceProvider.isListening) {
      await voiceProvider.stopListening();
    }

    // Process recognized text if available
    if (voiceProvider.recognizedText.isNotEmpty) {
      await _processVoiceInput(voiceProvider.recognizedText);
    }

    await _controller.reverse();
    voiceProvider.reset();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _processVoiceInput(String text) async {
    final voiceProvider = context.read<VoiceProvider>();
    final groceryProvider = context.read<GroceryProvider>();
    final mlProvider = context.read<MLInferenceProvider>();
    final pantryProvider = context.read<SmartPantryProvider>();

    // Parse voice input into items
    final parsedItems = await voiceProvider.parseVoiceInput(text);

    // Add each item with ML-predicted category
    for (final itemData in parsedItems) {
      // Use existing ML provider or fallback to API category if valid
      final category = await mlProvider.predictCategory(itemData['name']);
      
      await groceryProvider.addItem(
        name: itemData['name'],
        category: category,
        quantity: itemData['quantity'] ?? 1,
      );
    }

    // Refresh Pantry and Recipes
    final allItems = groceryProvider.activeItems.map((e) => e.name).toList();
    await pantryProvider.refreshFromIngredients(allItems);
    
    // Trigger Recipe Recommendations
    if (mounted) {
       // We can iterate nicely here
       final recipeProvider = context.read<RecipeProvider>();
       recipeProvider.fetchRecommendations(allItems); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _handleClose();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: _handleClose,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundDark.withValues(alpha: 0.95),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: SafeArea(
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Close Button
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: IconButton(
                              onPressed: _handleClose,
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.surfaceDark,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Microphone Animation
                        _buildMicrophoneSection(),
                        
                        const SizedBox(height: 48),
                        
                        // Status Text
                        Consumer<VoiceProvider>(
                          builder: (context, provider, child) {
                            return Text(
                              provider.status,
                              style: AppTextStyles.voiceStatus.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Recognized Text
                        _buildRecognizedText(),
                        
                        const Spacer(),
                        
                        // Action Buttons
                        _buildActionButtons(),
                        
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMicrophoneSection() {
    return Consumer<VoiceProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Animated Microphone
            Hero(
              tag: 'mic_button',
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: provider.isListening
                      ? AppColors.voiceActiveGradient
                      : AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: provider.isListening
                          ? AppColors.accentMain.withValues(alpha: 0.5)
                          : AppColors.primaryMain.withValues(alpha: 0.5),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: provider.isListening
                    ? const PulseAnimation(
                        child: Icon(
                          Icons.mic,
                          size: 70,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.mic_off,
                        size: 70,
                        color: Colors.white,
                      ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Waveform Animation
            if (provider.isListening)
              const WaveformAnimation(
                color: AppColors.accentMain,
                height: 60,
                barCount: 5,
              ),
          ],
        );
      },
    );
  }

  Widget _buildRecognizedText() {
    return Consumer<VoiceProvider>(
      builder: (context, provider, child) {
        if (provider.recognizedText.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Say something like "Add milk and bread"',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.glassBorder,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                provider.recognizedText,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              if (provider.confidence > 0) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: provider.confidence,
                  backgroundColor: AppColors.surfaceLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.success,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 4),
                Text(
                  'Confidence: ${(provider.confidence * 100).toStringAsFixed(0)}%',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Consumer<VoiceProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Cancel Button
              if (provider.isListening)
                ElevatedButton(
                  onPressed: () async {
                    await provider.cancelListening();
                    await _handleClose();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error.withValues(alpha: 0.2),
                    foregroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              
              // Done Button
              if (!provider.isListening && provider.recognizedText.isNotEmpty)
                ElevatedButton(
                  onPressed: _handleClose,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Add Items'),
                ),
              
              // Retry Button
              if (!provider.isListening && provider.recognizedText.isEmpty)
                ElevatedButton(
                  onPressed: () => provider.startListening(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryMain,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Try Again'),
                ),
            ],
          ),
        );
      },
    );
  }
}
