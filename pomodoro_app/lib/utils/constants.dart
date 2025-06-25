import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFE8F4F0); // Verde mint suave
  static const Color primary = Color(0xFF4ECDC4); // Turquesa
  static const Color accent = Color(0xFFFF6B6B); // Coral suave
  static const Color text = Color(0xFF2D3436); // Cinza escuro
  static const Color amber = Color(0xFFFFBE76); // Amarelo suave
  static final Color shadowColor = primary.withOpacity(0.2);
  
  // Cores adicionais para aviões
  static const Color planeGreen = Color(0xFF6BCB77); // Verde natureza
  static const Color planePurple = Color(0xFF9B59B6); // Roxo suave
  static const Color planeOrange = Color(0xFFFF9F43); // Laranja vibrante
}

class TimerDurations {
  static const int workMinutes = 25;
  static const int shortBreakMinutes = 5;
  static const int longBreakMinutes = 15;
}

class GameConfig {
  static const int pointsPerPomodoro = 10;
  static const int colorCustomizationCost = 10;
  static const int styleCustomizationCost = 20;
}

class AirplaneStyles {
  static const String classic = 'classic';
  static const String jet = 'jet';
  static const String biplane = 'biplane';
}