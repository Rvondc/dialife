import 'package:collection/collection.dart';
import 'package:dialife/activity_log/activity_log.dart';
import 'package:dialife/activity_log/entities.dart';
import 'package:dialife/api/api.dart';
import 'package:dialife/api/entities.dart';
import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:dialife/blood_glucose_tracking/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:table_calendar/table_calendar.dart';

class ActivityRecordEditor extends StatefulWidget {
  final Database db;

  const ActivityRecordEditor({
    super.key,
    required this.db,
  });

  @override
  State<ActivityRecordEditor> createState() => _ActivityRecordEditorState();
}

class _ActivityRecordEditorState extends State<ActivityRecordEditor> {
  @override
  Widget build(BuildContext context) {
    const loading = Scaffold(
      body: SpinKitCircle(color: fgColor),
    );

    void reset() {
      setState(() {});
    }

    return waitForFuture(
      loading: loading,
      future: widget.db.query("ActivityRecord"),
      builder: (context, data) {
        final parsedData = ActivityRecord.fromListOfMaps(data);
        // final parsedData = GlucoseRecord.mock(
        //   count: 50,
        //   daySpan: 365,
        //   a1cInDay: true,
        // );

        parsedData.sort((a, b) => a.createdAt.compareTo(b.createdAt));

        return _ActivityRecordEditorInternalScaffold(
          records: parsedData.reversed.toList(),
          reset: reset,
          db: widget.db,
        );
      },
    );
  }
}

enum HistoryFormat { linear, calendar }

class _ActivityRecordEditorInternalScaffold extends StatefulWidget {
  final Database db;
  final void Function() reset;
  final List<ActivityRecord> records;

  const _ActivityRecordEditorInternalScaffold({
    required this.db,
    required this.reset,
    required this.records,
  });

  @override
  State<_ActivityRecordEditorInternalScaffold> createState() =>
      _ActivityRecordEditorInternalScaffoldState();
}

