import 'package:flutter/material.dart';

class AirplaneModel {
  final Color color;
  final String style;

  AirplaneModel({
    required this.color,
    required this.style,
  });

  AirplaneModel copyWith({
    Color? color,
    String? style,
  }) {
    return AirplaneModel(
      color: color ?? this.color,
      style: style ?? this.style,
    );
  }
}