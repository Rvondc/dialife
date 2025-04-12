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

const fgColor = Color(0xFF3878A6);
const fgColor2 = Color(0xFFDD4848);
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
              await FilePicker.platform.clearTemporaryFiles();
              final directory = await FilePicker.platform.getDirectoryPath();
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
        // Time Range Selector
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Builder(
              builder: (context) {
                int index = 0;
                switch (_scopeString) {
                  case "allTime":
                    index = 3;
                    break;
                  case "month":
                    index = 2;
                    break;
                  case "week":
                    index = 1;
                    break;
                  case "day":
                    index = 0;
                    break;
                }

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ToggleSwitch(
                    inactiveBgColor: bgColorToggleSwitch,
                    activeBgColor: const [Colors.white],
                    activeFgColor: Colors.black,
                    inactiveFgColor: Colors.grey.shade700,
                    cornerRadius: 10,
                    radiusStyle: true,
                    centerText: true,
                    activeBorders: [
                      Border.all(
                        width: 3,
                        color: fgColor.withOpacity(0.7),
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

        const SizedBox(height: 24),

        // Current Glucose Display
        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 6,
                    spreadRadius: 1,
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 3),
                  ),
                  BoxShadow(
                    blurRadius: 4,
                    color: fgColor.withOpacity(0.3),
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              width: constraints.maxWidth * 0.85,
              child: Builder(
                builder: (context) {
                  double glucoseLevel = _unit == Units.milligramsPerDeciliter
                      ? mmolLToMgDL(widget.glucoseRecords.last.glucoseLevel)
                      : widget.glucoseRecords.last.glucoseLevel;

                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Current Glucose",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              fontSize: 18,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                _unit == Units.mmolPerLiter
                                    ? "mmol/L"
                                    : "mg/dL",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              FlutterSwitch(
                                value: _unit == Units.mmolPerLiter,
                                height: 22,
                                width: 45,
                                padding: 2,
                                duration: const Duration(milliseconds: 100),
                                activeColor: const Color(0xFFF0E5FF),
                                activeToggleColor: const Color(0xFF841896),
                                inactiveColor: Colors.grey.shade200,
                                inactiveToggleColor: Colors.grey.shade700,
                                borderRadius: 12,
                                onToggle: (value) {
                                  setState(() {
                                    _unit = value
                                        ? Units.mmolPerLiter
                                        : Units.milligramsPerDeciliter;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            glucoseLevel.toStringAsFixed(1),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 46,
                              color: fgColor,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _unit == Units.mmolPerLiter ? "mmol/L" : "mg/dL",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        DateFormat("MMM d, yyyy 'at' h:mm a")
                            .format(widget.glucoseRecords.last.bloodTestDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        // Glucose Chart
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 6,
                spreadRadius: 1,
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                blurRadius: 4,
                color: fgColor.withOpacity(0.3),
                offset: const Offset(0, 2),
              )
            ],
          ),
          padding: const EdgeInsets.fromLTRB(8, 16, 12, 12),
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12.0, bottom: 8.0),
                child: Text(
                  "Glucose Trends",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12.0, bottom: 8.0),
                child: Row(
                  children: [
                    _legendItem("Normal", const Color(0xFF67E88B)),
                    const SizedBox(width: 16),
                    _legendItem("Pre-Diabetes", const Color(0xFFCBCF10)),
                    const SizedBox(width: 16),
                    _legendItem("Diabetes", const Color(0xFFB84141)),
                  ],
                ),
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
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

                    switch (_scopeString) {
                      case "allTime":
                        interval = 7;
                      case "month":
                        interval = 7;
                      case "week":
                        interval = 1;
                      case "day":
                        interval = 0.3;
                    }

                    final normalGlucoseRecMap = widget.glucoseRecords
                        .where((data) => !data.isA1C)
                        .toList()
                        .asMap()
                        .entries
                        .toList();

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
                      margin: const EdgeInsets.only(right: 8),
                      crosshairBehavior: CrosshairBehavior(
                        enable: true,
                        lineColor: fgColor.withOpacity(0.5),
                        lineWidth: 1,
                      ),
                      tooltipBehavior: TooltipBehavior(
                        animationDuration: 200,
                        duration: 2500,
                        enable: true,
                        builder:
                            (data, point, series, pointIndex, seriesIndex) {
                          var typedData = data as GlucoseRecord;
                          bool isA1C = typedData.isA1C;
                          Color tooltipColor = isA1C
                              ? const Color.fromARGB(255, 153, 104, 230)
                              : const Color(0xFF67E88B);
                          Color borderColor =
                              isA1C ? a1cPurple : const Color(0xFF016629);

                          return Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: tooltipColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                width: 1,
                                color: borderColor,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  offset: const Offset(0, 4),
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: borderColor,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isA1C ? "A1C TEST" : "GLUCOSE",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  DateFormat("MMMM d")
                                      .format(typedData.bloodTestDate),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  DateFormat("h:mm a")
                                      .format(typedData.bloodTestDate),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Value: ${_unit == Units.milligramsPerDeciliter ? mmolLToMgDL(typedData.glucoseLevel).toStringAsFixed(1) : typedData.glucoseLevel.toStringAsFixed(1)} ${_unit == Units.milligramsPerDeciliter ? 'mg/dL' : 'mmol/L'}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (typedData.notes.isNotEmpty)
                                  SizedBox(
                                    width: 95,
                                    child: Text(
                                      typedData.notes,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 10,
                                      ),
                                    ),
                                  )
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
                        majorGridLines: MajorGridLines(
                          color: Colors.grey.shade300,
                          width: 0.5,
                        ),
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
                            opacity: 0.3,
                          ),
                          PlotBand(
                            start: _unit == Units.milligramsPerDeciliter
                                ? 100
                                : mgDLToMmolL(100),
                            end: _unit == Units.milligramsPerDeciliter
                                ? 125
                                : mgDLToMmolL(125),
                            color: const Color(0xFFCBCF10),
                            opacity: 0.3,
                          ),
                          PlotBand(
                            start: _unit == Units.milligramsPerDeciliter
                                ? 125
                                : mgDLToMmolL(125),
                            color: const Color(0xFFB84141),
                            opacity: 0.3,
                          ),
                        ],
                        majorGridLines: MajorGridLines(
                          color: Colors.grey.shade300,
                          width: 0.5,
                        ),
                      ),
                      series: <CartesianSeries<GlucoseRecord, DateTime>>[
                        LineSeries(
                          dataSource: glucoseDataPoints,
                          xValueMapper: (datum, index) => datum.bloodTestDate,
                          yValueMapper: (datum, index) =>
                              _unit == Units.milligramsPerDeciliter
                                  ? mmolLToMgDL(datum.glucoseLevel)
                                  : datum.glucoseLevel,
                          markerSettings: MarkerSettings(
                            isVisible: true,
                            width: 8,
                            height: 8,
                            borderWidth: 1,
                            borderColor: fgColor,
                            color: fgColor.withOpacity(0.8),
                          ),
                          color: fgColor,
                          width: 2,
                          isVisibleInLegend: false,
                        ),
                        LineSeries(
                          dataSource: a1cDataPoints,
                          dataLabelMapper: (datum, index) => "A1C",
                          dataLabelSettings: DataLabelSettings(
                            isVisible: true,
                            labelAlignment: ChartDataLabelAlignment.top,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: a1cPurple,
                              fontSize: 12,
                            ),
                          ),
                          xValueMapper: (datum, index) => datum.bloodTestDate,
                          yValueMapper: (datum, index) =>
                              _unit == Units.milligramsPerDeciliter
                                  ? mmolLToMgDL(datum.glucoseLevel)
                                  : datum.glucoseLevel,
                          isVisibleInLegend: false,
                          markerSettings: const MarkerSettings(
                            isVisible: true,
                            width: 10,
                            height: 10,
                            shape: DataMarkerType.diamond,
                            borderColor: a1cPurple,
                            color: a1cPurple,
                          ),
                          color: a1cPurple.withOpacity(0.5),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Average Section
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                blurRadius: 6,
                spreadRadius: 1,
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
                child: Text(
                  "Average Glucose",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
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
                    dayAverage =
                        dayAverage == null ? null : mmolLToMgDL(dayAverage);
                    weekAverage =
                        weekAverage == null ? null : mmolLToMgDL(weekAverage);
                    monthAverage =
                        monthAverage == null ? null : mmolLToMgDL(monthAverage);
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _averageCard("Daily", dayAverage),
                      _averageCard("Weekly", weekAverage),
                      _averageCard("Monthly", monthAverage),
                    ],
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0, left: 8.0),
                child: Text(
                  "Unit: ${_unit == Units.milligramsPerDeciliter ? "mg/dL" : "mmol/L"}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Recent Records Section
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                blurRadius: 6,
                spreadRadius: 1,
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
                child: Text(
                  "Recent Records",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
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
                      margin: const EdgeInsets.only(bottom: 10),
                      child: _recordCard(
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
            ],
          ),
        ),

        const SizedBox(height: 24),

        // View Report Button
        ElevatedButton.icon(
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
          icon: const Icon(Icons.history_rounded),
          label: const Text("VIEW COMPLETE HISTORY"),
          style: ElevatedButton.styleFrom(
            backgroundColor: fgColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 3,
            shadowColor: fgColor.withOpacity(0.5),
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  // Helper methods for UI components
  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _averageCard(String period, double? average) {
    return Container(
      width: 100,
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: fgColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fgColor.withOpacity(0.2), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            period,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            average != null ? average.toStringAsFixed(1) : "No Data",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: average != null ? 24 : 16,
              color: fgColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _recordCard(DateTime date, String notes, double glucoseLevel,
      Units unit, bool isA1C) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color:
                isA1C ? a1cPurple.withOpacity(0.3) : fgColor.withOpacity(0.1),
            width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 3,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  isA1C ? a1cPurple.withOpacity(0.1) : fgColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isA1C ? Icons.science_rounded : Icons.water_drop_rounded,
              color: isA1C ? a1cPurple : fgColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isA1C ? "A1C Test" : "Glucose Reading",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isA1C ? a1cPurple : Colors.black87,
                  ),
                ),
                Text(
                  DateFormat("MMM dd, yyyy • h:mm a").format(date),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (notes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      notes,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                glucoseLevel.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isA1C ? a1cPurple : fgColor,
                ),
              ),
              Text(
                unit == Units.milligramsPerDeciliter ? "mg/dL" : "mmol/L",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
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