class _ActivityRecordEditorInternalScaffoldState
    extends State<_ActivityRecordEditorInternalScaffold> {
  HistoryFormat _historyFormat = HistoryFormat.calendar;

  @override
  Widget build(BuildContext context) {
    if (widget.records.isEmpty) {
      // TODO:
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text("Activity Records"),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _historyFormat = _historyFormat == HistoryFormat.calendar
                    ? HistoryFormat.linear
                    : HistoryFormat.calendar;
              });
            },
            icon: _historyFormat != HistoryFormat.calendar
                ? const Icon(Icons.calendar_month_outlined)
                : const Icon(Icons.format_list_bulleted),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 10,
              right: 10,
              top: 0,
              bottom: 0,
            ),
            child: _ActivityRecordEditorInternal(
              db: widget.db,
              reset: widget.reset,
              records: widget.records,
              format: _historyFormat,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityRecordEditorInternal extends StatefulWidget {
  final Database db;
  final void Function() reset;
  final List<ActivityRecord> records;
  final HistoryFormat _historyFormat;

  const _ActivityRecordEditorInternal({
    required this.db,
    required this.reset,
    required this.records,
    required HistoryFormat format,
  }) : _historyFormat = format;

  @override
  State<_ActivityRecordEditorInternal> createState() =>
      _ActivityRecordEditorInternalState();
}

class _ActivityRecordEditorInternalState
    extends State<_ActivityRecordEditorInternal> {
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _format = CalendarFormat.month;

  List<ActivityRecord> _focusedDayEvents = [];

  @override
  void initState() {
    super.initState();
    _focusedDayEvents = widget.records
        .where((record) => isSameDay(record.createdAt, _focusedDay))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return true;
      },
      child: () {
        if (widget._historyFormat == HistoryFormat.calendar) {
          return ListView(
            children: [
              TableCalendar(
                calendarBuilders: CalendarBuilders(
                  todayBuilder: (context, day, focusedDay) {
                    return Container(
                      width: 40,
                      height: 40,
                      color: Colors.orange.withOpacity(0.1),
                      alignment: Alignment.topCenter,
                      child: Text(day.day.toString()),
                    );
                  },
                  selectedBuilder: (context, day, focusedDay) {
                    return Container(
                      width: 40,
                      height: 40,
                      color: Colors.orange.withOpacity(0.3),
                      alignment: Alignment.topCenter,
                      child: Text(
                        day.day.toString(),
                      ),
                    );
                  },
                  markerBuilder: (context, day, events) {
                    if (events.isEmpty) {
                      return null;
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 15,
                          height: 15,
                          color: fgColor.withOpacity(0.7),
                          alignment: Alignment.center,
                          child: Text(
                            events.length.toString(),
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                onFormatChanged: (format) {
                  setState(() {
                    _format = format;
                  });
                },
                calendarFormat: _format,
                firstDay: DateTime.now().subtract(
                  const Duration(days: 365),
                ),
                lastDay: DateTime.now().add(
                  const Duration(days: 365),
                ),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(day, _focusedDay);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                    _focusedDayEvents = widget.records
                        .where(
                            (record) => isSameDay(record.createdAt, focusedDay))
                        .toList();
                  });
                },
                eventLoader: (day) {
                  return widget.records
                      .where((record) => isSameDay(record.createdAt, day))
                      .toList();
                },
              ),
              const SizedBox(height: 10),
              () {
                if (_focusedDayEvents.isEmpty) {
                  return const SizedBox();
                }

                return Text(
                  "Records",
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                  ),
                );
              }(),
              ..._focusedDayEvents.mapIndexed((
                index,
                current,
              ) {
                final color = switch (current.type) {
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
                        "existing": current,
                      },
                    );

                    widget.reset();
                  },
                  child: Dismissible(
                    key: ValueKey(index),
                    onDismissed: (direction) async {
                      await widget.db.delete(
                        "ActivityRecord",
                        where: "id = ?",
                        whereArgs: [current.id],
                      );

                      widget.reset();
                      MonitoringAPI.recordSyncAll();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(5),
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
                                    "${current.duration} mins",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    "Frequency: x${current.frequency}",
                                    style: GoogleFonts.montserrat(),
                                  ),
                                ],
                              ),
                              const Expanded(child: SizedBox()),
                              Text(
                                "Started: ${DateFormat("MMM. dd hh:mm a").format(current.createdAt)}",
                                style: GoogleFonts.montserrat(fontSize: 14),
                              ),
                            ],
                          ),
                          subtitle: Text(
                              "Notes: ${current.notes.isEmpty ? "--" : current.notes}"),
                          tileColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      final result = ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 1),
                          content: const Text('Delete?'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                            },
                          ),
                        ),
                      );

                      return await result.closed != SnackBarClosedReason.action;
                    },
                  ),
                );
              }).toList(),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.bottomLeft,
                child: FloatingActionButton(
                  onPressed: () async {
                    if (_focusedDay.isAfter(DateTime.now())) {
                      return;
                    }

                    await Navigator.of(context).pushNamed(
                      "/activity-log/input",
                      arguments: {
                        "db": widget.db,
                        "now": _focusedDay,
                      },
                    );

                    widget.reset();
                  },
                  shape: const CircleBorder(),
                  backgroundColor: fgColor,
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        } else {
          return ListView.builder(
            itemBuilder: (context, index) {
              final current = widget.records[index];
              final color = switch (current.type) {
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
                      "existing": current,
                    },
                  );

                  widget.reset();
                },
                child: Dismissible(
                  key: ValueKey(index),
                  onDismissed: (direction) async {
                    await widget.db.delete(
                      "ActivityRecord",
                      where: "id = ?",
                      whereArgs: [current.id],
                    );

                    MonitoringAPI.recordSyncAll();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(5),
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
                                  "${current.duration} mins",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  "Frequency: x${current.frequency}",
                                  style: GoogleFonts.montserrat(),
                                ),
                              ],
                            ),
                            const Expanded(child: SizedBox()),
                            Text(
                              "Started: ${DateFormat("MMM. dd hh:mm a").format(current.createdAt)}",
                              style: GoogleFonts.montserrat(fontSize: 14),
                            ),
                          ],
                        ),
                        subtitle: Text(
                            "Notes: ${current.notes.isEmpty ? "--" : current.notes}"),
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    final result = ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(seconds: 1),
                        content: const Text('Delete?'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          },
                        ),
                      ),
                    );

                    return await result.closed != SnackBarClosedReason.action;
                  },
                ),
              );
            },
            itemCount: widget.records.length,
          );
        }
      }(),
    );
  }
}
