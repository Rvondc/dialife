import 'package:collection/collection.dart';
import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:dialife/medication_tracking/entities.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MedicationReminderCarousel extends StatelessWidget {
  final List<MedicationRecordDetails> _records;

  const MedicationReminderCarousel({
    super.key,
    required List<MedicationRecordDetails> records,
  }) : _records = records;

  @override
  Widget build(BuildContext context) {
    final groupedRecords = groupBy(
      _records,
      (record) => record.medicationDatetime.copyWith(
        hour: 0,
        minute: 0,
        second: 0,
        millisecond: 0,
        microsecond: 0,
      ),
    );

    final filtered = groupedRecords.keys
        .where((param) => param.isAfter(
              DateTime.now().copyWith(day: DateTime.now().day - 1),
            ))
        .toList();

    filtered.sort((a, b) => a.compareTo(b));

    // NOTE: The code below retrieves the first reminder record for today
    // debugPrint(groupedRecords[filtered.first]!.first.toString());

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
              "Medications",
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
                Column(
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
                        if (filtered.isEmpty || _records.isEmpty) {
                          return Text(
                            "Nothing for today",
                            style: GoogleFonts.roboto(
                              color: Colors.grey.shade700,
                            ),
                          );
                        }

                        final today = groupedRecords[filtered.first]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              today.first.medicineName,
                              style: GoogleFonts.roboto(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Wrap(
                              children: today.map((record) {
                                final hour = DateFormat("h:mm a")
                                    .format(record.medicationDatetime);

                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  margin: const EdgeInsets.only(right: 4),
                                  decoration: BoxDecoration(
                                    color: fgColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    hour,
                                    style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      height: 1.5,
                                    ),
                                  ),
                                );
                              }).toList(),
                            )
                          ],
                        );
                      },
                    )
                  ],
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
                    "View All Medications",
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
