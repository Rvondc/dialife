import 'package:carousel_slider/carousel_slider.dart';
import 'package:dialife/blood_glucose_tracking/conversions.dart';
import 'package:dialife/blood_glucose_tracking/entities.dart';
import 'package:dialife/blood_glucose_tracking/summary.dart';
import 'package:dialife/blood_glucose_tracking/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

Future<Database> initDatabase(String path) async {
  return openDatabase(
    join(path, "bgt.db"),
    onCreate: (db, version) async {
      await db.execute("""
        CREATE TABLE Facility (
          id INTEGER NOT NULL PRIMARY KEY,
          name VARCHAR(255) NOT NULL,
          long DECIMAL(7, 4),
          lat DECIMAL(7, 4),
          description VARCHAR(255) NOT NULL
        )
      """);

      await db.execute(
          "INSERT INTO Facility (name, long, lat, description) VALUES (\"Emmanuel\", 23.112, 138.2211, \"Emmanuel Description\"), (\"Medicus\", 69.162, 22.5413, \"Medicus Description\"), (\"Centrum\", 213.12, 228.1, \"Centrum Description\")");

      await db.execute("""
        CREATE TABLE GlucoseRecord (
          id INTEGER NOT NULL PRIMARY KEY,
          facility_id INTEGER NOT NULL,
          glucose_level DECIMAL(5, 2) NOT NULL,
          blood_test_date DATETIME,
          FOREIGN KEY (facility_id) REFERENCES Facility (id)
        )
       """);
    },
    version: 1,
  );
}

class BloodGlucoseTracking extends StatelessWidget {
  const BloodGlucoseTracking({super.key});

