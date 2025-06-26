import 'package:flutter/material.dart';
import '../models/airplane_collection.dart';
import '../utils/constants.dart';
import '../widgets/airplane_widget.dart';
import '../models/airplane_model.dart';

class HangarScreen extends StatefulWidget {
  final int currentPoints;
  final int currentStreak;
  final int totalPomodoros;
  final Function(CollectableAirplane) onSelectAirplane;
  final String currentAirplaneId;

  const HangarScreen({
    Key? key,
    required this.currentPoints,
    required this.currentStreak,
    required this.totalPomodoros,
    required this.onSelectAirplane,
    required this.currentAirplaneId,
  }) : super(key: key);

  @override
  _HangarScreenState createState() => _HangarScreenState();
}

class _HangarScreenState extends State<HangarScreen> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  CollectableAirplane? selectedAirplane;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(
      begin: -5.0,
      end: 5.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    // Encontrar o avião atualmente selecionado
    selectedAirplane = AirplaneCollection.allAirplanes.firstWhere(
      (plane) => plane.id == widget.currentAirplaneId,
      orElse: () => AirplaneCollection.allAirplanes.first,
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  bool _canUnlock(CollectableAirplane airplane) {
    if (airplane.isSpecial) {
      if (airplane.id == 'special_rainbow') {
        return widget.totalPomodoros >= 100;
      }
      return widget.currentStreak >= airplane.requiredStreak;
    }
    return widget.currentPoints >= airplane.unlockCost;
  }

  Widget _buildAirplaneCard(CollectableAirplane airplane) {
    final isUnlocked = airplane.isUnlocked || _canUnlock(airplane);
    final isSelected = selectedAirplane?.id == airplane.id;

    return GestureDetector(
      onTap: isUnlocked
          ? () {
              setState(() {
                selectedAirplane = airplane;
              });
              widget.onSelectAirplane(airplane);
            }
          : null,
      child: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Preview do avião
            Container(
              height: 100,
              padding: EdgeInsets.all(10),
              child: Center(
                child: isUnlocked
                    ? Transform.scale(
                        scale: 0.7,
                        child: AirplaneWidget(
                          airplane: AirplaneModel(
                            color: airplane.baseColor,
                            style: airplane.style,
                          ),
                          floatAnimation: _floatAnimation,
                          propellerAnimation: _floatController,
                          isRunning: false,
                        ),
                      )
                    : Icon(
                        Icons.lock,
                        size: 40,
                        color: Colors.grey[400],
                      ),
              ),
            ),
            // Nome e status
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? (airplane.isSpecial ? AppColors.amber : AppColors.primary)
                    : Colors.grey[300],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    airplane.name,
                    style: TextStyle(
                      color: isUnlocked ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (!isUnlocked) ...[
                    SizedBox(height: 2),
                    Text(
                      airplane.isSpecial
                          ? (airplane.id == 'special_rainbow'
                              ? '${widget.totalPomodoros}/100 🍅'
                              : '${widget.currentStreak}/${airplane.requiredStreak} dias')
                          : '${airplane.unlockCost} pontos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Galpão de Aviões',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.text),
      ),
      body: Column(
        children: [
          // Estatísticas
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Pontos', widget.currentPoints.toString(), Icons.star),
                _buildStat('Sequência', '${widget.currentStreak} dias', Icons.local_fire_department),
                _buildStat('Total', '${widget.totalPomodoros} 🍅', Icons.check_circle),
              ],
            ),
          ),
          // Grid de aviões
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: AirplaneCollection.allAirplanes.length,
              itemBuilder: (context, index) {
                return _buildAirplaneCard(AirplaneCollection.allAirplanes[index]);
              },
            ),
          ),
          // Descrição do avião selecionado
          if (selectedAirplane != null)
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    selectedAirplane!.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    selectedAirplane!.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}