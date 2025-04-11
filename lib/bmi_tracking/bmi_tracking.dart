import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:dialife/blood_glucose_tracking/utils.dart';
import 'package:dialife/bmi_tracking/calculate_average.dart';
import 'package:dialife/bmi_tracking/entities.dart';
import 'package:dialife/bmi_tracking/no_data.dart';
import 'package:dialife/main.dart';
import 'package:dialife/user.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:toggle_switch/toggle_switch.dart';

class BMITracking extends StatefulWidget {
  final User user;
  final Database db;

  const BMITracking({
    super.key,
    required this.db,
    required this.user,
  });

  @override
  State<BMITracking> createState() => _BMITrackingState();
}

class _BMITrackingState extends State<BMITracking> {
  @override
  Widget build(BuildContext context) {
    const loading = Scaffold(
      body: SpinKitCircle(color: fgColor),
    );

    reset() {
      setState(() {});
    }

    return waitForFuture(
      future: getDatabasesPath(),
      loading: loading,
      builder: (context, data) {
        return waitForFuture(
          loading: loading,
          future: initAppDatabase(data),
          builder: (context, data) {
            return waitForFuture(
              loading: loading,
              future: data.query("BMIRecord"),
              builder: (context, data) {
                final parsedData = BMIRecord.fromListOfMaps(data);
                // final parsedData = BMIRecord.mock(0, 3);
                parsedData.sort((a, b) => a.createdAt.compareTo(b.createdAt));

                return _BMITrackingInteralScaffold(
                  reset: reset,
                  user: widget.user,
                  db: widget.db,
                  records: parsedData,
                );
              },
            );
          },
        );
      },
    );
  }
}

class _BMITrackingInteralScaffold extends StatelessWidget {
  final List<BMIRecord> records;
  final Database db;
  final User user;
  final void Function() reset;

