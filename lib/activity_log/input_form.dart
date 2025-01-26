import 'package:dialife/activity_log/entities.dart';
import 'package:dialife/api/api.dart';
import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sqflite/sqflite.dart';

class ActivityLogInput extends StatelessWidget {
  final ActivityRecord? existing;
  final DateTime? now;
  final Database db;

  const ActivityLogInput({
    super.key,
    required this.existing,
    required this.now,
    required this.db,
  });

  @override
  Widget build(BuildContext context) {
    return _ActivityLogInternalScaffold(
      db: db,
      now: now,
      existing: existing,
    );
  }
}

class _ActivityLogInternalScaffold extends StatelessWidget {
  final ActivityRecord? existing;
  final DateTime? now;
  final Database db;

  const _ActivityLogInternalScaffold({
    required this.existing,
    required this.now,
    required this.db,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(title: const Text("Activity Log Form")),
      body: SafeArea(
        child: SingleChildScrollView(
          child: _ActivityLogInternal(
            db: db,
            now: now,
            existing: existing,
          ),
        ),
      ),
    );
  }
}

class _ActivityLogInternal extends StatefulWidget {
  final ActivityRecord? existing;
  final DateTime? now;
  final Database db;

  const _ActivityLogInternal({
    required this.existing,
    required this.now,
    required this.db,
  });

  @override
  State<_ActivityLogInternal> createState() => _ActivityLogInternalState();
}

class _ActivityLogInternalState extends State<_ActivityLogInternal> {
  final ValueNotifier<DateTime?> _date = ValueNotifier(null);

  final ValueNotifier<TimeOfDay?> _time = ValueNotifier(null);

  final _notesController = TextEditingController();

  final _durationController = TextEditingController();

  final _frequencyController = TextEditingController();

  ExerciseType? _type;

