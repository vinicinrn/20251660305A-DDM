import 'package:flutter/material.dart';

class CollectableAirplane {
  final String id;
  final String name;
  final String style;
  final Color baseColor;
  final int unlockCost;
  final String description;
  final int requiredStreak; // Dias consecutivos necessários
  final bool isSpecial;
  bool isUnlocked;

  CollectableAirplane({
    required this.id,
    required this.name,
    required this.style,
    required this.baseColor,
    required this.unlockCost,
    required this.description,
    this.requiredStreak = 0,
    this.isSpecial = false,
    this.isUnlocked = false,
  });
}

class AirplaneCollection {
  static final List<CollectableAirplane> allAirplanes = [
    // Aviões Básicos
    CollectableAirplane(
      id: 'classic_turquoise',
      name: 'Explorador',
      style: 'classic',
      baseColor: Color(0xFF4ECDC4),
      unlockCost: 0,
      description: 'O avião inicial para começar sua jornada',
      isUnlocked: true,
    ),
    CollectableAirplane(
      id: 'classic_coral',
      name: 'Flamingo',
      style: 'classic',
      baseColor: Color(0xFFFF6B6B),
      unlockCost: 30,
      description: 'Elegante e vibrante como um flamingo',
    ),
    CollectableAirplane(
      id: 'classic_green',
      name: 'Esmeralda',
      style: 'classic',
      baseColor: Color(0xFF6BCB77),
      unlockCost: 30,
      description: 'Verde como as florestas tropicais',
    ),

    // Aviões Jato
    CollectableAirplane(
      id: 'jet_purple',
      name: 'Supersônico',
      style: 'jet',
      baseColor: Color(0xFF9B59B6),
      unlockCost: 50,
      description: 'Veloz como o som',
    ),
    CollectableAirplane(
      id: 'jet_orange',
      name: 'Sol Nascente',
      style: 'jet',
      baseColor: Color(0xFFFF9F43),
      unlockCost: 50,
      description: 'Brilhante como o amanhecer',
    ),
    CollectableAirplane(
      id: 'jet_midnight',
      name: 'Stealth',
      style: 'jet',
      baseColor: Color(0xFF2C3E50),
      unlockCost: 80,
      description: 'Furtivo e misterioso',
    ),

    // Aviões Biplano
    CollectableAirplane(
      id: 'biplane_vintage',
      name: 'Barão Vermelho',
      style: 'biplane',
      baseColor: Color(0xFFE74C3C),
      unlockCost: 60,
      description: 'Um clássico dos céus',
    ),
    CollectableAirplane(
      id: 'biplane_royal',
      name: 'Majestade',
      style: 'biplane',
      baseColor: Color(0xFF3498DB),
      unlockCost: 60,
      description: 'Digno da realeza aérea',
    ),

    // Aviões Especiais (desbloqueados por streaks)
    CollectableAirplane(
      id: 'special_golden',
      name: 'Águia Dourada',
      style: 'classic',
      baseColor: Color(0xFFFFD700),
      unlockCost: 0,
      description: 'Conquistado após 7 dias consecutivos',
      requiredStreak: 7,
      isSpecial: true,
    ),
    CollectableAirplane(
      id: 'special_platinum',
      name: 'Platina',
      style: 'jet',
      baseColor: Color(0xFFE5E4E2),
      unlockCost: 0,
      description: 'Conquistado após 30 dias consecutivos',
      requiredStreak: 30,
      isSpecial: true,
    ),
    CollectableAirplane(
      id: 'special_rainbow',
      name: 'Arco-Íris',
      style: 'biplane',
      baseColor: Color(0xFFFF1493),
      unlockCost: 0,
      description: 'Conquistado após 100 pomodoros',
      requiredStreak: 0,
      isSpecial: true,
    ),
  ];
}