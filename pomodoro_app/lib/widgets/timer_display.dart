import 'package:flutter/material.dart';
import '../utils/constants.dart';

class TimerDisplay extends StatelessWidget {
  final int seconds;
  final bool isBreak;

  const TimerDisplay({
    Key? key,
    required this.seconds,
    required this.isBreak,
  }) : super(key: key);

  String get _timerText {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Text(
          _timerText,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: isBreak ? AppColors.accent : AppColors.primary,
          ),
        ),
      ),
    );
  }
}