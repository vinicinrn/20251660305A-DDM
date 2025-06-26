import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/constants.dart';
import '../models/airplane_model.dart';

class AirplaneWidget extends StatelessWidget {
  final AirplaneModel airplane;
  final Animation<double> floatAnimation;
  final Animation<double> propellerAnimation;
  final bool isRunning;

  const AirplaneWidget({
    Key? key,
    required this.airplane,
    required this.floatAnimation,
    required this.propellerAnimation,
    required this.isRunning,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, floatAnimation.value),
          child: Transform.scale(
            scale: 1.0,
            child: _buildLowPolyAirplane(),
          ),
        );
      },
    );
  }

  Widget _buildLowPolyAirplane() {
    switch (airplane.style) {
      case AirplaneStyles.jet:
        return _buildLowPolyJet();
      case AirplaneStyles.biplane:
        return _buildLowPolyBiplane();
      default:
        return _buildLowPolyClassic();
    }
  }

  Widget _buildLowPolyClassic() {
    return Container(
      width: 120,
      height: 120,
      child: CustomPaint(
        painter: LowPolyAirplanePainter(
          color: airplane.color,
          style: 'classic',
          isRunning: isRunning,
          propellerAnimation: propellerAnimation,
        ),
      ),
    );
  }

  Widget _buildLowPolyJet() {
    return Container(
      width: 120,
      height: 120,
      child: CustomPaint(
        painter: LowPolyAirplanePainter(
          color: airplane.color,
          style: 'jet',
          isRunning: isRunning,
          propellerAnimation: propellerAnimation,
        ),
      ),
    );
  }

  Widget _buildLowPolyBiplane() {
    return Container(
      width: 120,
      height: 120,
      child: CustomPaint(
        painter: LowPolyAirplanePainter(
          color: airplane.color,
          style: 'biplane',
          isRunning: isRunning,
          propellerAnimation: propellerAnimation,
        ),
      ),
    );
  }
}

class LowPolyAirplanePainter extends CustomPainter {
  final Color color;
  final String style;
  final bool isRunning;
  final Animation<double>? propellerAnimation;

  LowPolyAirplanePainter({
    required this.color,
    required this.style,
    required this.isRunning,
    this.propellerAnimation,
  }) : super(repaint: propellerAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Cores derivadas da cor principal
    final lightColor = Color.lerp(color, Colors.white, 0.3)!;
    final darkColor = Color.lerp(color, Colors.black, 0.2)!;
    final shadowColor = Color.lerp(color, Colors.black, 0.4)!;

    switch (style) {
      case 'jet':
        _drawLowPolyJet(canvas, size, centerX, centerY, lightColor, darkColor, shadowColor);
        break;
      case 'biplane':
        _drawLowPolyBiplane(canvas, size, centerX, centerY, lightColor, darkColor, shadowColor);
        break;
      default:
        _drawLowPolyClassic(canvas, size, centerX, centerY, lightColor, darkColor, shadowColor);
    }
  }

  void _drawLowPolyClassic(Canvas canvas, Size size, double centerX, double centerY,
      Color lightColor, Color darkColor, Color shadowColor) {
    
    // Fuselagem principal - polígono central
    final fuselagePath = Path()
      ..moveTo(centerX - 40, centerY)
      ..lineTo(centerX - 30, centerY - 10)
      ..lineTo(centerX + 20, centerY - 8)
      ..lineTo(centerX + 35, centerY)
      ..lineTo(centerX + 20, centerY + 8)
      ..lineTo(centerX - 30, centerY + 10)
      ..close();

    // Sombra da fuselagem
    final fuselageShadowPath = Path()
      ..moveTo(centerX - 40, centerY)
      ..lineTo(centerX - 30, centerY + 10)
      ..lineTo(centerX + 20, centerY + 8)
      ..lineTo(centerX + 35, centerY)
      ..close();

    // Asa superior
    final wingTopPath = Path()
      ..moveTo(centerX - 20, centerY - 10)
      ..lineTo(centerX - 15, centerY - 35)
      ..lineTo(centerX + 10, centerY - 30)
      ..lineTo(centerX + 5, centerY - 8)
      ..close();

    // Asa inferior
    final wingBottomPath = Path()
      ..moveTo(centerX - 20, centerY + 10)
      ..lineTo(centerX - 15, centerY + 35)
      ..lineTo(centerX + 10, centerY + 30)
      ..lineTo(centerX + 5, centerY + 8)
      ..close();

    // Cauda vertical
    final tailPath = Path()
      ..moveTo(centerX + 20, centerY - 8)
      ..lineTo(centerX + 30, centerY - 20)
      ..lineTo(centerX + 35, centerY - 15)
      ..lineTo(centerX + 35, centerY)
      ..close();

    // Desenhar elementos
    canvas.drawPath(wingBottomPath, Paint()..color = darkColor);
    canvas.drawPath(wingTopPath, Paint()..color = lightColor);
    canvas.drawPath(fuselageShadowPath, Paint()..color = shadowColor);
    canvas.drawPath(fuselagePath, Paint()..color = color);
    canvas.drawPath(tailPath, Paint()..color = lightColor);

    // Cockpit - triângulo
    final cockpitPath = Path()
      ..moveTo(centerX - 25, centerY - 5)
      ..lineTo(centerX - 15, centerY - 8)
      ..lineTo(centerX - 15, centerY)
      ..lineTo(centerX - 25, centerY + 5)
      ..close();
    canvas.drawPath(cockpitPath, Paint()..color = shadowColor.withOpacity(0.6));

    // Hélice
    if (isRunning && propellerAnimation != null) {
      canvas.save();
      canvas.translate(centerX - 40, centerY);
      canvas.rotate(propellerAnimation!.value * 2 * math.pi);
      
      final propellerPaint = Paint()
        ..color = Colors.grey[700]!
        ..style = PaintingStyle.fill;
      
      // Pás da hélice em estilo low-poly
      final bladePath = Path()
        ..moveTo(-2, -20)
        ..lineTo(2, -20)
        ..lineTo(1, 0)
        ..lineTo(-1, 0)
        ..close();
      
      canvas.drawPath(bladePath, propellerPaint);
      canvas.rotate(math.pi);
      canvas.drawPath(bladePath, propellerPaint);
      
      canvas.restore();
    }

    // Detalhes geométricos
    _drawGeometricDetails(canvas, centerX, centerY, shadowColor);
  }

