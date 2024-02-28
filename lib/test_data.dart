import 'package:dialife/nutrition_log/nutrition_log.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

List<PieChartSectionData> showingSampleSections(int touchedIndex) {
  return List.generate(3, (i) {
    final isTouched = i == touchedIndex;
    final fontSize = isTouched ? 20.0 : 16.0;
    final radius = isTouched ? 95.0 : 90.0;
    final widgetSize = isTouched ? 45.0 : 40.0;
    const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

    switch (i) {
      case 0:
        return PieChartSectionData(
          color: fatsColor,
          value: 40,
          title: '40%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade200,
            shadows: shadows,
          ),
          badgeWidget: _Badge(
            Image.asset("assets/fat.png"),
            size: widgetSize,
            borderColor: fatsColor,
          ),
          badgePositionPercentageOffset: .98,
        );
      case 1:
        return PieChartSectionData(
          color: proteinColor,
          value: 16,
          title: '16%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade200,
            shadows: shadows,
          ),
          badgeWidget: _Badge(
            Image.asset("assets/protein.png"),
            size: widgetSize,
            borderColor: proteinColor,
          ),
          badgePositionPercentageOffset: .98,
        );
      case 2:
        return PieChartSectionData(
          color: carbsColor,
          value: 15,
          title: '15%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade200,
            shadows: shadows,
          ),
          badgeWidget: _Badge(
            const Icon(Icons.breakfast_dining_outlined),
            size: widgetSize,
            borderColor: carbsColor,
          ),
          badgePositionPercentageOffset: .98,
        );
      default:
        throw Exception('Oh no');
    }
  });
}

class _Badge extends StatelessWidget {
  const _Badge(
    this.child, {
    required this.size,
    required this.borderColor,
  });
  final Widget child;
  final double size;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: borderColor.withOpacity(0.5),
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(.2),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * .15),
      child: Center(
        child: child,
      ),
    );
  }
}
