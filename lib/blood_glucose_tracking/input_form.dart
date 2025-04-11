import 'package:dialife/api/api.dart';
import 'package:dialife/api/entities.dart';
import 'package:dialife/blood_glucose_tracking/entities.dart';
import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:dialife/blood_glucose_tracking/utils.dart';
import 'package:dialife/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sqflite/sqflite.dart';

const bloodColor = Color(0xFFB84141);

class GlucoseRecordInputForm extends StatelessWidget {
  final User _user;
  final Database _db;
  final GlucoseRecord? _existing;

  const GlucoseRecordInputForm({
    super.key,
    required User user,
    required Database db,
    required GlucoseRecord? existing,
  })  : _existing = existing,
        _user = user,
        _db = db;

  @override
  Widget build(BuildContext context) {
    return _GlucoseRecordInputFormInternalScaffold(
      existing: _existing,
      db: _db,
      user: _user,
    );
  }
}

class _GlucoseRecordInputFormInternalScaffold extends StatelessWidget {
  final User _user;
  final Database _db;
  final GlucoseRecord? _existing;

  const _GlucoseRecordInputFormInternalScaffold({
    required User user,
    required Database db,
    required GlucoseRecord? existing,
  })  : _user = user,
        _existing = existing,
        _db = db;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text("Glucose Form"),
      ),
      body: SingleChildScrollView(
        child: _GlucoseRecordInputFormInternal(
          existing: _existing,
          db: _db,
          user: _user,
        ),
      ),
    );
  }
}

class _GlucoseRecordInputFormInternal extends StatefulWidget {
  final User _user;
  final GlucoseRecord? _existing;
  final Database _database;

  const _GlucoseRecordInputFormInternal({
    required User user,
    required Database db,
    required GlucoseRecord? existing,
  })  : _user = user,
        _existing = existing,
        _database = db;

  @override
  State<_GlucoseRecordInputFormInternal> createState() =>
      _GlucoseRecordInputFormInternalState();
}

