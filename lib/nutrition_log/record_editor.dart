import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:dialife/api/api.dart';
import 'package:dialife/api/entities.dart';
import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:dialife/blood_glucose_tracking/utils.dart';
import 'package:dialife/nutrition_log/entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:table_calendar/table_calendar.dart';

class NutritionRecordEditor extends StatefulWidget {
  final Database db;

  const NutritionRecordEditor({
    super.key,
    required this.db,
  });

  @override
  State<NutritionRecordEditor> createState() => _NutritionRecordEditorState();
}

enum HistoryFormat { linear, calendar }

class _NutritionRecordEditorState extends State<NutritionRecordEditor> {
  @override
  Widget build(BuildContext context) {
    reset() {
      setState(() {});
    }

    return waitForFuture(
      loading: const SpinKitCircle(color: fgColor),
      future: widget.db.query("NutritionRecord"),
      builder: (context, data) {
        final parsedData = NutritionRecord.fromListOfMaps(data);

        parsedData.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return _NutritionEditorInternalScaffold(
          db: widget.db,
          records: parsedData,
          reset: reset,
        );
      },
    );
  }
}

class _NutritionEditorInternalScaffold extends StatefulWidget {
  final void Function() reset;
  final List<NutritionRecord> records;
  final Database db;

  const _NutritionEditorInternalScaffold({
    required this.records,
    required this.reset,
    required this.db,
  });

  @override
  State<_NutritionEditorInternalScaffold> createState() =>
      _NutritionEditorInternalScaffoldState();
}

class _NutritionEditorInternalScaffoldState
    extends State<_NutritionEditorInternalScaffold> {
  HistoryFormat _historyFormat = HistoryFormat.calendar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text("Nutrition Records"),
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
      body: SafeArea(
        child: _NutritionEditorInternal(
          db: widget.db,
          records: widget.records,
          format: _historyFormat,
          reset: widget.reset,
        ),
      ),
    );
  }
}

class _NutritionEditorInternal extends StatefulWidget {
  final void Function() reset;
  final List<NutritionRecord> records;
  final HistoryFormat _historyFormat;
  final Database db;

  const _NutritionEditorInternal({
    required this.reset,
    required this.records,
    required this.db,
    required HistoryFormat format,
  }) : _historyFormat = format;

  @override
  State<_NutritionEditorInternal> createState() =>
      _NutritionEditorInternalState();
}

class _NutritionEditorInternalState extends State<_NutritionEditorInternal> {
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _format = CalendarFormat.month;

  List<NutritionRecord> _focusedDayEvents = [];
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
      ),
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
                return GestureDetector(
                  onTap: () async {
                    await Navigator.of(context).pushNamed(
                      "/nutrition-log/input",
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
                        "NutritionRecord",
                        where: "id = ?",
                        whereArgs: [current.id],
                      );

                      widget.reset();
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
                                        const BoxShadow(color: fgColor),
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
                                    current.dayDescription,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14,
                                    ),
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
                      "/nutrition-log/input",
                      arguments: {
                        "db": widget.db,
                        "now": _focusedDay,
                      },
                    );
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
            itemCount: widget.records.length,
            itemBuilder: (context, index) {
              final current = widget.records[index];

              return Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Dismissible(
                  key: ValueKey(index),
                  onDismissed: (direction) async {
                    await widget.db.delete(
                      "NutritionRecord",
                      where: "id = ?",
                      whereArgs: [current.id],
                    );

                    MonitoringAPI.uploadPatientRecord(
                      await APIPatientRecordUploadable.latestCompiled(),
                    );
                  },
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
                  child: Material(
                    borderRadius: BorderRadius.circular(12),
                    elevation: 4,
                    shadowColor: fgColor,
                    child: GestureDetector(
                      onTap: () async {
                        await Navigator.of(context).pushNamed(
                          "/nutrition-log/input",
                          arguments: {
                            "db": widget.db,
                            "existing": current,
                          },
                        );

                        widget.reset();
                      },
                      child: ListTile(
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        leading: const Icon(
                          Icons.receipt,
                          color: fgColor,
                        ),
                        title: AutoSizeText(
                          DateFormat("MMM. dd, yyyy hh:mm a")
                              .format(current.createdAt),
                          maxLines: 1,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        // trailing: IntrinsicWidth(
                        //   child: Column(
                        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //     children: [
                        //       Row(
                        //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //         children: [
                        //           Container(
                        //             decoration: BoxDecoration(
                        //               color: proteinColor,
                        //               borderRadius: BorderRadius.circular(5),
                        //             ),
                        //             width: 10,
                        //             height: 10,
                        //           ),
                        //           const SizedBox(width: 3),
                        //           Text(
                        //             "${current.dayDescription}g",
                        //             style: const TextStyle(
                        //               fontSize: 12,
                        //               fontWeight: FontWeight.bold,
                        //             ),
                        //           ),
                        //           const SizedBox(width: 7),
                        //           Container(
                        //             decoration: BoxDecoration(
                        //               color: carbsColor,
                        //               borderRadius: BorderRadius.circular(5),
                        //             ),
                        //             width: 10,
                        //             height: 10,
                        //           ),
                        //           const SizedBox(width: 3),
                        //           Text(
                        //             "${current.foods}g",
                        //             style: const TextStyle(
                        //               fontWeight: FontWeight.bold,
                        //               fontSize: 12,
                        //             ),
                        //           ),
                        //         ],
                        //       ),

                        //     ],
                        //   ),
                        // ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              current.dayDescription,
                              style: GoogleFonts.istokWeb(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            AutoSizeText(
                              "Foods: ${current.foods.join(", ")}",
                              maxLines: 3,
                              overflow: TextOverflow.fade,
                            ),
                          ],
                        ),
                        // TODO: Add trailing
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }
      }(),
    );
  }
}