  void _drawLowPolyJet(Canvas canvas, Size size, double centerX, double centerY,
      Color lightColor, Color darkColor, Color shadowColor) {
    
    // Fuselagem principal - mais angular
    final fuselagePath = Path()
      ..moveTo(centerX - 35, centerY)
      ..lineTo(centerX - 30, centerY - 8)
      ..lineTo(centerX + 25, centerY - 5)
      ..lineTo(centerX + 40, centerY)
      ..lineTo(centerX + 25, centerY + 5)
      ..lineTo(centerX - 30, centerY + 8)
      ..close();

    // Asas delta
    final deltaWingPath = Path()
      ..moveTo(centerX - 10, centerY)
      ..lineTo(centerX - 25, centerY - 30)
      ..lineTo(centerX + 20, centerY - 10)
      ..lineTo(centerX + 20, centerY + 10)
      ..lineTo(centerX - 25, centerY + 30)
      ..lineTo(centerX - 10, centerY)
      ..close();

    // Cauda vertical
    final tailPath = Path()
      ..moveTo(centerX + 25, centerY - 5)
      ..lineTo(centerX + 35, centerY - 18)
      ..lineTo(centerX + 40, centerY - 12)
      ..lineTo(centerX + 40, centerY)
      ..close();

    // Turbinas
    final enginePath1 = Path()
      ..addPolygon([
        Offset(centerX + 15, centerY - 12),
        Offset(centerX + 25, centerY - 12),
        Offset(centerX + 28, centerY - 8),
        Offset(centerX + 18, centerY - 8),
      ], true);

    final enginePath2 = Path()
      ..addPolygon([
        Offset(centerX + 15, centerY + 12),
        Offset(centerX + 25, centerY + 12),
        Offset(centerX + 28, centerY + 8),
        Offset(centerX + 18, centerY + 8),
      ], true);

    // Desenhar elementos
    canvas.drawPath(deltaWingPath, Paint()..color = darkColor);
    canvas.drawPath(fuselagePath, Paint()..color = color);
    canvas.drawPath(tailPath, Paint()..color = lightColor);
    canvas.drawPath(enginePath1, Paint()..color = shadowColor);
    canvas.drawPath(enginePath2, Paint()..color = shadowColor);

    // Cockpit angular
    final cockpitPath = Path()
      ..moveTo(centerX - 30, centerY - 5)
      ..lineTo(centerX - 20, centerY - 7)
      ..lineTo(centerX - 18, centerY)
      ..lineTo(centerX - 20, centerY + 7)
      ..lineTo(centerX - 30, centerY + 5)
      ..close();
    canvas.drawPath(cockpitPath, Paint()..color = shadowColor.withOpacity(0.7));

    // Detalhes geométricos
    _drawJetDetails(canvas, centerX, centerY, lightColor);
  }

