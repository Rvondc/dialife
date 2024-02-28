import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dialife/blood_glucose_tracking/calculate_average.dart';
import 'package:dialife/blood_glucose_tracking/entities.dart';
import 'package:dialife/blood_glucose_tracking/no_data.dart';
import 'package:dialife/blood_glucose_tracking/utils.dart';
import 'package:dialife/user.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:toggle_switch/toggle_switch.dart';

const fgColor = Color(0xFF4C66F0);
const bgColorToggleSwitch = Color(0xFFBFBFBF);
const a1cPurple = Color.fromARGB(255, 81, 31, 163);

class GlucoseTracking extends StatefulWidget {
  final User user;
  final Database db;

  const GlucoseTracking({
    super.key,
    required this.db,
    required this.user,
  });

  @override
  State<GlucoseTracking> createState() => _GlucoseTrackingState();
}

class _GlucoseTrackingState extends State<GlucoseTracking> {
  @override
  Widget build(BuildContext context) {
    const loading = Scaffold(
      body: SpinKitCircle(color: fgColor),
    );

    reset() {
      setState(() {});
    }

    return waitForFuture(
      loading: loading,
      future: Future.wait(
        [widget.db.query("GlucoseRecord")],
      ),
      builder: (context, data) {
        // NOTE: Should pull from database in production
        final parsedGlucoseRecordData = GlucoseRecord.fromListOfMaps(data[0]);
        // final parsedGlucoseRecordData = GlucoseRecord.mock(
        //   count: 90,
        //   daySpan: 30,
        //   a1cInDay: true,
        // );
        parsedGlucoseRecordData
            .sort((a, b) => a.bloodTestDate.compareTo(b.bloodTestDate));

        // final parsedA1CRecordData = A1CRecord.mock(1, 1);
        // parsedA1CRecordData
        //     .sort((a, b) => a.bloodTestDate.compareTo(b.bloodTestDate));

        return _GlucoseTrackingInternalScaffold(
          glucoseRecords: parsedGlucoseRecordData,
          db: widget.db,
          user: widget.user,
          reset: reset,
        );
      },
    );
  }
}

class _GlucoseTrackingInternalScaffold extends StatelessWidget {
  final List<GlucoseRecord> glucoseRecords;
  final Database db;
  final User user;
  final void Function() reset;

  const _GlucoseTrackingInternalScaffold({
    super.key,
    required this.glucoseRecords,
    required this.db,
    required this.user,
    required this.reset,
  });

  @override
  Widget build(BuildContext context) {
    if (glucoseRecords.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(
          title: const Text("Glucose"),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: GlucoseTrackingNoData(
              db: db,
              user: user,
            ),
          ),
        ),
      );
    }

    final glucoseTracking = _GlucoseTrackingInternal(
      glucoseRecords: glucoseRecords,
      user: user,
      db: db,
      reset: reset,
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text("Glucose"),
        actions: [
          IconButton(
            onPressed: () async {
              final directory = await FilePicker.platform.getDirectoryPath();
              await FilePicker.platform.clearTemporaryFiles();
              if (!await Permission.storage.status.isGranted) {
                await Permission.storage.request();
              }

              if (directory == null) {
                return;
              }

              final path = Directory(directory);
              final file =
                  File(join(path.path, "blood_glucose_tracking.dialife.csv"));

              if (await file.exists()) {
                await file.delete();
              }

              try {
                for (var record in glucoseRecords) {
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
          await Navigator.of(context)
              .pushNamed("/blood-glucose-tracking/input", arguments: {
            "user": user,
            "db": db,
          });

          reset();
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          reset();

          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
                top: 20,
                bottom: 10,
              ),
              child: glucoseTracking,
            ),
          ),
        ),
      ),
    );
  }
}

class _GlucoseTrackingInternal extends StatefulWidget {
  final List<GlucoseRecord> glucoseRecords;
  final Database db;
  final User user;
  final void Function() reset;

