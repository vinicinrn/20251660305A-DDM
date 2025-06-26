import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../utils/constants.dart';
import '../models/airplane_model.dart';
import '../models/airplane_collection.dart';
import '../widgets/airplane_widget.dart';
import '../widgets/timer_display.dart';
import '../widgets/customization_dialog.dart';
import 'hangar_screen.dart';

class PomodoroScreen extends StatefulWidget {
  @override
  _PomodoroScreenState createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen>
    with TickerProviderStateMixin {
  Timer? _timer;
  int _seconds = TimerDurations.workMinutes * 60;
  bool _isRunning = false;
  bool _isBreak = false;
  int _completedPomodoros = 0;
  int _points = 0;
  int _currentStreak = 1; // Dias consecutivos
  DateTime? _lastCompletedDate;
  String _currentAirplaneId = 'classic_turquoise';

  // Modelo do avião
  late AirplaneModel _airplane;

  // Animações
  late AnimationController _floatController;
  late AnimationController _propellerController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    _airplane = AirplaneModel(
      color: AppColors.primary,
      style: AirplaneStyles.classic,
    );

    _floatController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _propellerController = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    );

    _floatAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _floatController.dispose();
    _propellerController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;

    setState(() => _isRunning = true);
    _propellerController.repeat();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          _completeSession();
        }
      });
    });
  }

  void _pauseTimer() {
    setState(() => _isRunning = false);
    _timer?.cancel();
    _propellerController.stop();
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _seconds = _isBreak
          ? (_completedPomodoros % 4 == 0
                  ? TimerDurations.longBreakMinutes
                  : TimerDurations.shortBreakMinutes) *
              60
          : TimerDurations.workMinutes * 60;
    });
    _timer?.cancel();
    _propellerController.stop();
  }

  void _completeSession() {
    _timer?.cancel();
    _propellerController.stop();

    // Vibração
    HapticFeedback.mediumImpact();

    setState(() {
      _isRunning = false;

      if (!_isBreak) {
        _completedPomodoros++;
        _points += GameConfig.pointsPerPomodoro;
        
        // Atualizar streak
        _updateStreak();
        
        _showRewardDialog();
      }

      _isBreak = !_isBreak;
      _seconds = _isBreak
          ? (_completedPomodoros % 4 == 0
                  ? TimerDurations.longBreakMinutes
                  : TimerDurations.shortBreakMinutes) *
              60
          : TimerDurations.workMinutes * 60;
    });
  }

  void _updateStreak() {
    final now = DateTime.now();
    if (_lastCompletedDate != null) {
      final difference = now.difference(_lastCompletedDate!).inDays;
      if (difference == 1) {
        _currentStreak++;
      } else if (difference > 1) {
        _currentStreak = 1;
      }
    }
    _lastCompletedDate = now;
  }

  void _showRewardDialog() {
    // Verificar se algum avião especial foi desbloqueado
    String? unlockedSpecialPlane;

    if (_currentStreak == 7) {
      unlockedSpecialPlane = 'Águia Dourada desbloqueada! 🏆';
    } else if (_currentStreak == 30) {
      unlockedSpecialPlane = 'Platina desbloqueada! 🏆';
    } else if (_completedPomodoros == 100) {
      unlockedSpecialPlane = 'Arco-Íris desbloqueado! 🌈';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.star, color: AppColors.amber, size: 30),
              SizedBox(width: 10),
              Text('Parabéns!', style: TextStyle(color: AppColors.text)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Você ganhou ${GameConfig.pointsPerPomodoro} pontos!\nTotal: $_points pontos',
                style: TextStyle(fontSize: 16, color: AppColors.text),
              ),
              if (_currentStreak > 1) ...[
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_fire_department, color: AppColors.accent, size: 20),
                    SizedBox(width: 4),
                    Text(
                      'Sequência: $_currentStreak dias!',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
              if (unlockedSpecialPlane != null) ...[
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    unlockedSpecialPlane,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              child: Text('Ver Galpão'),
              onPressed: () {
                Navigator.of(context).pop();
                _showCustomizationDialog();
              },
            ),
            TextButton(
              child: Text('Continuar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showCustomizationDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HangarScreen(
          currentPoints: _points,
          currentStreak: _currentStreak,
          totalPomodoros: _completedPomodoros,
          currentAirplaneId: _currentAirplaneId,
          onSelectAirplane: (airplane) {
            setState(() {
              _airplane = AirplaneModel(
                color: airplane.baseColor,
                style: airplane.style,
              );
              _currentAirplaneId = airplane.id;

              // Deduzir pontos se necessário
              if (!airplane.isUnlocked && !airplane.isSpecial) {
                _points -= airplane.unlockCost;
                airplane.isUnlocked = true;
              }
            });
          },
        ),
      ),
    );
  }

  bool _hasNewUnlockableAirplanes() {
    return AirplaneCollection.allAirplanes.any((airplane) {
      if (airplane.isUnlocked) return false;

      if (airplane.isSpecial) {
        if (airplane.id == 'special_rainbow') {
          return _completedPomodoros >= 100;
        }
        return _currentStreak >= airplane.requiredStreak;
      }

      return _points >= airplane.unlockCost;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header com estatísticas
            Container(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pomodoros: $_completedPomodoros',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            size: 16,
                            color: _currentStreak > 0 ? AppColors.accent : Colors.grey,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '$_currentStreak dias',
                            style: TextStyle(
                              fontSize: 14,
                              color: _currentStreak > 0 ? AppColors.accent : Colors.grey,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            _isBreak ? 'Descanso' : 'Foco',
                            style: TextStyle(
                              fontSize: 16,
                              color: _isBreak ? AppColors.accent : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: AppColors.amber, size: 24),
                        SizedBox(width: 8),
                        Text(
                          '$_points',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Área principal com timer e avião
            Expanded(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Timer
                    TimerDisplay(
                      seconds: _seconds,
                      isBreak: _isBreak,
                    ),
                    SizedBox(width: 50),
                    // Avião
                    Container(
                      width: 150,
                      height: 150,
                      child: Center(
                        child: AirplaneWidget(
                          airplane: _airplane,
                          floatAnimation: _floatAnimation,
                          propellerAnimation: _propellerController,
                          isRunning: _isRunning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Controles
            Container(
              padding: EdgeInsets.all(30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Botão Reset
                  IconButton(
                    icon: Icon(Icons.refresh),
                    iconSize: 32,
                    color: AppColors.text,
                    onPressed: _resetTimer,
                  ),
                  // Botão Play/Pause
                  GestureDetector(
                    onTap: _isRunning ? _pauseTimer : _startTimer,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _isBreak ? AppColors.accent : AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isBreak ? AppColors.accent : AppColors.primary)
                                .withOpacity(0.3),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isRunning ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  // Botão Galpão
                  Stack(
                    children: [
                      IconButton(
                        icon: Icon(Icons.airplanemode_active),
                        iconSize: 32,
                        color: AppColors.text,
                        onPressed: _showCustomizationDialog,
                      ),
                      // Badge para aviões desbloqueáveis
                      if (_hasNewUnlockableAirplanes())
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}