  const _BMITrackingInteralScaffold({
    required this.reset,
    required this.db,
    required this.user,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(title: const Text("BMI")),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: BMITrackingNoData(
              db: db,
              user: user,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text("BMI"),
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
              final file = File(join(path.path, "bmi_tracking.dialife.csv"));

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
            "/bmi-tracking/input",
            arguments: {
              "db": db,
              "user": user,
            },
          );

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
              child: _BMITrackingInternal(
                records: records,
                db: db,
                reset: reset,
                user: user,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BMITrackingInternal extends StatefulWidget {
  final List<BMIRecord> records;
  final Database db;
  final User user;
  final void Function() reset;

  const _BMITrackingInternal({
    required this.db,
    required this.reset,
    required this.user,
    required this.records,
  });

  @override
  State<_BMITrackingInternal> createState() => __BMITrackingInternalState();
}

class __BMITrackingInternalState extends State<_BMITrackingInternal> {
  DateScope _scope = DateScope.day(DateTime.now());
  String _scopeString = "day";

  @override
  Widget build(BuildContext context) {
    // NOTE: Takes, at most, the last 3 records
    var lastRecords = widget.records.reversed.take(3);

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

        // Current BMI Display
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
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Current BMI",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          fontSize: 18,
                        ),
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
                        widget.records.last.bmi.toStringAsFixed(1),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 46,
                          color: fgColor,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    DateFormat("MMM d, yyyy 'at' h:mm a")
                        .format(widget.records.last.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        // BMI Chart
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
                  "BMI Trends",
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
                    _legendItem("Underweight",
                        const Color.fromARGB(255, 232, 183, 103)),
                    const SizedBox(width: 16),
                    _legendItem("Normal", const Color(0xFF67E88B)),
                    const SizedBox(width: 16),
                    _legendItem("Overweight", const Color(0xFFCBCF10)),
                    const SizedBox(width: 16),
                    _legendItem("Obese", const Color(0xFFB84141)),
                  ],
                ),
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    // NOTE: This convoluted step is required in order to get the last element that is not in the dataPoints list
                    final dataPointsMap = widget.records
                        .asMap()
                        .entries
                        .where(
                          (data) =>
                              _scope.start.isBefore(data.value.createdAt) &&
                              _scope.end.isAfter(data.value.createdAt),
                        )
                        .toList();

                    var dataPoints =
                        dataPointsMap.map((data) => data.value).toList();
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

                    if (dataPointsMap.isNotEmpty &&
                        dataPointsMap.first.key - 1 >= 0) {
                      dataPoints.insert(
                          0, widget.records[dataPointsMap.first.key - 1]);
                    }

                    return SfCartesianChart(
                      backgroundColor: Colors.white,
                      zoomPanBehavior: ZoomPanBehavior(
                        enablePinching: true,
                        enablePanning: true,
                        enableDoubleTapZooming: true,
                      ),
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
                          var typedData = data as BMIRecord;
                          Color tooltipColor = const Color(0xFF67E88B);
                          Color borderColor = const Color(0xFF016629);

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
                                    const Text(
                                      "BMI RECORD",
                                      style: TextStyle(
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
                                      .format(typedData.createdAt),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  DateFormat("h:mm a")
                                      .format(typedData.createdAt),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "BMI: ${typedData.bmi.toStringAsFixed(1)}",
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
                            ? dataPoints.first.createdAt.copyWith(hour: -12)
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
                        maximum: lastRecords.length > 1 ? null : 40,
                        plotBands: [
                          PlotBand(
                            start: 29,
                            color: const Color(0xFFB84141),
                            opacity: 0.3,
                          ),
                          PlotBand(
                            start: 24,
                            end: 29,
                            color: const Color(0xFFCBCF10),
                            opacity: 0.3,
                          ),
                          PlotBand(
                            start: 19,
                            end: 24,
                            color: const Color(0xFF67E88B),
                            opacity: 0.3,
                          ),
                          PlotBand(
                            start: 0,
                            end: 19,
                            color: const Color.fromARGB(255, 232, 183, 103),
                            opacity: 0.3,
                          )
                        ],
                        majorGridLines: MajorGridLines(
                          color: Colors.grey.shade300,
                          width: 0.5,
                        ),
                      ),
                      series: <ChartSeries<BMIRecord, DateTime>>[
                        LineSeries(
                          dataSource: dataPoints,
                          xValueMapper: (datum, index) => datum.createdAt,
                          yValueMapper: (datum, index) => datum.bmi,
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
                  "Average BMI",
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

                  double? dayAverage = calcAverageBMIRecord(
                      dayScope.start, dayScope.end, widget.records);
                  double? weekAverage = calcAverageBMIRecord(
                      weekScope.start, weekScope.end, widget.records);
                  double? monthAverage = calcAverageBMIRecord(
                      monthScope.start, monthScope.end, widget.records);

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
                  return GestureDetector(
                    onTap: () async {
                      await Navigator.of(context).pushNamed(
                        "/bmi-tracking/input",
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
                        record.createdAt,
                        record.notes,
                        record.bmi,
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
              "/bmi-tracking/editor",
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

  Widget _recordCard(DateTime date, String notes, double bmi) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: fgColor.withOpacity(0.1), width: 1),
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
              color: fgColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.monitor_weight_rounded,
              color: fgColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "BMI Reading",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
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
                bmi.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: fgColor,
                ),
              ),
              Builder(builder: (context) {
                String category;
                Color categoryColor;

                if (bmi >= 19 && bmi <= 24) {
                  categoryColor = const Color(0xFF67E88B);
                  category = "Normal";
                } else if (bmi > 24 && bmi <= 29) {
                  categoryColor = const Color(0xFFCBCF10);
                  category = "Overweight";
                } else if (bmi > 29) {
                  categoryColor = const Color(0xFFB84141);
                  category = "Obese";
                } else {
                  categoryColor = const Color.fromARGB(255, 232, 183, 103);
                  category = "Underweight";
                }

                return Text(
                  category,
                  style: TextStyle(
                    fontSize: 12,
                    color: categoryColor,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}

Widget bmiRecordListTile(DateTime date, String notes, double bmi) {
  return Material(
    elevation: 4,
    shadowColor: fgColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ListTile(
      leading: const Icon(
        Icons.receipt,
        color: fgColor,
      ),
      title: AutoSizeText(
        "Date: ${DateFormat("MMM. dd, yyyy hh:mm a").format(date)}",
        maxLines: 1,
        maxFontSize: 14,
        minFontSize: 10,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Row(
        children: [
          Builder(builder: (context) {
            Color color;
            String category;

            // TODO: Might contain bug
            if (bmi >= 19 && bmi <= 24) {
              color = const Color(0xFF67E88B);
              category = "Normal";
            } else if (bmi > 24 && bmi <= 29) {
              color = const Color(0xFFCBCF10);
              category = "Overweight";
            } else if (bmi > 29) {
              color = const Color(0xFFB84141);
              category = "Obese";
            } else {
              color = const Color.fromARGB(255, 232, 183, 103);
              category = "Underweight";
            }

            return Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  category,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          })
        ],
      ),
      trailing: AutoSizeText(
        bmi.toStringAsFixed(2),
        minFontSize: 28,
        style: const TextStyle(fontWeight: FontWeight.bold),
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

// Future<Database> initBMIRecordDatabase(String path) async {
//   return openDatabase(
//     join(path, "bmi-tracking.db"),
//     onCreate: (db, version) async {
//       await db.execute("""
//         CREATE TABLE BMIRecord (
//           id INTEGER PRIMARY KEY NOT NULL,
//           height DECIMAL(3, 2) NOT NULL,
//           notes VARCHAR(255) NOT NULL,
//           weight DECIMAL(5, 2) NOT NULL,
//           created_at DATETIME NOT NULL
//         ) 
//       """);

//       return db.execute(
//           "INSERT INTO BMIRecord (height, weight, created_at, notes) VALUES (1.73, 77.08, '2023-10-13', 'After lunch'), (1.73, 77.5, '2023-10-12', 'Before bed'), (1.73, 78.2, '2023-10-11', 'Deserunt deserunt eu duis sit minim deserunt et aute et ea dolore.')");
//     },
//     version: 1,
//   );
// }
