import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

import '../../core/animations/custom_animations.dart';

/// Floating microphone button with pulse animation
/// Central interaction point for voice input
class FloatingMicButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isListening;

  const FloatingMicButton({super.key, required this.onPressed, this.isListening = false});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'mic_button',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          onPressed();
        },
        child: PulseAnimation(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: isListening
                  ? AppColors.voiceActiveGradient
                  : AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isListening
                      ? AppColors.accentMain.withValues(alpha: 0.4)
                      : AppColors.primaryMain.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              isListening ? Icons.mic : Icons.mic_none,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}
