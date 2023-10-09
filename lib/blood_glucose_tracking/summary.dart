import 'package:dialife/blood_glucose_tracking/entities.dart';
import 'package:flutter/material.dart';

class RecordSummary extends StatelessWidget {
  const RecordSummary({
    super.key,
    required this.data,
  });

  final List<GlucoseRecord> data;

  @override
  Widget build(BuildContext context) {
    final latest = data.last.glucoseLevel;
    final beforeLatest = data[data.length - 2].glucoseLevel;
    final difference = latest - beforeLatest;
    final averageLevel = data.map((datum) => datum.glucoseLevel).reduce(
              (value, element) => value + element,
            ) /
        data.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.greenAccent.shade100,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text("Latest"),
              Text(
                latest.toStringAsFixed(2),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
              Text(
                (difference.isNegative ? "" : "+") +
                    difference.toStringAsFixed(2),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              )
            ],
          ),
        ),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.greenAccent.shade100,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text("Average"),
              Text(
                averageLevel.toStringAsFixed(2),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
            ],
          ),
        ),
        // Container(
        //   width: 100,
        //   height: 100,
        //   decoration: BoxDecoration(
        //     borderRadius: BorderRadius.circular(12),
        //     color: Colors.greenAccent.shade100,
        //   ),
        // )
      ],
    );
  }
}
