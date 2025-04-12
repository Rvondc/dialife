import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dialife/activity_log/entities.dart';
import 'package:dialife/activity_log/no_data.dart';
import 'package:dialife/activity_log/utils.dart';
import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:dialife/blood_glucose_tracking/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

class ActivityLog extends StatefulWidget {
  final Database db;

  const ActivityLog({
    super.key,
    required this.db,
  });

  @override
  State<ActivityLog> createState() => _ActivityLogState();
}

class _ActivityLogState extends State<ActivityLog> {
  @override
  Widget build(BuildContext context) {
    reset() {
      setState(() {});
    }

    return waitForFuture(
      future: widget.db.query("ActivityRecord"),
      loading: const Scaffold(
        body: SpinKitCircle(color: fgColor),
      ),
      builder: (context, data) {
        final parsedActivityRecordData = ActivityRecord.fromListOfMaps(data);

        parsedActivityRecordData
            .sort((a, b) => a.createdAt.compareTo(b.createdAt));

        return _ActivityLogInternalScaffold(
          db: widget.db,
          reset: reset,
          records: parsedActivityRecordData,
        );
      },
    );
  }
}

class _ActivityLogInternalScaffold extends StatelessWidget {
  final Database db;
  final void Function() reset;
  final List<ActivityRecord> records;

