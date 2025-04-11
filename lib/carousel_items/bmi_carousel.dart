import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:dialife/bmi_tracking/entities.dart';
import 'package:dialife/main.dart';
import 'package:dialife/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite/sqflite.dart';

class BMICarousel extends StatelessWidget {
  final List<BMIRecord> _records;

  const BMICarousel({
    super.key,
    required List<BMIRecord> records,
  }) : _records = records;

  @override
  Widget build(BuildContext context) {
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
          children: [
            Text(
              "Body Mass Index",
              style: GoogleFonts.roboto(
                fontSize: 18,
                height: 1,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  "assets/fit.png",
                  fit: BoxFit.cover,
                  height: 112,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Text(
                                  "Weight",
                                  style: GoogleFonts.roboto(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Builder(
                                  builder: (context) {
                                    if (_records.isEmpty) {
                                      return const Text(
                                        "--",
                                        style: TextStyle(height: 0.8),
                                      );
                                    }

                                    final weight = _records
                                        .last.weightInKilograms
                                        .toStringAsFixed(1);

                                    return Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: weight,
                                            style: GoogleFonts.roboto(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              height: 1.1,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                          TextSpan(
                                            text: " kg",
                                            style: GoogleFonts.roboto(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                      style: GoogleFonts.roboto(
                                        height: 1,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Text(
                                  "Height",
                                  style: GoogleFonts.roboto(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Builder(
                                  builder: (context) {
                                    if (_records.isEmpty) {
                                      return const Text(
                                        "--",
                                        style: TextStyle(height: 0.8),
                                      );
                                    }

                                    final height = _records.last.heightInMeters
                                        .toStringAsFixed(2);

                                    return Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: height,
                                            style: GoogleFonts.roboto(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              height: 1.1,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                          TextSpan(
                                            text: " m",
                                            style: GoogleFonts.roboto(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                      style: GoogleFonts.roboto(
                                        height: 1,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Text(
                                  "BMI",
                                  style: GoogleFonts.roboto(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Builder(
                                  builder: (context) {
                                    if (_records.isEmpty) {
                                      return const Text(
                                        "--",
                                        style: TextStyle(height: 0.8),
                                      );
                                    }

                                    final bmi =
                                        _records.last.bmi.toStringAsFixed(1);

                                    return Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: bmi,
                                            style: GoogleFonts.roboto(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              height: 1.1,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                          TextSpan(
                                            text: " kg/m²",
                                            style: GoogleFonts.roboto(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                      style: GoogleFonts.roboto(
                                        height: 1,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                        child: Builder(builder: (context) {
                          if (_records.isEmpty) {
                            return Container(
                              alignment: Alignment.center,
                              child: Text(
                                "No BMI data available",
                                style: GoogleFonts.roboto(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }

                          final latestBmiRecord = _records.last;

                          double fraction;

                          if (latestBmiRecord.bmi < 19) {
                            fraction = 0.23 * (latestBmiRecord.bmi / 19.0);
                          } else if (latestBmiRecord.bmi >= 19 &&
                              latestBmiRecord.bmi <= 24) {
                            fraction =
                                (0.27 * ((latestBmiRecord.bmi - 19) / 5)) +
                                    0.23;
                          } else if (latestBmiRecord.bmi > 24 &&
                              latestBmiRecord.bmi <= 29) {
                            fraction =
                                (0.27 * ((latestBmiRecord.bmi - 24) / 5)) + 0.5;
                          } else {
                            fraction = clampDouble(
                                (0.23 * ((latestBmiRecord.bmi - 29) / 11)),
                                0,
                                1);
                          }
                          return BMIGraph(frac: fraction);
                        }),
                      ),
                      Divider(
                        height: 4,
                        color: Colors.grey.shade600,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [],
                          ),
                          TextButton(
                            onPressed: () async {
                              final path = await getDatabasesPath();
                              final db = await initAppDatabase(path);
                              final user = await User.currentUser;

                              if (!context.mounted) return;
                              Navigator.pushNamed(context, '/bmi-tracking',
                                  arguments: {
                                    "db": db,
                                    "user": user,
                                  });
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(fgColor),
                              visualDensity: VisualDensity.comfortable,
                              shape: WidgetStateProperty.all(
                                const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            child: Text(
                              "View BMI History",
                              style: GoogleFonts.roboto(
                                color: Colors.white,
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
          ],
        ),
      ),
    );
  }
}
