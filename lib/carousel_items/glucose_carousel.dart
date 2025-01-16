import 'package:dialife/blood_glucose_tracking/calculate_average.dart';
import 'package:dialife/blood_glucose_tracking/entities.dart';
import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:flutter/material.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:google_fonts/google_fonts.dart';

class GlucoseCarousel extends StatelessWidget {
  final List<GlucoseRecord> _records;

  const GlucoseCarousel({
    super.key,
    required List<GlucoseRecord> records,
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
              "Glucose Levels",
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        color: const Color(0xFFCCCF10),
                      ),
                      Text(
                        "Latest",
                        style: GoogleFonts.roboto(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Builder(
                        builder: (context) {
                          if (_records.isEmpty) {
                            return Text(
                              "--",
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                            );
                          }

                          final lastest =
                              _records.last.glucoseLevel.toStringAsFixed(2);

                          return Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: lastest,
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    height: 1.1,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                TextSpan(
                                  text: " mmol/L",
                                  style: GoogleFonts.roboto(
                                    fontSize: 13,
                                  ),
                                ),
                              ],
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
                      Container(
                        width: 4,
                        height: 20,
                        color: const Color(0xFF102DCF),
                      ),
                      Text(
                        "Week Average",
                        style: GoogleFonts.roboto(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Builder(
                        builder: (context) {
                          final start =
                              DateTime.now().subtract(const Duration(days: 7));
                          final end = DateTime.now();

                          final average = calcAverageGlucoseRecord(
                            start,
                            end,
                            _records,
                          );

                          if (average == null) {
                            return Text(
                              "--",
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                            );
                          }

                          return Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: average.toStringAsFixed(2),
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    height: 1.1,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                TextSpan(
                                  text: " mmol/L",
                                  style: GoogleFonts.roboto(
                                    fontSize: 13,
                                  ),
                                ),
                              ],
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
                      Container(
                        width: 4,
                        height: 20,
                        color: const Color(0xFF865F00),
                      ),
                      Text(
                        "Last Updated",
                        style: GoogleFonts.roboto(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Builder(
                        builder: (context) {
                          if (_records.isEmpty) {
                            return Text(
                              "--",
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                            );
                          }

                          final latestAgo = GetTimeAgo.parse(
                            _records.last.bloodTestDate,
                            pattern: 'MMM. dd, y',
                          );

                          return Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: latestAgo,
                                  style: GoogleFonts.roboto(
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Divider(
              height: 4,
              color: Colors.grey.shade600,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Status",
                      style: GoogleFonts.roboto(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
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
                    "View Full History",
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
    );
  }
}