  @override
  void initState() {
    super.initState();

    _date.value = widget.now;
    if (widget.existing == null) {
      return;
    }

    _notesController.text = widget.existing!.notes;
    _durationController.text = widget.existing!.duration.toString();
    _frequencyController.text = widget.existing!.frequency.toString();
    _type = widget.existing!.type;

    _date.value = widget.existing!.createdAt;
    _time.value = TimeOfDay(
      hour: widget.existing!.createdAt.hour,
      minute: widget.existing!.createdAt.minute,
    );

    // NOTE: now has priority over existing
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30, right: 10, left: 10),
      child: Column(
        children: [
          Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  Text(
                    "ACTIVITY LOG",
                    style: GoogleFonts.istokWeb(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Image.asset("assets/activity_log.png", width: 200),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(10),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField(
                          value: widget.existing?.type.asString.capitalize(),
                          decoration: InputDecoration(
                            fillColor: Colors.grey.shade200,
                            filled: true,
                            labelText: 'Exercise Type',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: [
                            "Walking",
                            "Zumba",
                            "Jogging",
                            "Lifting",
                          ].map((type) {
                            return DropdownMenuItem(
                                value: type, child: Text(type));
                          }).toList(),
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }

                            _type = parseExerciseType(value.toLowerCase());
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: _durationController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            fillColor: Colors.grey.shade200,
                            filled: true,
                            labelText: 'Mins',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          keyboardType: TextInputType.number,
                          controller: _frequencyController,
                          decoration: InputDecoration(
                            fillColor: Colors.grey.shade200,
                            filled: true,
                            labelText: 'No. of Times',
                            labelStyle: const TextStyle(fontSize: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: 0,
                  thickness: 2,
                  color: Color(0xFFCDCDCD),
                ),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _date.value != null
                                  ? _date.value!
                                  : DateTime.now(),
                              firstDate: DateTime(1),
                              lastDate: DateTime.now(),
                            );

                            if (date == null) {
                              return;
                            }

                            _date.value = date;
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFFE1E1E1),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                              ),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: ValueListenableBuilder(
                              valueListenable: _date,
                              builder: (context, value, child) {
                                final formatter = DateFormat("dd / MM / yyyy");

                                String result;

                                if (value != null) {
                                  result = formatter.format(value);
                                } else {
                                  result = "DD / MM / YYYY";
                                }

                                return Text(
                                  result,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    color: const Color(0xFF848181),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      Container(
                        color: const Color(0xFFCDCDCD),
                        width: 2,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: _time.value != null
                                  ? _time.value!
                                  : TimeOfDay.now(),
                            );
                            if (time == null) {
                              return;
                            }

                            _time.value = time;
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE1E1E1),
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                            child: ValueListenableBuilder(
                              valueListenable: _time,
                              builder: (context, value, child) {
                                final formatter = DateFormat("hh : mm a");

                                String result;

                                if (value != null) {
                                  result = formatter.format(
                                    DateTime.now().copyWith(
                                      hour: value.hour,
                                      minute: value.minute,
                                    ),
                                  );
                                } else {
                                  result = "HH : MM";
                                }

                                return Text(
                                  result,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    color: const Color(0xFF848181),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Material(
            elevation: 4,
            child: Stack(
              children: [
                TextField(
                  controller: _notesController,
                  maxLines: 4,
                  maxLength: 255,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(
                      top: 32,
                      left: 8,
                      right: 8,
                    ),
                    fillColor: Color(0xFFFFFCB7),
                    counterText: "",
                    filled: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "NOTES",
                        style: GoogleFonts.inter(
                          color: Colors.grey,
                        ),
                      ),
                      const Icon(
                        Symbols.add_notes,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(child: SizedBox()),
              TextButton(
                onPressed: () async {
                  Future<void> error() async {
                    await ScaffoldMessenger.of(context)
                        .showSnackBar(
                          const SnackBar(
                            duration: Duration(milliseconds: 300),
                            content: Text('Incomplete Form'),
                          ),
                        )
                        .closed;
                  }

                  if (_date.value == null || _time.value == null) {
                    await error();
                    return;
                  }

                  final date = _date.value!.copyWith(
                    hour: _time.value!.hour,
                    minute: _time.value!.minute,
                  );

                  if (_type == null ||
                      _durationController.text.isEmpty ||
                      _frequencyController.text.isEmpty) {
                    await error();
                    return;
                  }

                  if (widget.existing == null) {
                    await widget.db.rawInsert(
                      "INSERT INTO ActivityRecord (type, duration, frequency, notes, created_at) VALUES (?, ?, ?, ?, ?)",
                      [
                        _type!.asString,
                        _durationController.text,
                        _frequencyController.text,
                        _notesController.text,
                        date.toIso8601String(),
                      ],
                    );
                  } else {
                    await widget.db.rawUpdate(
                      "UPDATE ActivityRecord SET type = ?, duration = ?, frequency = ?, notes = ?,  created_at = ? WHERE id = ?",
                      [
                        _type!.asString,
                        _durationController.text,
                        _frequencyController.text,
                        _notesController.text,
                        date.toIso8601String(),
                        widget.existing!.id,
                      ],
                    );
                  }

                  if (context.mounted) {
                    await ScaffoldMessenger.of(context)
                        .showSnackBar(
                          const SnackBar(
                            duration: Duration(milliseconds: 300),
                            content: Text('Success'),
                          ),
                        )
                        .closed;
                  }

                  await MonitoringAPI.syncActivityRecords().then((_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          duration: Duration(milliseconds: 1000),
                          content: Text('Synced activity records'),
                        ),
                      );
                    }
                  }).catchError((_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          duration: Duration(milliseconds: 1000),
                          content: Text('Failed to sync activity records'),
                        ),
                      );
                    }
                  });

                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
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
                child: Text(
                  widget.existing == null ? "Submit" : "Save",
                  style: GoogleFonts.istokWeb(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              () {
                if (widget.existing == null) {
                  return const Expanded(child: SizedBox());
                }

                return Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Delete Record'),
                                content: const Text('Are you sure?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Yes'),
                                    onPressed: () async {
                                      // Perform some action
                                      await widget.db.delete("ActivityRecord",
                                          where: "id = ?",
                                          whereArgs: [widget.existing!.id]);

                                      try {
                                        await MonitoringAPI
                                            .syncActivityRecords();

                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              duration:
                                                  Duration(milliseconds: 1000),
                                              content: Text(
                                                  'Synced activity records'),
                                            ),
                                          );
                                        }
                                      } catch (_) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              duration:
                                                  Duration(milliseconds: 1000),
                                              content: Text(
                                                  'Failed to sync activity records'),
                                            ),
                                          );
                                        }
                                      }

                                      if (!context.mounted) {
                                        return;
                                      }

                                      int count = 0;
                                      Navigator.of(context)
                                          .popUntil((_) => count++ >= 2);
                                    },
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('No'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                );
              }(),
            ],
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
