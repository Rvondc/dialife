import 'dart:math';

import 'package:dialife/activity_log/activity_log.dart';
import 'package:dialife/activity_log/entities.dart';
import 'package:dialife/activity_log/utils.dart';
import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityCarousel extends StatelessWidget {
  final List<ActivityRecord> _records;

  const ActivityCarousel({
    super.key,
    required List<ActivityRecord> records,
  }) : _records = records;

  int _cumulativeMins(ExerciseType type) {
    final records = _records
        .where((record) => record.type == type)
        .where((record) => record.createdAt.day == DateTime.now().day)
        .toList();

    var sum = 0;

    for (var record in records) {
      sum += record.duration;
    }

    return sum;
  }

  int _flexOffsetFor(ExerciseType type) {
    final cumAero = _cumulativeMins(ExerciseType.aerobic);
    final cumStr = _cumulativeMins(ExerciseType.strength);
    final cumBal = _cumulativeMins(ExerciseType.balance);
    final cumFlex = _cumulativeMins(ExerciseType.flexibility);

    final maxim = max(max(max(cumAero, cumStr), cumBal), cumFlex);

    switch (type) {
      case ExerciseType.aerobic:
        return maxim - cumAero;
      case ExerciseType.strength:
        return maxim - cumStr;
      case ExerciseType.balance:
        return maxim - cumBal;
      case ExerciseType.flexibility:
        return maxim - cumFlex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final validDays = validDaysActivityRecord(_records);

    final withinToday =
        validDays.where((day) => day.day == DateTime.now().day).toList();

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
              "Activity Log (Today)",
              style: GoogleFonts.roboto(
                fontSize: 18,
                height: 1,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 72,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade600),
                  left: BorderSide(color: Colors.grey.shade600),
                ),
              ),
              child: withinToday.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(
                        top: 24,
                        left: 12,
                      ),
                      child: Text(
                        "No activity log for today",
                        style: GoogleFonts.roboto(fontWeight: FontWeight.w500),
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                flex: _cumulativeMins(ExerciseType.balance),
                                child: Container(
                                  padding: const EdgeInsets.only(right: 4),
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(3),
                                      bottomRight: Radius.circular(3),
                                    ),
                                    color: balanceColor,
                                  ),
                                  child: _cumulativeMins(ExerciseType.balance) >
                                          0
                                      ? Text(
                                          "${_cumulativeMins(ExerciseType.balance)}",
                                          textAlign: TextAlign.right,
                                          style:
                                              GoogleFonts.roboto(fontSize: 10),
                                        )
                                      : const SizedBox(),
                                ),
                              ),
                              Expanded(
                                flex: _flexOffsetFor(ExerciseType.balance),
                                child: const SizedBox(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                flex: _cumulativeMins(ExerciseType.flexibility),
                                child: Container(
                                  padding: const EdgeInsets.only(right: 4),
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(3),
                                      bottomRight: Radius.circular(3),
                                    ),
                                    color: flexibilityColor,
                                  ),
                                  child: _cumulativeMins(
                                              ExerciseType.flexibility) >
                                          0
                                      ? Text(
                                          "${_cumulativeMins(ExerciseType.flexibility)}",
                                          textAlign: TextAlign.right,
                                          style:
                                              GoogleFonts.roboto(fontSize: 10),
                                        )
                                      : const SizedBox(),
                                ),
                              ),
                              Expanded(
                                flex: _flexOffsetFor(ExerciseType.flexibility),
                                child: const SizedBox(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                flex: _cumulativeMins(ExerciseType.strength),
                                child: Container(
                                  padding: const EdgeInsets.only(right: 4),
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(3),
                                      bottomRight: Radius.circular(3),
                                    ),
                                    color: strengthColor,
                                  ),
                                  child:
                                      _cumulativeMins(ExerciseType.strength) > 0
                                          ? Text(
                                              "${_cumulativeMins(ExerciseType.strength)}",
                                              textAlign: TextAlign.right,
                                              style: GoogleFonts.roboto(
                                                  fontSize: 10),
                                            )
                                          : const SizedBox(),
                                ),
                              ),
                              Expanded(
                                flex: _flexOffsetFor(ExerciseType.strength),
                                child: const SizedBox(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                flex: _cumulativeMins(ExerciseType.aerobic),
                                child: Container(
                                  padding: const EdgeInsets.only(right: 4),
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(3),
                                      bottomRight: Radius.circular(3),
                                    ),
                                    color: aerobicColor,
                                  ),
                                  child: Text(
                                    "${_cumulativeMins(ExerciseType.aerobic)}",
                                    textAlign: TextAlign.right,
                                    style: GoogleFonts.roboto(fontSize: 10),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: _flexOffsetFor(ExerciseType.aerobic),
                                child: const SizedBox(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
            ),
            const SizedBox(height: 1),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgPicture.asset(
                  "assets/activity_indicators.svg",
                  width: 200,
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
                    "View Activities",
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