  const _ActivityLogInternalScaffold({
    required this.db,
    required this.reset,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(
          title: const Text("Activity Log"),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: ActivityLogNoData(db: db),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text("Activity Log"),
        actions: [
          IconButton(
            onPressed: () async {
              await FilePicker.platform.clearTemporaryFiles();
              final directory = await FilePicker.platform.getDirectoryPath();
              if (!await Permission.storage.status.isGranted) {
                await Permission.storage.request();
              }

              if (directory == null) {
                return;
              }

              final path = Directory(directory);
              final file = File(join(path.path, "activity_log.dialife.csv"));

              if (await file.exists()) {
                await file.delete();
              }

              try {
                for (var record in records) {
                  await file.writeAsString("${record.toCSVRow()}\n",
                      mode: FileMode.writeOnlyAppend);
                }

                await file.create();
              } catch (e) {
                // TODO: Handle failure
                rethrow;
              }
            },
            icon: const Icon(
              Symbols.export_notes_rounded,
              color: Colors.black,
              size: 32,
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: fgColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () async {
          await Navigator.of(context).pushNamed(
            "/activity-log/editor",
            arguments: {
              "db": db,
            },
          );

          reset();
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: _ActivityLogInternal(
            records: records,
            reset: reset,
            db: db,
          ),
        ),
      ),
    );
  }
}

const aerobicColor = Color(0xFFFFB4B4);
const balanceColor = Color(0xFFB2B1FC);
const flexibilityColor = Color(0xFFA7E5FF);
const strengthColor = Color(0xFFCFFF9E);

class _ActivityLogInternal extends StatefulWidget {
  final Database db;
  final void Function() reset;
  final List<ActivityRecord> records;

  const _ActivityLogInternal({
    required this.db,
    required this.reset,
    required this.records,
  });

  @override
  State<_ActivityLogInternal> createState() => _ActivityLogInternalState();
}

class _ActivityLogInternalState extends State<_ActivityLogInternal> {
  int touchedGroupIndex = -1;
  String _scope = "Daily";

  @override
  Widget build(BuildContext context) {
    final recordByDays = dayConsolidateActivityRecord(widget.records);
    final validDays = validDaysActivityRecord(widget.records);

    return Padding(
      padding: const EdgeInsets.only(
        top: 30,
        left: 10,
        right: 10,
        bottom: 30,
      ),
      child: Column(
        children: [
          Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(10),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  padding: const EdgeInsets.all(10),
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Text(
                            "ACTIVITY LOG",
                            style: GoogleFonts.istokWeb(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          AspectRatio(
                            aspectRatio: 10 / 8,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                groupsSpace: 12,
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: fgColor.withOpacity(0.2),
                                    strokeWidth: 1,
                                  ),
                                ),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border.symmetric(
                                    horizontal: BorderSide(
                                      color: fgColor.withOpacity(0.2),
                                    ),
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  topTitles: const AxisTitles(),
                                  leftTitles: const AxisTitles(),
                                  rightTitles: const AxisTitles(),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 36,
                                      getTitlesWidget: (value, meta) {
                                        return SideTitleWidget(
                                          meta: TitleMeta(
                                            min: 0,
                                            max: 1,
                                            parentAxisSize: 10,
                                            axisPosition: 1,
                                            appliedInterval: 1,
                                            sideTitles: SideTitles(),
                                            formattedValue: "formattedValue",
                                            axisSide: AxisSide.bottom,
                                            rotationQuarterTurns: 1,
                                          ),
                                          child: Text(
                                            DateFormat("dd/MM").format(
                                              validDays[value.toInt()],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                barGroups: validDays
                                    .asMap()
                                    .entries
                                    .toList()
                                    .reversed
                                    .take(5)
                                    .toList()
                                    .reversed
                                    .map((entry) {
                                  final current = recordByDays[entry.value];

                                  int aerobicTotalDuration = 0;
                                  int balanceTotalDuration = 0;
                                  int flexibilityTotalDuration = 0;
                                  int strengthTotalDuration = 0;

                                  for (var element in current!) {
                                    switch (element.type) {
                                      case ExerciseType.aerobic:
                                        aerobicTotalDuration +=
                                            element.duration;
                                      case ExerciseType.balance:
                                        balanceTotalDuration +=
                                            element.duration;
                                      case ExerciseType.flexibility:
                                        flexibilityTotalDuration +=
                                            element.duration;
                                      case ExerciseType.strength:
                                        strengthTotalDuration +=
                                            element.duration;
                                    }
                                  }

                                  return generateBarGroup(
                                    entry.key,
                                    aerobicTotalDuration,
                                    balanceTotalDuration,
                                    flexibilityTotalDuration,
                                    strengthTotalDuration,
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          Row(
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
                                        color: Colors.black.withOpacity(0.3),
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
                              const SizedBox(width: 2),
                              Text(
                                "Walking",
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  color: const Color(0xFFA4A0A0),
                                ),
                              ),
                              const Expanded(child: SizedBox()),
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
                                        color: Colors.black.withOpacity(0.3),
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
                              const SizedBox(width: 2),
                              Text(
                                "Jogging",
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  color: const Color(0xFFA4A0A0),
                                ),
                              ),
                              const Expanded(child: SizedBox()),
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
                                        color: Colors.black.withOpacity(0.3),
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
                              const SizedBox(width: 2),
                              Text(
                                "Lifting",
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  color: const Color(0xFFA4A0A0),
                                ),
                              ),
                              const Expanded(child: SizedBox()),
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
                                        color: Colors.black.withOpacity(0.3),
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
                              const SizedBox(width: 2),
                              Text(
                                "Zumba",
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  color: const Color(0xFFA4A0A0),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Positioned(
                        top: 30,
                        child: Text(
                          "Minutes",
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IntrinsicWidth(
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            labelText: '',
                            isDense: true,
                            contentPadding: const EdgeInsets.all(4),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          value: "Daily",
                          style: GoogleFonts.montserrat(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                          items: ["Daily", "Weekly", "Monthly"]
                              .map(
                                (val) => DropdownMenuItem(
                                  value: val,
                                  child: Text(val),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }

                            setState(() {
                              _scope = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Activity",
                        style: GoogleFonts.montserrat(fontSize: 14),
                      ),
                    ],
                  ),
                  ...validDays.reversed.where((date) {
                    final latest = validDays.last
                        .copyWith(second: validDays.last.second + 1);
                    final dayScope = switch (_scope) {
                      "Daily" => 1,
                      "Weekly" => 7,
                      "Monthly" => 30,
                      String() => 1,
                    };

                    final start = latest.subtract(Duration(days: dayScope));

                    return date.isAfter(start) && date.isBefore(latest);
                  }).map(
                    (day) => Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: generateRecordsInDay(recordByDays[day]!, context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () async {
              await Navigator.of(context).pushNamed(
                "/activity-log/editor",
                arguments: {"db": widget.db},
              );

              widget.reset();
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(fgColor),
              overlayColor: WidgetStateProperty.all(
                Colors.white.withOpacity(0.3),
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            child: const Text(
              "VIEW HISTORY",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData generateBarGroup(
    int index,
    int aerobicMins,
    int balanceMins,
    int flexibilityMins,
    int strengthMins,
  ) {
    return BarChartGroupData(
      x: index,
      barRods: [
        () {
          if (aerobicMins == 0) {
            return null;
          }

          return BarChartRodData(
            toY: aerobicMins.toDouble(),
            color: aerobicColor,
            width: 10,
          );
        }(),
        () {
          if (balanceMins == 0) {
            return null;
          }

          return BarChartRodData(
            toY: balanceMins.toDouble(),
            color: balanceColor,
            width: 10,
          );
        }(),
        () {
          if (flexibilityMins == 0) {
            return null;
          }

          return BarChartRodData(
            toY: flexibilityMins.toDouble(),
            color: flexibilityColor,
            width: 10,
          );
        }(),
        () {
          if (strengthMins == 0) {
            return null;
          }

          return BarChartRodData(
            toY: strengthMins.toDouble(),
            color: strengthColor,
            width: 10,
          );
        }(),
      ].whereNotNull().toList(),
    );
  }

  Widget generateRecordsInDay(
      List<ActivityRecord> records, BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFECEC),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              DateFormat("dd/MM, EEEE").format(records.first.createdAt),
              style: GoogleFonts.montserrat(
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            ...records.map((record) {
              final color = switch (record.type) {
                ExerciseType.aerobic => aerobicColor,
                ExerciseType.strength => strengthColor,
                ExerciseType.balance => balanceColor,
                ExerciseType.flexibility => flexibilityColor,
              };

              return GestureDetector(
                onTap: () async {
                  await Navigator.of(context).pushNamed(
                    "/activity-log/input",
                    arguments: {
                      "db": widget.db,
                      "existing": record,
                    },
                  );

                  widget.reset();
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: ListTile(
                      dense: true,
                      title: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color,
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
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
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${record.duration} mins",
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                "Frequency: x${record.frequency}",
                                style: GoogleFonts.montserrat(),
                              ),
                            ],
                          ),
                          const Expanded(child: SizedBox()),
                          Text(
                            "Started: ${DateFormat("hh:mm a").format(record.createdAt)}",
                            style: GoogleFonts.montserrat(fontSize: 14),
                          ),
                        ],
                      ),
                      subtitle: Text(
                          "Notes: ${record.notes.isEmpty ? "--" : record.notes}"),
                      tileColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
