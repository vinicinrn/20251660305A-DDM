import 'package:flutter/material.dart';
import 'screens/pomodoro_screen.dart';

void main() => runApp(PomodoroAirplaneApp());

class PomodoroAirplaneApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodoro Sky',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: PomodoroScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}