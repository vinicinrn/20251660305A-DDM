import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/airplane_model.dart';

class CustomizationDialog extends StatefulWidget {
  final int points;
  final AirplaneModel currentAirplane;
  final Function(int, AirplaneModel) onCustomize;

  const CustomizationDialog({
    Key? key,
    required this.points,
    required this.currentAirplane,
    required this.onCustomize,
  }) : super(key: key);

  @override
  _CustomizationDialogState createState() => _CustomizationDialogState();
}

class _CustomizationDialogState extends State<CustomizationDialog> {
  late int _remainingPoints;
  late AirplaneModel _tempAirplane;

  @override
  void initState() {
    super.initState();
    _remainingPoints = widget.points;
    _tempAirplane = widget.currentAirplane;
  }

  Widget _colorOption(Color color, String name) {
    bool isSelected = _tempAirplane.color == color;
    bool canAfford = _remainingPoints >= GameConfig.colorCustomizationCost || isSelected;

    return GestureDetector(
      onTap: canAfford
          ? () {
              if (!isSelected) {
                setState(() {
                  if (_tempAirplane.color != widget.currentAirplane.color) {
                    _remainingPoints += GameConfig.colorCustomizationCost;
                  }
                  _remainingPoints -= GameConfig.colorCustomizationCost;
                  _tempAirplane = _tempAirplane.copyWith(color: color);
                });
              }
            }
          : null,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(canAfford ? 1.0 : 0.3),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: 3,
          ),
        ),
        child: Text(
          name,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _styleOption(String style, String name, int cost) {
    bool isSelected = _tempAirplane.style == style;
    bool canAfford = _remainingPoints >= cost || isSelected;

    return GestureDetector(
      onTap: canAfford
          ? () {
              if (!isSelected) {
                setState(() {
                  // Reembolsar o estilo anterior se não for o classic
                  if (_tempAirplane.style != AirplaneStyles.classic &&
                      _tempAirplane.style != widget.currentAirplane.style) {
                    _remainingPoints += GameConfig.styleCustomizationCost;
                  }
                  // Cobrar pelo novo estilo se não for o classic
                  if (style != AirplaneStyles.classic) {
                    _remainingPoints -= cost;
                  }
                  _tempAirplane = _tempAirplane.copyWith(style: style);
                });
              }
            }
          : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: canAfford
              ? AppColors.primary.withOpacity(isSelected ? 1.0 : 0.7)
              : Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.text : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          name,
          style: TextStyle(
            color: canAfford ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Personalizar Avião', style: TextStyle(color: AppColors.text)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Pontos disponíveis: $_remainingPoints',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text('Cores (${GameConfig.colorCustomizationCost} pontos cada):',
              style: TextStyle(fontSize: 16)),
          SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: [
              _colorOption(AppColors.primary, 'Turquesa'),
              _colorOption(AppColors.accent, 'Coral'),
              _colorOption(AppColors.planeGreen, 'Verde'),
              _colorOption(AppColors.planePurple, 'Roxo'),
              _colorOption(AppColors.planeOrange, 'Laranja'),
            ],
          ),
          SizedBox(height: 20),
          Text('Estilos:', style: TextStyle(fontSize: 16)),
          SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: [
              _styleOption(AirplaneStyles.classic, 'Clássico', 0),
              _styleOption(AirplaneStyles.jet, 'Jato', GameConfig.styleCustomizationCost),
              _styleOption(AirplaneStyles.biplane, 'Biplano', GameConfig.styleCustomizationCost),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text('Cancelar'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text('Confirmar'),
          onPressed: () {
            int pointsSpent = widget.points - _remainingPoints;
            widget.onCustomize(pointsSpent, _tempAirplane);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}