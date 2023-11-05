import 'package:auto_size_text/auto_size_text.dart';
import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:dialife/blood_glucose_tracking/utils.dart';
import 'package:dialife/bmi_tracking/calculate_average.dart';
import 'package:dialife/bmi_tracking/entities.dart';
import 'package:dialife/bmi_tracking/no_data.dart';
import 'package:dialife/main.dart';
import 'package:dialife/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:toggle_switch/toggle_switch.dart';

class BMITracking extends StatefulWidget {
  final User user;

  const BMITracking({
    super.key,
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
  final User user;
  final void Function() reset;

  const _BMITrackingInteralScaffold({
    super.key,
    required this.reset,
    required this.user,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(title: const Text("BMI")),
        body: const SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: BMITrackingNoData(),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(title: const Text("BMI")),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: fgColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.of(context).pushNamed("/bmi-tracking/input");
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
  final User user;
  final void Function() reset;

  const _BMITrackingInternal({
    super.key,
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
    final lastRecords = widget.records.reversed.take(3);

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
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            "Your Current BMI",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            return AutoSizeText(
              widget.records.last.bmi.toStringAsFixed(2),
              maxLines: 1,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 48,
              ),
            );
          },
        ),
        const SizedBox(height: 12),
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
          height: 260,
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

              var dataPoints = dataPointsMap.map((data) => data.value).toList();
              double interval = 1;

              // NOTE: This is for optimization purposes
              // TODO: Implement in settings
              switch (_scopeString) {
                case "allTime":
                  interval = 7;
                // dataPoints = sparsifyBMIRecords(dataPoints, 1);
                case "month":
                  interval = 7;
                // dataPoints = sparsify(dataPoints, 4);
                case "week":
                  interval = 1;
                // dataPoints = sparsify(dataPoints, 10);
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
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  builder: (data, point, series, pointIndex, seriesIndex) {
                    return const Card(
                      shape: BeveledRectangleBorder(),
                      shadowColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      child: Text("Heelo"),
                    );
                  },
                ),
                primaryXAxis: DateTimeAxis(
                  axisLine: const AxisLine(color: fgColor, width: 2),
                  maximum: _scope.end,
                  minimum: _scopeString == "allTime"
                      ? dataPoints.first.createdAt.copyWith(hour: -12)
                      : _scope.start,
                  majorGridLines: const MajorGridLines(color: fgColor),
                  intervalType: DateTimeIntervalType.days,
                  interval: interval,
                  dateFormat: DateFormat.Md(),
                ),
                primaryYAxis: NumericAxis(
                  axisLine: const AxisLine(color: fgColor, width: 2),
                  majorGridLines: const MajorGridLines(color: fgColor),
                ),
                trackballBehavior: TrackballBehavior(enable: true),
                legend: const Legend(isVisible: true),
                series: <ChartSeries<BMIRecord, DateTime>>[
                  LineSeries(
                    dataSource: dataPoints,
                    xValueMapper: (datum, index) => datum.createdAt,
                    yValueMapper: (datum, index) =>
                        datum.weightInKilograms /
                        (datum.heightInMeters * datum.heightInMeters),
                    markerSettings: const MarkerSettings(
                        isVisible: true,
                        width: 5,
                        height: 5,
                        borderWidth: 1,
                        borderColor: fgColor,
                        color: fgColor),
                    color: Colors.black,
                    width: 1,
                    isVisibleInLegend: false,
                  )
                ],
              );
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.all(12),
          child: Text(
            "AVERAGE",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700),
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
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: GestureDetector(
                onTap: () {},
                child: bmiRecordListTile(
                  record.createdAt,
                  record.notes,
                  record.bmi,
                ),
              ),
            );
          },
        ),
        Container(
          margin: const EdgeInsets.all(12),
          child: TextButton(
            onPressed: () async {
              final changed = await Navigator.of(context)
                  .pushNamed("/bmi-tracking/editor") as bool;

              if (changed) {
                widget.reset();
              }
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(fgColor),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
            ),
            child: const Text(
              "VIEW REPORT HISTORY",
              style: TextStyle(color: Colors.white),
            ),
          ),
        )
      ],
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
      subtitle: AutoSizeText(
        "Notes: $notes",
        maxLines: 3,
        overflow: TextOverflow.fade,
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
