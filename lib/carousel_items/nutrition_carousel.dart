import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:dialife/nutrition_log/entities.dart';
import 'package:dialife/nutrition_log/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class NutritionCarousel extends StatelessWidget {
  final List<NutritionRecord> _records;

  const NutritionCarousel({
    super.key,
    required List<NutritionRecord> records,
  }) : _records = records;

  @override
  Widget build(BuildContext context) {
    _records.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    var validDays = validDaysNutritionRecord(_records)
        .where((day) => day.day == DateTime.now().day)
        .toList();

    final consolidated = dayConsolidateNutritionRecord(_records);

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
              "Nutrition Log",
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 20,
                  ),
                  margin: const EdgeInsets.only(bottom: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Builder(
                    builder: (context) {
                      final now = DateTime.now();

                      final month = DateFormat("MMM").format(now);
                      final day = DateFormat("d").format(now);
                      final dayAsStr = DateFormat("EEE").format(now);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            month,
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              color: Colors.red,
                              height: 0.8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            day,
                            style: GoogleFonts.roboto(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dayAsStr,
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              height: 0.8,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          if (validDays.isEmpty) {
                            return Text(
                              "Nothing for today",
                              style: GoogleFonts.roboto(
                                color: Colors.grey.shade700,
                              ),
                            );
                          }

                          final today = consolidated[validDays.last];

                          if (today == null) {
                            return Text(
                              "Nothing for today",
                              style: GoogleFonts.roboto(
                                color: Colors.grey.shade700,
                              ),
                            );
                          }

                          final latest = today.first;
                          final time =
                              DateFormat("h:mm a").format(latest.createdAt);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    latest.dayDescription,
                                    style: GoogleFonts.roboto(
                                      color: Colors.grey.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    time,
                                    style: GoogleFonts.roboto(
                                      color: Colors.grey.shade800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: latest.foods.map(
                                    (food) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 2,
                                          horizontal: 6,
                                        ),
                                        margin: const EdgeInsets.only(
                                          bottom: 2,
                                          left: 2,
                                          right: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          color: fgColor,
                                        ),
                                        child: Text(
                                          food,
                                          style: GoogleFonts.roboto(
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      );
                                    },
                                  ).toList(),
                                ),
                              ),
                            ],
                          );
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
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
                  children: [],
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
                    "View Meals",
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
