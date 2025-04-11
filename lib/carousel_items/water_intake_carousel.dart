import 'package:dialife/api/api.dart';
import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:dialife/main.dart';
import 'package:dialife/nutrition_log/entities.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite/sqflite.dart';

class WaterIntakeCarousel extends StatelessWidget {
  final Future<void> Function() _refreshWaterIntake;
  final List<WaterRecord> _records;

  const WaterIntakeCarousel({
    super.key,
    required Future<void> Function() refreshWaterIntake,
    required List<WaterRecord> records,
  })  : _records = records,
        _refreshWaterIntake = refreshWaterIntake;

  @override
  Widget build(BuildContext context) {
    final records = _records
        .where(
          (element) => element.time.isAfter(DateTime.now()
              .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0)),
        )
        .toList();

    return SizedBox.expand(
      child: Container(
        padding: const EdgeInsets.only(
          top: 12,
          left: 12,
          right: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Water Intake",
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 18,
                height: 1,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 8,
                  ),
                  child: Image.asset(
                    "assets/glass.png",
                    height: 100,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                "Today",
                                style: GoogleFonts.roboto(
                                  color: Colors.grey.shade600,
                                  height: 1,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Builder(
                                builder: (context) {
                                  final glassesOfWater = records.length;
                                  final description =
                                      records.length == 1 ? "glass" : "glasses";

                                  return Text.rich(
                                    TextSpan(
                                      children: [
                                        const TextSpan(text: "Drank "),
                                        TextSpan(
                                          text: glassesOfWater.toString(),
                                          style: GoogleFonts.roboto(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        TextSpan(
                                            text: " $description of water"),
                                      ],
                                      style: GoogleFonts.roboto(fontSize: 12),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const Expanded(child: SizedBox()),
                          SizedBox(
                            width: 68,
                            height: 52,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  child: GestureDetector(
                                    onTap: () async {
                                      final databasePath =
                                          await getDatabasesPath();
                                      final db =
                                          await initAppDatabase(databasePath);

                                      await db.rawDelete(
                                        "DELETE FROM WaterRecord WHERE id = (SELECT MAX(id) FROM WaterRecord)",
                                      );

                                      MonitoringAPI.syncWaterRecords();

                                      _refreshWaterIntake();
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(99),
                                        color: fgColor2,
                                      ),
                                      width: 28,
                                      height: 28,
                                      child: Center(
                                        child: Text(
                                          "-",
                                          style: GoogleFonts.roboto(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: GestureDetector(
                                    onTap: () async {
                                      final databasePath =
                                          await getDatabasesPath();
                                      final db =
                                          await initAppDatabase(databasePath);

                                      await db.rawInsert(
                                        "INSERT INTO WaterRecord (glasses, time) VALUES (?, ?)",
                                        [
                                          1,
                                          DateTime.now().toIso8601String(),
                                        ],
                                      );

                                      MonitoringAPI.syncWaterRecords();

                                      _refreshWaterIntake();
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: fgColor,
                                        borderRadius: BorderRadius.circular(99),
                                      ),
                                      width: 52,
                                      height: 52,
                                      child: Center(
                                        child: Text(
                                          "+",
                                          style: GoogleFonts.roboto(
                                            color: Colors.white,
                                            fontSize: 32,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Divider(
                        height: 4,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
