import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:dialife/api/api.dart';
import 'package:dialife/api/entities.dart';
import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:dialife/local_notifications/local_notifications.dart';
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
import 'package:table_calendar/table_calendar.dart';

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
        backgroundColor: fgColor,
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
                    activeColor: fgColor,
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
                context,
                firstRecord.id,
                firstRecord.medicineName,
                _selectedDate,
                record.value,
                widget.reset,
                widget.db,
              ),
            );
          }),
        ],
      ),
    );
  }
}

Widget medicationReminderListTile(
  BuildContext context,
  int id,
  String name,
  DateTime pickedDate,
  List<MedicationRecordDetails> values,
  void Function() reset,
  Database db,
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

  List<TimeOfDay> uniqueTimes = selectedTimes.toSet().toList();

  if (isSelectedDateInList(pickedDate, dateTimes)) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Material(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: GestureDetector(
            onTap: () async {
              final record = (await db.rawQuery(
                "SELECT * FROM MedicationRecordDetails WHERE id = ?",
                [id],
              ))
                  .first;

              if (!context.mounted) return;
              await Navigator.of(context).pushNamed(
                "/medication-tracking/input",
                arguments: {
                  "db": db,
                  "existing": MedicationRecordDetails.fromMap(record),
                },
              );

              reset();
            },
            child: ListTile(
              leading: const Icon(
                Symbols.pill,
                color: Color(0xFF326BFD),
              ),
              title: Row(
                children: [
                  AutoSizeText(
                    name,
                    maxLines: 1,
                    maxFontSize: 24,
                    minFontSize: 18,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Expanded(child: SizedBox()),
                  // firstRecord.medicationDatetime.isAfter(DateTime.now())
                  //     ? const SizedBox()
                  //     : TextButton(
                  //         onPressed: firstRecord.actualTakenTime == null
                  //             ? () async {
                  //                 await db.update("MedicationRecordDetails", {
                  //                   "actual_taken_time":
                  //                       DateTime.now().toIso8601String(),
                  //                 });

                  //                 reset();

                  //                 MonitoringAPI.recordSyncAll(
                  //                   await APIPatientRecordUploadable
                  //                       .normalizedRecords(),
                  //                 );
                  //               }
                  //             : null,
                  //         style: ButtonStyle(
                  //           padding: MaterialStateProperty.all(
                  //             const EdgeInsets.symmetric(
                  //               horizontal: 8,
                  //             ),
                  //           ),
                  //           backgroundColor: MaterialStateProperty.all(
                  //             firstRecord.actualTakenTime == null
                  //                 ? const Color(0xFF326BFD)
                  //                 : Colors.grey,
                  //           ),
                  //           overlayColor: firstRecord.actualTakenTime != null
                  //               ? null
                  //               : MaterialStateProperty.all(
                  //                   Colors.white.withOpacity(0.3),
                  //                 ),
                  //         ),
                  //         child: Container(
                  //           alignment: Alignment.center,
                  //           width: 80,
                  //           height: 25,
                  //           child: AutoSizeText(
                  //             firstRecord.actualTakenTime == null
                  //                 ? "Complete"
                  //                 : "Taken @${DateFormat("h:mm a").format(firstRecord.actualTakenTime!)}",
                  //             minFontSize: 10,
                  //             maxLines: 2,
                  //             textAlign: TextAlign.center,
                  //             style: GoogleFonts.istokWeb(
                  //               letterSpacing: 1.0,
                  //               height: 1.0,
                  //               color: Colors.white,
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  IconButton(
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Medication Reminder?'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Confirm'),
                              onPressed: () async {
                                final record = (await db.rawQuery(
                                  "SELECT * FROM MedicationRecordDetails WHERE id = ?",
                                  [id],
                                ))
                                    .first;

                                final notifRecords = await db.rawQuery(
                                  "SELECT * FROM MedicationRecordDetails WHERE medication_reminder_record_id = ?",
                                  [
                                    record["medication_reminder_record_id"],
                                  ],
                                );

                                final parsedIds =
                                    MedicationRecordDetails.fromListOfMaps(
                                            notifRecords)
                                        .map((element) => element.notifId)
                                        .toList();

                                for (var id in parsedIds) {
                                  await LocalNotification.cancel(id);
                                }

                                await db.rawDelete(
                                  "DELETE FROM MedicationReminderRecords WHERE id = ?",
                                  [
                                    record["medication_reminder_record_id"],
                                  ],
                                );

                                await db.rawDelete(
                                  "DELETE FROM MedicationRecordDetails WHERE medication_reminder_record_id = ?",
                                  [
                                    record["medication_reminder_record_id"],
                                  ],
                                );

                                reset();
                                await MonitoringAPI.syncMedicationRecords()
                                    .then((_) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        duration: Duration(milliseconds: 1000),
                                        content:
                                            Text('Synced activity records'),
                                      ),
                                    );
                                  }
                                }).catchError((_) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        duration: Duration(milliseconds: 1000),
                                        content: Text(
                                            'Failed to sync activity records'),
                                      ),
                                    );
                                  }
                                });

                                if (!context.mounted) return;
                                Navigator.pop(context);
                              },
                            ),
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete_outlined),
                  ),
                ],
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
                      // NOTE: Replace with relevant times
                      ...values
                          .where((element) =>
                              isSameDay(element.medicationDatetime, pickedDate))
                          .map(
                        (value) {
                          DateTime now = DateTime.now();
                          return Row(
                            children: [
                              Chip(
                                label: Text(
                                  DateFormat("hh:mm a").format(
                                    DateTime(
                                      now.year,
                                      now.month,
                                      now.day,
                                      value.medicationDatetime.hour,
                                      value.medicationDatetime.minute,
                                    ),
                                  ),
                                ),
                                labelStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                backgroundColor: const Color(0xFF326BFD),
                              ),
                              const Expanded(child: SizedBox()),
                              value.medicationDatetime.isAfter(DateTime.now())
                                  ? const Text("Don't Take Yet")
                                  : TextButton(
                                      style: ButtonStyle(
                                        padding: WidgetStateProperty.all(
                                          const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                        ),
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                          value.actualTakenTime == null
                                              ? const Color(0xFF326BFD)
                                              : Colors.grey,
                                        ),
                                        overlayColor: value.actualTakenTime !=
                                                null
                                            ? null
                                            : WidgetStateProperty.all(
                                                Colors.white.withOpacity(0.3),
                                              ),
                                      ),
                                      onPressed: value.actualTakenTime != null
                                          ? null
                                          : () async {
                                              await db.update(
                                                "MedicationRecordDetails",
                                                {
                                                  "actual_taken_time":
                                                      DateTime.now()
                                                          .toIso8601String(),
                                                },
                                                where: "notification_id = ?",
                                                whereArgs: [value.notifId],
                                              );

                                              reset();

                                              await MonitoringAPI
                                                      .syncMedicationRecords()
                                                  .then((_) {
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      duration: Duration(
                                                          milliseconds: 1000),
                                                      content: Text(
                                                          'Synced medication records'),
                                                    ),
                                                  );
                                                }
                                              }).catchError((_) {
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      duration: Duration(
                                                          milliseconds: 1000),
                                                      content: Text(
                                                          'Failed to sync medication records'),
                                                    ),
                                                  );
                                                }
                                              });
                                            },
                                      child: Text(
                                        value.actualTakenTime == null
                                            ? "Complete"
                                            : "Taken @${DateFormat("h:mm a").format(value.actualTakenTime!)}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
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
