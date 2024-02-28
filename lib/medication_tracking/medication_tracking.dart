import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:dialife/main.dart';
import 'package:dialife/medication_tracking/entities.dart';
import 'package:dialife/medication_tracking/utils.dart';
import 'package:dialife/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:sqflite/sqflite.dart';

class MedicationTracking extends StatefulWidget {
  final User user;
  final Database db;

  const MedicationTracking({
    super.key,
    required this.user,
    required this.db,
  });

  @override
  State<MedicationTracking> createState() => _MedicationTrackingState();
}

class _MedicationTrackingState extends State<MedicationTracking> {
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
              future: data.query("MedicationRecordDetails"),
              builder: (context, data) {
                final parsedData = MedicationRecordDetails.fromListOfMaps(data);

                return _MedicationTrackingInteralScaffold(
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

class _MedicationTrackingInteralScaffold extends StatelessWidget {
  final List<MedicationRecordDetails> records;
  final Database db;
  final User user;
  final void Function() reset;

  const _MedicationTrackingInteralScaffold({
    super.key,
    required this.records,
    required this.db,
    required this.user,
    required this.reset,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Medication Tracking")),
      backgroundColor: Colors.grey.shade200,
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).pushNamed(
            "/medication-tracking/input",
            arguments: {
              "db": db,
              "user": user,
            },
          );

          reset();
        },
        label: Text(
          "Create Reminder",
          style: GoogleFonts.istokWeb(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: const Color(0xFF6078F8),
        elevation: 4,
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
                bottom: 75,
              ),
              child: _MedicationTrackingInternal(
                records: records,
                db: db,
                user: user,
                reset: reset,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MedicationTrackingInternal extends StatefulWidget {
  final List<MedicationRecordDetails> records;
  final Database db;
  final User user;
  final void Function() reset;

  const _MedicationTrackingInternal({
    super.key,
    required this.records,
    required this.db,
    required this.user,
    required this.reset,
  });

  @override
  State<_MedicationTrackingInternal> createState() =>
      __MedicationTrackingInternalState();
}

class __MedicationTrackingInternalState
    extends State<_MedicationTrackingInternal> {
  DateTime _selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  Widget build(BuildContext context) {
    final groupedRecords = groupBy(widget.records,
            (record) => record.toMap()["medication_reminder_record_id"])
        .entries
        .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    "MEDICATION REMINDER",
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    "assets/pills_logo.png",
                    width: 200,
                  ),
                  const SizedBox(height: 20),
                  Divider(
                    color: Colors.grey.shade200,
                    thickness: 3,
                  ),
                  EasyDateTimeLine(
                    initialDate: DateTime.now(),
                    onDateChange: (selectedDate) {
                      setState(() {
                        _selectedDate = selectedDate;
                      });
                    },
                    activeColor: const Color(0xFF326BFD),
                    headerProps: EasyHeaderProps(
                      selectedDateStyle: TextStyle(
                        fontFamily: GoogleFonts.istokWeb().fontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      dateFormatter: const DateFormatter.custom("MMMM, y"),
                    ),
                    dayProps: EasyDayProps(
                      height: 56.0,
                      width: 56.0,
                      dayStructure: DayStructure.dayStrDayNum,
                      inactiveDayStyle: DayStyle(
                        borderRadius: 48.0,
                        dayNumStyle: TextStyle(
                          fontSize: 18.0,
                          fontFamily: GoogleFonts.istokWeb().fontFamily,
                        ),
                        dayStrStyle: TextStyle(
                          fontFamily: GoogleFonts.istokWeb().fontFamily,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      activeDayStyle: DayStyle(
                        borderRadius: 48.0,
                        dayNumStyle: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: GoogleFonts.istokWeb().fontFamily,
                        ),
                        dayStrStyle: TextStyle(
                          fontFamily: GoogleFonts.istokWeb().fontFamily,
                          color: Colors.white,
                        ),
                      ),
                      todayStyle: DayStyle(
                        borderRadius: 48.0,
                        dayNumStyle: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.istokWeb().fontFamily,
                        ),
                        dayStrStyle: TextStyle(
                          fontFamily: GoogleFonts.istokWeb().fontFamily,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ),
          ...groupedRecords.map((record) {
            MedicationRecordDetails firstRecord = record.value.first;

            return GestureDetector(
              onTap: () {},
              child: medicationReminderListTile(
                firstRecord.medicineName,
                _selectedDate,
                record.value,
              ),
            );
          }),
        ],
      ),
    );
  }
}

Widget medicationReminderListTile(
  String name,
  DateTime pickedDate,
  List<MedicationRecordDetails> values,
) {
  MedicationRecordDetails firstRecord = values.first;
  List<DateTime> dateTimes = [];
  List<TimeOfDay> selectedTimes = [];

  for (var value in values) {
    DateTime date = value.medicationDatetime;
    dateTimes.add(date);

    TimeOfDay time = TimeOfDay(
      hour: value.medicationDatetime.hour,
      minute: value.medicationDatetime.minute,
    );
    selectedTimes.add(time);
  }

  List<TimeOfDay> unqiueTimes = selectedTimes.toSet().toList();

  if (isSelectedDateInList(pickedDate, dateTimes)) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Material(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: const Icon(
              Symbols.pill,
              color: Color(0xFF326BFD),
            ),
            title: AutoSizeText(
              name,
              maxLines: 1,
              maxFontSize: 24,
              minFontSize: 18,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: -5,
                  children: [
                    Text(
                        "Dosage: ${firstRecord.medicineDosage.toStringAsFixed(2)} mg,"),
                    Text("Form: ${firstRecord.medicineForm},"),
                    Text("Route: ${firstRecord.medicineRoute}"),
                  ],
                ),
                const Divider(thickness: 1),
                Wrap(
                  spacing: 5,
                  runSpacing: -5,
                  children: [
                    ...unqiueTimes.map(
                      (value) {
                        DateTime now = DateTime.now();
                        return Chip(
                          label: Text(
                            DateFormat("HH:mm a").format(
                              DateTime(
                                now.year,
                                now.month,
                                now.day,
                                value.hour,
                                value.minute,
                              ),
                            ),
                          ),
                          labelStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          backgroundColor: const Color(0xFF326BFD),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  return Container();
}

bool isSelectedDateInList(DateTime selectedDate, List<DateTime> dateList) {
  for (var date in dateList) {
    if (date.year == selectedDate.year &&
        date.month == selectedDate.month &&
        date.day == selectedDate.day) {
      return true;
    }
  }
  return false;
}
