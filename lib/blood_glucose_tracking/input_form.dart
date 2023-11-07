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
    super.key,
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
    super.key,
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
      padding: const EdgeInsets.only(
        top: 25,
        left: 10,
        right: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    "GLUCOSE LEVEL",
                    style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2),
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    "assets/glucose_logo.png",
                    width: 120,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          Material(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                      top: 15,
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
                          height: 25,
                          width: 60,
                          duration: const Duration(milliseconds: 150),
                          activeColor: const Color(0xFFF7C6FF),
                          activeToggleColor: const Color(0xFF841896),
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
                      left: 15,
                      right: 15,
                      bottom: 15,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Icon(
                          Symbols.glucose,
                          color: Color(0xFFE25430),
                          weight: 700,
                          size: 54,
                        ),
                        const SizedBox(width: 20),
                        IntrinsicWidth(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            maxLength: 5,
                            inputFormatters: [
                              // NOTE: Only allows a single decimal point (.)
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
                              height: 0.8,
                              fontSize: 36,
                            ),
                            decoration: InputDecoration(
                              isCollapsed: true,
                              hintText: "0.00",
                              counterText: "",
                              border: InputBorder.none,
                              hintStyle: GoogleFonts.inter(
                                color: const Color(0xFFE25430),
                                fontWeight: FontWeight.bold,
                                height: 0.8,
                                fontSize: 36,
                              ),
                            ),
                            controller: _converterController,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _isMmolPerLiter ? "mmol/L" : "mg/dL",
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
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
                                  final formatter =
                                      DateFormat("dd / MM / yyyy");

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
          ),
          const SizedBox(height: 15),
          Material(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                TextField(
                  controller: _notesController,
                  maxLines: 7,
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
          const SizedBox(height: 5),
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
                            title: const Text('Delete Record'),
                            content: const Text('Are you sure?'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Yes'),
                                onPressed: () async {
                                  // Perform some action
                                  await widget._database.delete("GlucoseRecord",
                                      where: "id = ?",
                                      whereArgs: [widget._existing!.id]);

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
                  );
                },
              ),
              const Expanded(child: SizedBox()),
              const Text(
                "A1C",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              Checkbox(
                value: _isA1C,
                visualDensity: VisualDensity.comfortable,
                activeColor: fgColor,
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
              width: 150,
              child: TextButton(
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

                  if (date.isAfter(DateTime.now())) {
                    await ScaffoldMessenger.of(context)
                        .showSnackBar(
                          const SnackBar(
                            duration: Duration(milliseconds: 300),
                            content: Text('Cannot enter future date'),
                          ),
                        )
                        .closed;

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
                    await error();
                    return;
                  }

                  // NOTE: Beware of SQL Injection in notes argument
                  if (widget._existing == null) {
                    await widget._database.rawInsert(
                        "INSERT INTO GlucoseRecord (glucose_level, notes, is_a1c, blood_test_date) VALUES (?, ?, ?, ?)",
                        [
                          _glucoseController.text,
                          _notesController.text,
                          _isA1C.toString(),
                          date.toIso8601String()
                        ]);
                  } else {
                    await widget._database.rawUpdate(
                      "UPDATE GlucoseRecord SET glucose_level = ?, notes = ?, is_a1c = ?, blood_test_date = ? WHERE id = ?",
                      [
                        _glucoseController.text,
                        _notesController.text,
                        _isA1C,
                        date.toIso8601String(),
                        widget._existing!.id,
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

                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(fgColor),
                  overlayColor: MaterialStateProperty.all(
                    Colors.white.withOpacity(0.5),
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                child: Text(
                  widget._existing == null ? "SUBMIT" : "SAVE",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