  @override
  Widget build(BuildContext context) {
    const loadingComponent = Scaffold(
      body: Text("Loading..."),
    );

    return waitForFuture(
      // NOTE: First we get the path
      future: getTemporaryDirectory(),
      loading: loadingComponent,
      builder: (context, pathData) {
        return waitForFuture(
          // NOTE: Here we initialize the database
          future: initDatabase(pathData.path),
          loading: loadingComponent,
          builder: (context, data) => Scaffold(
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // NOTE: We give the initialized database to record the facilities and glucose records
                    GlucoseRecordingForm(
                      db: data,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class GlucoseRecordingForm extends StatefulWidget {
  final Database db;
  const GlucoseRecordingForm({
    super.key,
    required this.db,
  });

  @override
  State<GlucoseRecordingForm> createState() => _GlucoseRecordingFormState();
}

enum Units {
  mmolPerLiter,
  milligramsPerDeciliter,
}

class _GlucoseRecordingFormState extends State<GlucoseRecordingForm> {
  final _glucoseReadingController = TextEditingController();
  final ValueNotifier<DateTime?> _readingDateTime = ValueNotifier(null);
  final ValueNotifier<Units> _currentUnit = ValueNotifier(Units.mmolPerLiter);
  final ValueNotifier<Facility?> _currentFacility = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Feature No. 1",
          style: TextStyle(fontSize: 24),
        ),
        const Text(
          "Test UI for DiaLife",
          style: TextStyle(fontSize: 24),
        ),
        waitForFuture(
          future: widget.db.query("GlucoseRecord"),
          loading: const SpinKitFadingFour(
            color: Colors.blueGrey,
          ),
          builder: (context, data) {
            final parsedData =
                data.map((map) => GlucoseRecord.fromMap(map)).toList();

            parsedData
                .sort((a, b) => a.bloodTestDate.compareTo(b.bloodTestDate));

            return Column(
              children: [
                SfCartesianChart(
                  zoomPanBehavior: ZoomPanBehavior(
                    enablePanning: true,
                    enablePinching: true,
                  ),
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    builder: (data, point, series, pointIndex, seriesIndex) {
                      final GlucoseRecord record = data;
                      final DateFormat formatter = DateFormat('HH:mm, M/d/y');

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.greenAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        width: 100,
                        child: Text(
                          formatter.format(record.bloodTestDate),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                  trackballBehavior: TrackballBehavior(enable: true),
                  title: ChartTitle(text: "Glucose Levels (mmol/L)"),
                  legend: const Legend(isVisible: true),
                  primaryXAxis: DateTimeAxis(),
                  series: <ChartSeries<GlucoseRecord, DateTime>>[
                    LineSeries<GlucoseRecord, DateTime>(
                        dataSource: parsedData,
                        xValueMapper: (datum, index) => datum.bloodTestDate,
                        yValueMapper: (datum, index) => datum.glucoseLevel,
                        name: "Glucose",
                        isVisibleInLegend: false,
                        markerSettings: const MarkerSettings(isVisible: true))
                  ],
                ),
                RecordSummary(
                  data: parsedData,
                )
              ],
            );
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ValueListenableBuilder(
              valueListenable: _currentUnit,
              builder: (context, value, child) {
                // NOTE: The source of truth should be a number (ideally a decima) not a string
                if (_glucoseReadingController.text.isNotEmpty) {
                  _glucoseReadingController.text = value == Units.mmolPerLiter
                      ? mgDLToMmolL(
                              double.parse(_glucoseReadingController.text))
                          .toStringAsFixed(2)
                      : mmolLToMgDL(
                              double.parse(_glucoseReadingController.text))
                          .toStringAsFixed(2);
                }

                return Container(
                    width: 150,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: TextField(
                      controller: _glucoseReadingController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        hintText: "Glucose level",
                      ),
                    ));
              },
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.greenAccent),
                minimumSize: MaterialStateProperty.all(const Size(100.0, 0.0)),
              ),
              onPressed: () {
                _currentUnit.value = _currentUnit.value == Units.mmolPerLiter
                    ? Units.milligramsPerDeciliter
                    : Units.mmolPerLiter;
              },
              child: ValueListenableBuilder(
                valueListenable: _currentUnit,
                builder: (context, value, child) {
                  return Text(_currentUnit.value == Units.mmolPerLiter
                      ? "mmol/L"
                      : "mg/dL");
                },
              ),
            )
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ValueListenableBuilder(
                  valueListenable: _readingDateTime,
                  builder: (context, value, child) {
                    if (value == null) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text("No Date Entered"),
                      );
                    }

                    return Container(
                      width: 250,
                      padding: const EdgeInsets.all(24),
                      child: Text("Date Entered: ${value.toString()}"),
                    );
                  },
                ),
                IconButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.greenAccent),
                    minimumSize: MaterialStateProperty.all(const Size(100, 0)),
                  ),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _readingDateTime.value ?? DateTime.now(),
                      firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                      lastDate: DateTime.now(),
                    );

                    if (date == null) {
                      return;
                    }

                    if (!mounted) {
                      return;
                    }

                    final time = await showTimePicker(
                      context: context,
                      initialTime: _readingDateTime.value == null
                          ? TimeOfDay.now()
                          : TimeOfDay.fromDateTime(_readingDateTime.value!),
                    );

                    if (time == null) {
                      return;
                    }

                    final dateTime = date.copyWith(
                      hour: time.hour,
                      minute: time.minute,
                    );

                    _readingDateTime.value = dateTime;
                  },
                  icon: const Icon(Icons.calendar_month_outlined),
                ),
              ],
            ),
          ],
        ),
        TextButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.greenAccent)),
          onPressed: () async {
            if (_readingDateTime.value == null) {
              return;
            }

            if (_glucoseReadingController.value.text.isEmpty) {
              return;
            }

            final height = MediaQuery.of(context).size.height * 0.6;
            final width = MediaQuery.of(context).size.width * 0.8;

            // NOTE: Displays the dialog when submitting a new glucose reading record
            await showDialog(
              context: context,
              builder: (context) {
                return waitForFuture(
                  loading: Container(),
                  future: widget.db.query("Facility"),
                  builder: (context, data) {
                    // NOTE: Consider moving this to the initlization level
                    final parsedData = data
                        .cast<Map<String, dynamic>>()
                        .map((e) => Facility.fromMap(e));

                    return AlertDialog(
                      contentPadding: const EdgeInsets.all(12),
                      content: SizedBox(
                        height: height,
                        child: Column(
                          children: [
                            const Text("Choose Facility"),
                            const SizedBox(height: 10),
                            CarouselSlider(
                              items: parsedData
                                  .map(
                                    (facility) => InkWell(
                                      // NOTE: This is where the record gets committed to the database
                                      onTap: () async {
                                        _currentFacility.value = facility;
                                        final mmolPerLiter = _currentUnit
                                                    .value ==
                                                Units.mmolPerLiter
                                            ? _glucoseReadingController.text
                                            : mgDLToMmolL(double.parse(
                                                    _glucoseReadingController
                                                        .text))
                                                .toString();
                                        await widget.db.rawInsert(
                                            "INSERT INTO GlucoseRecord (facility_id, glucose_level, blood_test_date) VALUES (${facility.id}, $mmolPerLiter, \"${_readingDateTime.value}\")");

                                        if (!mounted) {
                                          return;
                                        }

                                        Navigator.of(context).pop();
                                        setState(() {
                                          _glucoseReadingController.text = "";
                                        });
                                      },
                                      child: Ink(
                                        width: width,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.greenAccent,
                                        ),
                                        child: Text(
                                          facility.name,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              options: CarouselOptions(
                                enlargeCenterPage: true,
                                viewportFraction: 0.7,
                                height: height * 0.2,
                                aspectRatio: width / height,
                              ),
                            ),
                            const SizedBox(height: 30),
                            const Text("Register Facility"),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
          child: const Text("Add glucose record"),
        ),
      ],
    );
  }
}