  void _drawLowPolyBiplane(Canvas canvas, Size size, double centerX, double centerY,
      Color lightColor, Color darkColor, Color shadowColor) {
    
    // Fuselagem
    final fuselagePath = Path()
      ..moveTo(centerX - 35, centerY)
      ..lineTo(centerX - 30, centerY - 8)
      ..lineTo(centerX + 20, centerY - 6)
      ..lineTo(centerX + 30, centerY)
      ..lineTo(centerX + 20, centerY + 6)
      ..lineTo(centerX - 30, centerY + 8)
      ..close();

    // Asa superior
    final wingTopPath = Path()
      ..moveTo(centerX - 25, centerY - 20)
      ..lineTo(centerX - 20, centerY - 40)
      ..lineTo(centerX + 15, centerY - 38)
      ..lineTo(centerX + 10, centerY - 18)
      ..close();

    // Asa inferior
    final wingBottomPath = Path()
      ..moveTo(centerX - 25, centerY + 20)
      ..lineTo(centerX - 20, centerY + 40)
      ..lineTo(centerX + 15, centerY + 38)
      ..lineTo(centerX + 10, centerY + 18)
      ..close();

    // Suportes das asas
    final strutPaint = Paint()
      ..color = shadowColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Cauda
    final tailPath = Path()
      ..moveTo(centerX + 20, centerY - 6)
      ..lineTo(centerX + 28, centerY - 15)
      ..lineTo(centerX + 30, centerY - 10)
      ..lineTo(centerX + 30, centerY)
      ..close();

    // Desenhar elementos
    canvas.drawPath(wingBottomPath, Paint()..color = darkColor);
    canvas.drawPath(wingTopPath, Paint()..color = lightColor);
    canvas.drawPath(fuselagePath, Paint()..color = color);
    canvas.drawPath(tailPath, Paint()..color = lightColor);

    // Suportes
    canvas.drawLine(Offset(centerX - 10, centerY - 18), 
                     Offset(centerX - 10, centerY + 18), strutPaint);
    canvas.drawLine(Offset(centerX + 5, centerY - 18), 
                     Offset(centerX + 5, centerY + 18), strutPaint);

    // Hélice vintage
    if (isRunning && propellerAnimation != null) {
      canvas.save();
      canvas.translate(centerX - 35, centerY);
      canvas.rotate(propellerAnimation!.value * 2 * math.pi);
      
      final propellerPaint = Paint()
        ..color = Colors.brown[700]!
        ..style = PaintingStyle.fill;
      
      // Hélice estilo madeira
      final bladePath = Path()
        ..moveTo(-3, -22)
        ..lineTo(3, -22)
        ..lineTo(2, 0)
        ..lineTo(-2, 0)
        ..close();
      
      canvas.drawPath(bladePath, propellerPaint);
      canvas.rotate(math.pi);
      canvas.drawPath(bladePath, propellerPaint);
      
      // Centro da hélice
      canvas.drawCircle(Offset.zero, 4, Paint()..color = Colors.grey[800]!);
      
      canvas.restore();
    }

    // Cockpit vintage
    final cockpitPath = Path()
      ..moveTo(centerX - 25, centerY - 6)
      ..lineTo(centerX - 15, centerY - 8)
      ..lineTo(centerX - 13, centerY)
      ..lineTo(centerX - 15, centerY + 8)
      ..lineTo(centerX - 25, centerY + 6)
      ..close();
    canvas.drawPath(cockpitPath, Paint()..color = shadowColor.withOpacity(0.6));
  }

  void _drawGeometricDetails(Canvas canvas, double centerX, double centerY, Color detailColor) {
    final detailPaint = Paint()
      ..color = detailColor.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Pequenos triângulos decorativos
    final detail1 = Path()
      ..moveTo(centerX - 5, centerY - 5)
      ..lineTo(centerX, centerY - 3)
      ..lineTo(centerX - 3, centerY)
      ..close();
    canvas.drawPath(detail1, detailPaint);

    final detail2 = Path()
      ..moveTo(centerX + 5, centerY + 3)
      ..lineTo(centerX + 10, centerY + 5)
      ..lineTo(centerX + 8, centerY)
      ..close();
    canvas.drawPath(detail2, detailPaint);
  }

  void _drawJetDetails(Canvas canvas, double centerX, double centerY, Color detailColor) {
    final detailPaint = Paint()
      ..color = detailColor.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    // Linhas aerodinâmicas
    final line1 = Path()
      ..moveTo(centerX - 20, centerY - 4)
      ..lineTo(centerX + 10, centerY - 2)
      ..lineTo(centerX + 10, centerY - 1)
      ..lineTo(centerX - 20, centerY - 3)
      ..close();
    canvas.drawPath(line1, detailPaint);

    final line2 = Path()
      ..moveTo(centerX - 20, centerY + 3)
      ..lineTo(centerX + 10, centerY + 1)
      ..lineTo(centerX + 10, centerY + 2)
      ..lineTo(centerX - 20, centerY + 4)
      ..close();
    canvas.drawPath(line2, detailPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}