  const _GlucoseTrackingInternal({
    super.key,
    required this.reset,
    required this.db,
    required this.user,
    required this.glucoseRecords,
    // required this.a1CRecords,
  });

  @override
  State<_GlucoseTrackingInternal> createState() =>
      _GlucoseTrackingInternalState();
}

class _GlucoseTrackingInternalState extends State<_GlucoseTrackingInternal> {
  final _zoomPanBehavior = ZoomPanBehavior(
    enablePanning: true,
    enablePinching: true,
    enableDoubleTapZooming: true,
  );

  DateScope _scope = DateScope.day(DateTime.now());
  String _scopeString = "day";
  Units _unit = Units.mmolPerLiter;

  @override
  Widget build(BuildContext context) {
    // NOTE: Takes, at most, the last 3 records
    var lastRecords = widget.glucoseRecords.reversed.take(3);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Builder(
              builder: (context) {
                int index = 3;

                switch (_scopeString) {
                  case "allTime":
                    index = 3;
                  case "month":
                    index = 2;
                  case "week":
                    index = 1;
                  case "day":
                    index = 0;
                }

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 3,
                        offset: const Offset(0, 2), // Shadow position
                      ),
                    ],
                  ),
                  child: ToggleSwitch(
                    inactiveBgColor: bgColorToggleSwitch,
                    activeBgColor: const [Colors.white],
                    activeFgColor: Colors.black,
                    inactiveFgColor: Colors.grey.shade700,
                    cornerRadius: 8,
                    radiusStyle: true,
                    centerText: true,
                    activeBorders: [
                      Border.all(
                        width: 3,
                        color: bgColorToggleSwitch,
                      )
                    ],
                    labels: const ["DAY", "WEEK", "MONTH"],
                    minWidth: 150,
                    initialLabelIndex: index,
                    onToggle: (index) {
                      switch (index) {
                        case 0:
                          if (_scopeString == "day") return;
                          setState(() {
                            _scope = DateScope.day(DateTime.now());
                            _scopeString = "day";
                          });
                        case 1:
                          if (_scopeString == "week") return;
                          setState(() {
                            _scope = DateScope.week(DateTime.now());
                            _scopeString = "week";
                          });
                        case 2:
                          if (_scopeString == "month") return;
                          setState(() {
                            _scope = DateScope.month(DateTime.now());
                            _scopeString = "month";
                          });
                        case 3:
                          if (_scopeString == "allTime") return;
                          setState(() {
                            _scope = DateScope.allTime(DateTime.now());
                            _scopeString = "allTime";
                          });
                      }
                    },
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 3,
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(0, 2),
                  ),
                  BoxShadow(
                    blurRadius: 3,
                    color: fgColor.withOpacity(0.6),
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
              width: constraints.maxWidth * 0.75,
              child: Builder(
                builder: (context) {
                  double glucoseLevel;

                  if (_unit == Units.milligramsPerDeciliter) {
                    glucoseLevel =
                        mmolLToMgDL(widget.glucoseRecords.last.glucoseLevel);
                  } else {
                    glucoseLevel = widget.glucoseRecords.last.glucoseLevel;
                  }

                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 160,
                            child: AutoSizeText(
                              "Your Current Glucose",
                              maxLines: 1,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          FlutterSwitch(
                            value: _unit == Units.mmolPerLiter,
                            height: 20,
                            width: 45,
                            padding: 2,
                            duration: const Duration(milliseconds: 100),
                            activeColor: const Color(0xFFF7C6FF),
                            activeToggleColor: const Color(0xFF841896),
                            borderRadius: 10,
                            onToggle: (value) {
                              setState(() {
                                _unit = _unit == Units.mmolPerLiter
                                    ? Units.milligramsPerDeciliter
                                    : Units.mmolPerLiter;
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          AutoSizeText(
                            glucoseLevel.toStringAsFixed(2),
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            minFontSize: 44,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _unit == Units.mmolPerLiter ? " mmol/L" : "mg/dL",
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 3,
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                blurRadius: 3,
                color: fgColor.withOpacity(0.6),
                offset: const Offset(0, 2),
              )
            ],
          ),
          padding: const EdgeInsets.only(top: 10, bottom: 8),
          height: 280,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFF67E88B),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text("Normal"),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBCF10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text("Pre-Diabetes"),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB84141),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text("Diabetes"),
                    ],
                  ),
                ],
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    // NOTE: This convoluted step is required in order to get the last element that is not in the dataPoints list
                    final glucoseDataPointsMap = widget.glucoseRecords
                        .asMap()
                        .entries
                        .where(
                          (data) =>
                              _scope.start.isBefore(data.value.bloodTestDate) &&
                              _scope.end.isAfter(data.value.bloodTestDate),
                        )
                        .toList();

                    var glucoseDataPoints = glucoseDataPointsMap
                        .map((data) => data.value)
                        .where((record) => !record.isA1C)
                        .toList();

                    var a1cDataPoints = glucoseDataPointsMap
                        .map((data) => data.value)
                        .where((record) => record.isA1C)
                        .toList();

                    double interval = 1;

                    // NOTE: This is for optimization purposes
                    // TODO: Implement in settings
                    switch (_scopeString) {
                      case "allTime":
                        interval = 7;
                      // TODO: Replace with glucoseDataPoints
                      // dataPoints = sparsifyGlucoseRecords(dataPoints, 1);
                      case "month":
                        interval = 7;
                      // dataPoints = sparsify(dataPoints, 4);
                      case "week":
                        interval = 1;
                      // dataPoints = sparsify(dataPoints, 10);
                      case "day":
                        interval = 0.3;
                    }

                    final normalGlucoseRecMap = widget.glucoseRecords
                        .where(
                          (data) => !data.isA1C,
                        )
                        .toList()
                        .asMap()
                        .entries
                        .toList();

                    // NOTE: Selects the element just before the first element in glucoseDataPoints if it exists
                    // TODO: Fix this garbage
                    if (glucoseDataPointsMap.isNotEmpty &&
                        glucoseDataPointsMap.first.key - 1 >= 0) {
                      glucoseDataPoints.insert(
                          0,
                          normalGlucoseRecMap[normalGlucoseRecMap
                                  .where((element) =>
                                      element.value.id ==
                                      glucoseDataPoints.first.id)
                                  .first
                                  .key]
                              .value);
                    }

                    return SfCartesianChart(
                      backgroundColor: Colors.white,
                      zoomPanBehavior: _zoomPanBehavior,
                      crosshairBehavior: CrosshairBehavior(
                        enable: true,
                      ),
                      tooltipBehavior: TooltipBehavior(
                        animationDuration: 500,
                        duration: 2000,
                        enable: true,
                        builder:
                            (data, point, series, pointIndex, seriesIndex) {
                          var typedData = data as GlucoseRecord;

                          return Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: !typedData.isA1C
                                  ? const Color(0xFF67E88B)
                                  : const Color.fromARGB(255, 153, 104, 230),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                width: 1,
                                color: !typedData.isA1C
                                    ? const Color(0xFF016629)
                                    : a1cPurple,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  offset: const Offset(0, 4),
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: !typedData.isA1C
                                        ? const Color(0xFF016629)
                                        : a1cPurple,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 5),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 95,
                                        child: AutoSizeText(
                                          "${(typedData.isA1C ? "(A1C)" : "")} ${DateFormat.EEEE().format(typedData.bloodTestDate).toUpperCase()} ",
                                          maxLines: 1,
                                          minFontSize: 8,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        DateFormat("MMMM d")
                                            .format(typedData.bloodTestDate)
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          height: 1,
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        DateFormat("hh:mm a")
                                            .format(typedData.bloodTestDate)
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          height: 1,
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        width: 95,
                                        child: AutoSizeText(
                                          "Notes: ${typedData.notes.isEmpty ? "--" : "\n${typedData.notes}"}",
                                          maxLines: 4,
                                          overflow: TextOverflow.fade,
                                          style: const TextStyle(
                                            height: 1,
                                            color: Colors.black,
                                            fontSize: 10,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      primaryXAxis: DateTimeAxis(
                        axisLine: const AxisLine(color: fgColor, width: 2),
                        maximum: _scope.end,
                        minimum: _scopeString == "allTime"
                            ? glucoseDataPoints.first.bloodTestDate
                                .copyWith(hour: -12)
                            : _scope.start,
                        majorGridLines: const MajorGridLines(color: fgColor),
                        intervalType: DateTimeIntervalType.days,
                        interval: interval,
                        dateFormat: DateFormat.Md(),
                      ),
                      primaryYAxis: NumericAxis(
                        minimum: 0,
                        axisLine: const AxisLine(color: fgColor, width: 2),
                        maximum: () {
                          if (lastRecords.length > 1) {
                            return null;
                          }

                          return _unit == Units.milligramsPerDeciliter
                              ? 200.0
                              : mgDLToMmolL(200);
                        }(),
                        plotBands: [
                          PlotBand(
                            start: _unit == Units.milligramsPerDeciliter
                                ? 70
                                : mgDLToMmolL(70),
                            end: _unit == Units.milligramsPerDeciliter
                                ? 100
                                : mgDLToMmolL(100),
                            color: const Color(0xFF67E88B),
                            opacity: 0.5,
                          ),
                          PlotBand(
                            start: _unit == Units.milligramsPerDeciliter
                                ? 100
                                : mgDLToMmolL(100),
                            end: _unit == Units.milligramsPerDeciliter
                                ? 125
                                : mgDLToMmolL(125),
                            color: const Color(0xFFCBCF10),
                            opacity: 0.5,
                          ),
                          PlotBand(
                            start: _unit == Units.milligramsPerDeciliter
                                ? 125
                                : mgDLToMmolL(125),
                            color: const Color(0xFFB84141),
                            opacity: 0.5,
                          ),
                        ],
                        majorGridLines: const MajorGridLines(color: fgColor),
                      ),
                      trackballBehavior: TrackballBehavior(
                        enable: true,
                      ),
                      legend: const Legend(isVisible: true),
                      series: <ChartSeries<GlucoseRecord, DateTime>>[
                        LineSeries(
                          dataSource: glucoseDataPoints,
                          xValueMapper: (datum, index) => datum.bloodTestDate,
                          yValueMapper: (datum, index) =>
                              _unit == Units.milligramsPerDeciliter
                                  ? mmolLToMgDL(datum.glucoseLevel)
                                  : datum.glucoseLevel,
                          markerSettings: const MarkerSettings(
                            isVisible: true,
                            width: 5,
                            height: 5,
                            borderWidth: 1,
                            borderColor: fgColor,
                            color: fgColor,
                          ),
                          color: Colors.black,
                          width: 1,
                          isVisibleInLegend: false,
                        ),
                        LineSeries(
                          dataSource: a1cDataPoints,
                          dataLabelMapper: (datum, index) => "A1C",
                          dataLabelSettings:
                              const DataLabelSettings(isVisible: true),
                          xValueMapper: (datum, index) => datum.bloodTestDate,
                          yValueMapper: (datum, index) =>
                              _unit == Units.milligramsPerDeciliter
                                  ? mmolLToMgDL(datum.glucoseLevel)
                                  : datum.glucoseLevel,
                          isVisibleInLegend: false,
                          markerSettings: const MarkerSettings(
                            isVisible: true,
                            borderColor: a1cPurple,
                          ),
                          color: Colors.transparent,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.all(12),
          child: Text(
            "AVERAGE (${_unit == Units.milligramsPerDeciliter ? "mg/dL" : "mmol/L"})",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ),
        Builder(
          builder: (context) {
            final dayScope = DateScope.day(DateTime.now());
            final weekScope = DateScope.week(DateTime.now());
            final monthScope = DateScope.month(DateTime.now());

            double? dayAverage = calcAverageGlucoseRecord(
                dayScope.start, dayScope.end, widget.glucoseRecords);
            double? weekAverage = calcAverageGlucoseRecord(
                weekScope.start, weekScope.end, widget.glucoseRecords);
            double? monthAverage = calcAverageGlucoseRecord(
                monthScope.start, monthScope.end, widget.glucoseRecords);

            if (_unit == Units.milligramsPerDeciliter) {
              dayAverage = dayAverage == null ? null : mmolLToMgDL(dayAverage);
              weekAverage =
                  weekAverage == null ? null : mmolLToMgDL(weekAverage);
              monthAverage =
                  monthAverage == null ? null : mmolLToMgDL(monthAverage);
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                averageContainer("Day", dayAverage),
                averageContainer("Week", weekAverage),
                averageContainer("Month", monthAverage),
              ],
            );
          },
        ),
        const SizedBox(height: 10),
        Text(
          "Recent Records",
          style: TextStyle(color: Colors.grey.shade700),
        ),
        ...lastRecords.map(
          (record) {
            double glucoseLevel = _unit == Units.milligramsPerDeciliter
                ? mmolLToMgDL(record.glucoseLevel)
                : record.glucoseLevel;

            return GestureDetector(
              onTap: () async {
                await Navigator.of(context).pushNamed(
                  "/blood-glucose-tracking/input",
                  arguments: {
                    "user": widget.user,
                    "db": widget.db,
                    "existing": record,
                  },
                );

                widget.reset();
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: glucoseRecordListTile(
                  record.bloodTestDate,
                  record.notes,
                  glucoseLevel,
                  _unit,
                  record.isA1C,
                ),
              ),
            );
          },
        ),
        Container(
          margin: const EdgeInsets.all(12),
          child: TextButton(
            onPressed: () async {
              await Navigator.of(context).pushNamed(
                "/blood-glucose-tracking/editor",
                arguments: {
                  "user": widget.user,
                  "db": widget.db,
                },
              );

              widget.reset();
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(fgColor),
              overlayColor: MaterialStateProperty.all(
                Colors.white.withOpacity(0.3),
              ),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
            ),
            child: const Text(
              "VIEW REPORT HISTORY",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

Widget glucoseRecordListTile(
    DateTime date, String notes, double glucoseLevel, Units unit, bool isA1C) {
  return Material(
    elevation: 4,
    shadowColor: fgColor,
    borderRadius: BorderRadius.circular(12),
    child: ListTile(
      leading: Icon(
        Icons.receipt,
        color: !isA1C ? fgColor : a1cPurple,
      ),
      title: AutoSizeText(
        "${(isA1C ? "(A1C) " : "")}Date: ${DateFormat("MMM. dd, yyyy hh:mm a").format(date)}",
        maxLines: 1,
        maxFontSize: 14,
        minFontSize: 10,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: AutoSizeText(
        "Notes: ${notes.isEmpty ? "--" : notes}",
        maxLines: 3,
        overflow: TextOverflow.fade,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AutoSizeText(
            glucoseLevel.toStringAsFixed(2),
            minFontSize: 28,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            unit == Units.milligramsPerDeciliter ? "mg/dL" : "mmol/L",
            style: const TextStyle(fontSize: 10),
            textAlign: TextAlign.end,
          ),
        ],
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: Colors.white,
    ),
  );
}

Widget averageContainer(String label, double? average) {
  return Container(
    width: 100,
    height: 75,
    padding: const EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: fgColor.withOpacity(0.7),
          blurRadius: 2,
          offset: const Offset(0, 2), // Shadow position
        ),
      ],
    ),
    child: Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        AutoSizeText(
          average != null ? average.toStringAsFixed(2) : "No Data",
          maxLines: 1,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
        ),
      ],
    ),
  );
}

enum Units {
  mmolPerLiter,
  milligramsPerDeciliter,
}
