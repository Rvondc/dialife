import 'package:collection/collection.dart';
import 'package:dialife/activity_log/activity_log.dart';
import 'package:dialife/activity_log/entities.dart';
import 'package:dialife/activity_log/utils.dart';
import 'package:dialife/nutrition_log/entities.dart';
import 'package:dialife/nutrition_log/nutrition_log.dart';
import 'package:dialife/nutrition_log/utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class NutritionAndActivity extends StatefulWidget {
  final void Function() resetNutritionRecords;
  final void Function() resetActivityRecords;
  final List<NutritionRecord> nutritionRecords;
  final List<ActivityRecord> activityRecords;
  final List<WaterRecord> waterRecords;
  final Database db;

  const NutritionAndActivity({
    required this.db,
    required this.resetNutritionRecords,
    required this.resetActivityRecords,
    required this.activityRecords,
    required this.waterRecords,
    required this.nutritionRecords,
    super.key,
  });

  @override
  State<NutritionAndActivity> createState() => _NutritionAndActivityState();
}

class _NutritionAndActivityState extends State<NutritionAndActivity> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final waterRecords = widget.waterRecords
        .where((element) => element.time.isAfter(DateTime.now().copyWith(
              hour: 0,
              minute: 0,
              second: 0,
              millisecond: 0,
            )))
        .toList();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        top: 15,
        left: 10,
        right: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4.0,
            spreadRadius: 0.0,
            offset: const Offset(0.0, 4.0),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () async {
                  await Navigator.of(context).pushNamed(
                    "/nutrition-log",
                    arguments: {
                      "db": widget.db,
                    },
                  );

                  widget.resetNutritionRecords();
                },
                child: Builder(
                  builder: (context) {
                    if (widget.nutritionRecords.isEmpty) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "Latest Nutrition Log",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: AspectRatio(
                              aspectRatio: 1.1,
                              child: PieChart(
                                PieChartData(
                                  borderData: FlBorderData(
                                    show: false,
                                  ),
                                  sectionsSpace: 0,
                                  centerSpaceRadius: 0,
                                  sections: noData(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    final nutritionDaysMap =
                        dayConsolidateNutritionRecord(widget.nutritionRecords);
                    final nutritionDays =
                        validDaysNutritionRecord(widget.nutritionRecords);

                    nutritionDays.sort((a, b) => a.compareTo(b));
                    final latestNutritionRecords =
                        nutritionDaysMap[nutritionDays.last];

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 8.0,
                          ),
                          child: Text(
                            "Latest Nutrition Log",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            DateFormat("dd / MM / yyyy")
                                .format(nutritionDays.last),
                            maxLines: 1,
                            style: GoogleFonts.montserrat(fontSize: 12),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 16),
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Image.asset(
                                  "assets/water.png",
                                  height: 150,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 36),
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          offset: const Offset(0, 3),
                                          spreadRadius: 0,
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      "${waterRecords.map((e) => e.glasses).sum} ${waterRecords.map((e) => e.glasses).sum > 1 ? "glasses" : "glass"} Drank",
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.only(bottom: 12.0, top: 8),
                        //   child: AspectRatio(
                        //     aspectRatio: 1.1,
                        //     child: PieChart(
                        //       PieChartData(
                        //         borderData: FlBorderData(
                        //           show: false,
                        //         ),
                        //         sectionsSpace: 0,
                        //         centerSpaceRadius: 0,
                        //         sections: representNutritionRecord(
                        //             latestNutritionRecords!),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const VerticalDivider(),
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () async {
                  await Navigator.of(context).pushNamed(
                    "/activity-log",
                    arguments: {
                      "db": widget.db,
                    },
                  );

                  widget.resetActivityRecords();
                },
                child: Builder(
                  builder: (context) {
                    if (widget.activityRecords.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          top: 8,
                          bottom: 8,
                          right: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "Activity Log",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const Expanded(child: SizedBox()),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey.shade500,
                              ),
                              height: 100,
                              alignment: Alignment.center,
                              child: Text(
                                "No Data",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                      );
                    }

                    final activityDaysMap =
                        dayConsolidateActivityRecord(widget.activityRecords);
                    final activityDays =
                        validDaysActivityRecord(widget.activityRecords);

                    activityDays.sort((a, b) => a.compareTo(b));
                    final latestActivityRecords =
                        activityDaysMap[activityDays.last];

                    int aerobicTotalDuration = 0;
                    int balanceTotalDuration = 0;
                    int flexibilityTotalDuration = 0;
                    int strengthTotalDuration = 0;

                    for (var element in latestActivityRecords!) {
                      switch (element.type) {
                        case ExerciseType.aerobic:
                          aerobicTotalDuration += element.duration;
                        case ExerciseType.balance:
                          balanceTotalDuration += element.duration;
                        case ExerciseType.flexibility:
                          flexibilityTotalDuration += element.duration;
                        case ExerciseType.strength:
                          strengthTotalDuration += element.duration;
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            "Activity Log",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              DateFormat("dd / MM / yyyy")
                                  .format(activityDays.last),
                              maxLines: 1,
                              style: GoogleFonts.montserrat(fontSize: 10),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Walking:",
                                style: GoogleFonts.montserrat(fontSize: 12),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        boxShadow: [
                                          const BoxShadow(
                                            color: aerobicColor,
                                          ),
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            offset: const Offset(0, -3),
                                            spreadRadius: 0,
                                            blurRadius: 5,
                                          ),
                                        ],
                                      ),
                                      width: 10,
                                      height: 10,
                                    ),
                                  ),
                                  Text(
                                    "$aerobicTotalDuration mins",
                                    style: GoogleFonts.montserrat(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Jogging:",
                                style: GoogleFonts.montserrat(fontSize: 12),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        boxShadow: [
                                          const BoxShadow(
                                            color: balanceColor,
                                          ),
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            offset: const Offset(0, -3),
                                            spreadRadius: 0,
                                            blurRadius: 5,
                                          ),
                                        ],
                                      ),
                                      width: 10,
                                      height: 10,
                                    ),
                                  ),
                                  Text(
                                    "$balanceTotalDuration mins",
                                    style: GoogleFonts.montserrat(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Lifting:",
                                style: GoogleFonts.montserrat(fontSize: 12),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        boxShadow: [
                                          const BoxShadow(
                                            color: flexibilityColor,
                                          ),
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            offset: const Offset(0, -3),
                                            spreadRadius: 0,
                                            blurRadius: 5,
                                          ),
                                        ],
                                      ),
                                      width: 10,
                                      height: 10,
                                    ),
                                  ),
                                  Text(
                                    "$flexibilityTotalDuration mins",
                                    style: GoogleFonts.montserrat(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Zumba:",
                                style: GoogleFonts.montserrat(fontSize: 12),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        boxShadow: [
                                          const BoxShadow(
                                            color: strengthColor,
                                          ),
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            offset: const Offset(0, -3),
                                            spreadRadius: 0,
                                            blurRadius: 5,
                                          ),
                                        ],
                                      ),
                                      width: 10,
                                      height: 10,
                                    ),
                                  ),
                                  Text(
                                    "$strengthTotalDuration mins",
                                    style: GoogleFonts.montserrat(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<PieChartSectionData> representNutritionRecord(
    List<NutritionRecord> records) {
  final totalCarbs = records.map((e) => 3.0).sum;
  final totalFats = records.map((e) => 3.0).sum;
  final totalProtein = records.map((e) => 3.0).sum;

  return [
    PieChartSectionData(
      color: fatsColor,
      value: totalFats,
      title: "${totalFats.toStringAsFixed(0)}g",
      radius: 90,
      badgePositionPercentageOffset: 1,
      titleStyle: GoogleFonts.montserrat(),
      badgeWidget: _Badge(
        Image.asset("assets/fat.png"),
        size: 40,
        borderColor: fatsColor,
      ),
    ),
    PieChartSectionData(
      color: proteinColor,
      value: totalProtein,
      title: "${totalProtein.toStringAsFixed(0)}g",
      radius: 90,
      badgePositionPercentageOffset: 1,
      titleStyle: GoogleFonts.montserrat(),
      badgeWidget: _Badge(
        Image.asset("assets/protein.png"),
        size: 40,
        borderColor: proteinColor,
      ),
    ),
    PieChartSectionData(
      color: carbsColor,
      value: totalCarbs,
      radius: 90,
      badgePositionPercentageOffset: 1,
      title: "${totalCarbs.toStringAsFixed(0)}g",
      titleStyle: GoogleFonts.montserrat(),
      badgeWidget: const _Badge(
        Icon(Icons.breakfast_dining_outlined),
        size: 40,
        borderColor: carbsColor,
      ),
    ),
  ];
}

List<PieChartSectionData> noData() {
  return [
    PieChartSectionData(
      color: Colors.grey,
      radius: 90,
      title: "No Data",
      titleStyle: GoogleFonts.montserrat(
        fontSize: 16,
      ),
      titlePositionPercentageOffset: 0,
    ),
  ];
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
          color: Colors.black,
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
