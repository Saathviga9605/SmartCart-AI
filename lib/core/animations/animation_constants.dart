import 'package:flutter/animation.dart';

/// Animation constants for consistent timing across the app
/// Ensures smooth, predictable animations throughout
class AnimationConstants {
  AnimationConstants._();

  // Duration constants
  static const Duration durationInstant = Duration(milliseconds: 100);
  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Duration durationVerySlow = Duration(milliseconds: 800);

  // Specific animation durations
  static const Duration splashDuration = Duration(milliseconds: 2500);
  static const Duration checkboxDuration = Duration(milliseconds: 250);
  static const Duration cardExpandDuration = Duration(milliseconds: 350);
  static const Duration voiceOverlayDuration = Duration(milliseconds: 400);
  static const Duration micPulseDuration = Duration(milliseconds: 1500);
  static const Duration waveformDuration = Duration(milliseconds: 800);
  static const Duration shimmerDuration = Duration(milliseconds: 1500);
  static const Duration successBurstDuration = Duration(milliseconds: 600);

  // Curves - for smooth, natural motion
  static const Curve curveDefault = Curves.easeInOutCubic;
  static const Curve curveEaseIn = Curves.easeIn;
  static const Curve curveEaseOut = Curves.easeOut;
  static const Curve curveEaseInOut = Curves.easeInOut;
  static const Curve curveBounce = Curves.elasticOut;
  static const Curve curveSpring = Curves.easeOutBack;
  static const Curve curveSmooth = Curves.easeInOutCubic;

  // Scale values for micro-interactions
  static const double scaleMin = 0.95;
  static const double scaleNormal = 1.0;
  static const double scaleMax = 1.05;
  static const double scalePressed = 0.92;

  // Opacity values for fade animations
  static const double opacityInvisible = 0.0;
  static const double opacityVisible = 1.0;
  static const double opacityFaded = 0.6;

  // Rotation values (in radians)
  static const double rotationQuarter = 0.785398; // 45 degrees
  static const double rotationHalf = 1.5708; // 90 degrees
  static const double rotationFull = 6.28319; // 360 degrees

  // Slide offsets
  static const double slideOffsetSmall = 20.0;
  static const double slideOffsetMedium = 50.0;
  static const double slideOffsetLarge = 100.0;
}