class _GlucoseRecordInputFormInternalState
    extends State<_GlucoseRecordInputFormInternal> {
  final _notesController = TextEditingController();

  final _glucoseController = TextEditingController();

  final _converterController = TextEditingController();

  final _date = ValueNotifier<DateTime?>(null);

  final _time = ValueNotifier<TimeOfDay?>(null);

  late bool _isA1C;
  late bool _isMmolPerLiter;

  @override
  void initState() {
    _isA1C = widget._existing != null ? widget._existing!.isA1C : false;
    _isMmolPerLiter = true;

    _date.value = DateTime.now();
    _time.value = TimeOfDay.now();

    _converterController.addListener(() {
      if (_converterController.text.isEmpty) {
        return;
      }

      if (_isMmolPerLiter) {
        _glucoseController.text = _converterController.text;
      } else {
        _glucoseController.text =
            mgDLToMmolL(double.parse(_converterController.text))
                .toStringAsFixed(2);
      }
    });

    if (widget._existing != null) {
      _converterController.text =
          widget._existing!.glucoseLevel.toStringAsFixed(2);
    }

    if (widget._existing == null) {
      return;
    }

    _notesController.text = widget._existing!.notes;
    _glucoseController.text = widget._existing!.glucoseLevel.toStringAsFixed(2);
    _date.value = widget._existing!.bloodTestDate;
    _time.value = TimeOfDay(
      hour: widget._existing!.bloodTestDate.hour,
      minute: widget._existing!.bloodTestDate.minute,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_glucoseController.text.isNotEmpty &&
        _converterController.text.isNotEmpty) {
      if (!_isMmolPerLiter) {
        _converterController.text =
            mmolLToMgDL(double.parse(_glucoseController.text))
                .toStringAsFixed(2);
      } else {
        _converterController.text = _glucoseController.text;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    "GLUCOSE LEVEL",
                    style: GoogleFonts.montserrat(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    "assets/glucose_logo.png",
                    width: 110,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Material(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 18,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Blood Glucose Value",
                          style: GoogleFonts.istokWeb(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        FlutterSwitch(
                          value: _isMmolPerLiter,
                          height: 28,
                          width: 62,
                          padding: 4,
                          duration: const Duration(milliseconds: 150),
                          activeColor: const Color(0xFFF7C6FF),
                          inactiveColor: const Color(0xFFE6E6E6),
                          activeToggleColor: const Color(0xFF841896),
                          inactiveToggleColor: const Color(0xFF666666),
                          onToggle: (value) {
                            setState(() {
                              _isMmolPerLiter = !_isMmolPerLiter;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 18,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Icon(
                          Symbols.glucose,
                          color: Color(0xFFE25430),
                          weight: 700,
                          size: 52,
                        ),
                        const SizedBox(width: 20),
                        IntrinsicWidth(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            maxLength: 5,
                            inputFormatters: [
                              TextInputFormatter.withFunction(
                                (oldValue, newValue) {
                                  final text = newValue.text;
                                  return text.isEmpty
                                      ? newValue
                                      : double.tryParse(text) == null
                                          ? oldValue
                                          : newValue;
                                },
                              ),
                            ],
                            style: GoogleFonts.inter(
                              color: const Color(0xFFE25430),
                              fontWeight: FontWeight.bold,
                              height: 0.9,
                              fontSize: 38,
                            ),
                            decoration: InputDecoration(
                              isCollapsed: true,
                              hintText: "0.00",
                              counterText: "",
                              border: InputBorder.none,
                              hintStyle: GoogleFonts.inter(
                                color: const Color(0xFFE25430).withOpacity(0.6),
                                fontWeight: FontWeight.bold,
                                height: 0.9,
                                fontSize: 38,
                              ),
                            ),
                            controller: _converterController,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isMmolPerLiter ? "mmol/L" : "mg/dL",
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            height: 1,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 0,
                    thickness: 1.5,
                    color: Color(0xFFE0E0E0),
                  ),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _date.value ?? DateTime.now(),
                                firstDate: DateTime(1),
                                lastDate: DateTime.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Color(0xFF841896),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );

                              if (date != null) {
                                _date.value = date;
                              }
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 10),
                              child: ValueListenableBuilder(
                                valueListenable: _date,
                                builder: (context, value, child) {
                                  final formatter =
                                      DateFormat("dd / MM / yyyy");
                                  String result = value != null
                                      ? formatter.format(value)
                                      : "DD / MM / YYYY";

                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 16,
                                        color: Color(0xFF666666),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        result,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF666666),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        Container(
                          color: const Color(0xFFE0E0E0),
                          width: 1.5,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: _time.value ?? TimeOfDay.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Color(0xFF841896),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (time != null) {
                                _time.value = time;
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 10),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(12),
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

                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.access_time_rounded,
                                        size: 16,
                                        color: Color(0xFF666666),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        result,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF666666),
                                        ),
                                      ),
                                    ],
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
          ),
          const SizedBox(height: 20),
          Material(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                TextField(
                  controller: _notesController,
                  maxLines: 6,
                  maxLength: 255,
                  style: GoogleFonts.inter(fontSize: 16),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(
                      top: 36,
                      left: 12,
                      right: 12,
                      bottom: 12,
                    ),
                    fillColor: const Color(0xFFFFFCB7),
                    counterStyle: GoogleFonts.inter(fontSize: 12),
                    hintText: "Add notes here...",
                    hintStyle: GoogleFonts.inter(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "NOTES",
                        style: GoogleFonts.inter(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Icon(
                        Symbols.add_notes,
                        color: Colors.grey.shade700,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Builder(
                builder: (context) {
                  if (widget._existing == null) {
                    return Container();
                  }

                  return IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(
                              'Delete Record',
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold),
                            ),
                            content: Text(
                              'Are you sure you want to delete this record?',
                              style: GoogleFonts.inter(),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text(
                                  'Cancel',
                                  style: GoogleFonts.inter(
                                      color: Colors.grey.shade700),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text(
                                  'Delete',
                                  style: GoogleFonts.inter(color: Colors.red),
                                ),
                                onPressed: () async {
                                  await widget._database.delete("GlucoseRecord",
                                      where: "id = ?",
                                      whereArgs: [widget._existing!.id]);

                                  if ((await User.currentUser).webId != null) {
                                    try {
                                      await MonitoringAPI.syncGlucoseRecords();

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            duration:
                                                Duration(milliseconds: 1000),
                                            content:
                                                Text('Synced glucose records'),
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
                                                'Failed to sync glucose records'),
                                          ),
                                        );
                                      }
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
                            ],
                          );
                        },
                      );
                    },
                    icon: Icon(
                      Icons.delete_outline,
                      size: 28,
                      color: Colors.red.shade400,
                    ),
                  );
                },
              ),
              const Expanded(child: SizedBox()),
              Text(
                "A1C Test",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Checkbox(
                value: _isA1C,
                visualDensity: VisualDensity.comfortable,
                activeColor: fgColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                onChanged: (value) {
                  setState(() {
                    _isA1C = !_isA1C;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 30),
          Center(
            child: SizedBox(
              width: 180,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  Future<void> error(String message) async {
                    await ScaffoldMessenger.of(context)
                        .showSnackBar(
                          SnackBar(
                            duration: const Duration(milliseconds: 1500),
                            behavior: SnackBarBehavior.floating,
                            content: Text(message),
                          ),
                        )
                        .closed;
                  }

                  if (_date.value == null || _time.value == null) {
                    await error('Please select date and time');
                    return;
                  }

                  final date = _date.value!.copyWith(
                    hour: _time.value!.hour,
                    minute: _time.value!.minute,
                  );

                  if (date.isAfter(DateTime.now())) {
                    await error('Cannot enter future date and time');
                    setState(() {
                      if (widget._existing != null) {
                        final current = widget._existing!.bloodTestDate;
                        _time.value = TimeOfDay(
                          hour: current.hour,
                          minute: current.minute,
                        );
                      } else {
                        _time.value = null;
                      }
                    });
                    return;
                  }

                  if (_glucoseController.text.isEmpty) {
                    await error('Please enter glucose value');
                    return;
                  }

                  if (widget._existing == null) {
                    await widget._database.rawInsert(
                        "INSERT INTO GlucoseRecord (glucose_level, notes, is_a1c, blood_test_date) VALUES (?, ?, ?, ?)",
                        [
                          _glucoseController.text,
                          _notesController.text,
                          _isA1C ? 1 : 0,
                          date.toIso8601String()
                        ]);
                  } else {
                    await widget._database.rawUpdate(
                      "UPDATE GlucoseRecord SET glucose_level = ?, notes = ?, is_a1c = ?, blood_test_date = ? WHERE id = ?",
                      [
                        _glucoseController.text,
                        _notesController.text,
                        _isA1C ? 1 : 0,
                        date.toIso8601String(),
                        widget._existing!.id,
                      ],
                    );
                  }

                  if ((await User.currentUser).webId != null) {
                    await MonitoringAPI.syncGlucoseRecords().then((_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            duration: Duration(milliseconds: 1000),
                            content: Text('Synced glucose records'),
                          ),
                        );
                      }
                    }).catchError((_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            duration: Duration(milliseconds: 1000),
                            content: Text('Failed to sync glucose records'),
                          ),
                        );
                      }
                    });
                  }

                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: fgColor,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  widget._existing == null ? "SUBMIT" : "SAVE CHANGES",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
