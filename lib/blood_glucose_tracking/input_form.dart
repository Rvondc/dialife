import 'package:auto_size_text/auto_size_text.dart';
import 'package:dialife/blood_glucose_tracking/entities.dart';
import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:dialife/blood_glucose_tracking/utils.dart';
import 'package:dialife/user.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:toggle_switch/toggle_switch.dart';

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
      appBar: AppBar(title: const Text("Glucose Input")),
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

  final _date = ValueNotifier<DateTime?>(null);

  final _time = ValueNotifier<TimeOfDay?>(null);

  late bool _isA1C;

  @override
  void initState() {
    _isA1C = widget._existing != null ? widget._existing!.isA1C : false;

    if (widget._existing == null) {
      return;
    }

    _notesController.text = widget._existing!.notes;
    _glucoseController.text = widget._existing!.glucoseLevel.toStringAsFixed(2);
    _date.value = widget._existing!.bloodTestDate;
    _time.value = TimeOfDay(
      hour: widget._existing!.bloodTestDate.hour,
      minute: widget._existing!.bloodTestDate.hour,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.only(
            top: 20,
            left: 10,
            right: 10,
          ),
          width: constraints.maxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "User Profile",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                ),
              ),
              Text(
                widget._user.name,
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          CustomDatePicker(
                            existing: widget._existing,
                            date: _date,
                            constraints: constraints,
                          ),
                          const SizedBox(height: 10),
                          CustomTimePicker(
                            existing: widget._existing,
                            time: _time,
                            constraints: constraints,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GlucoseValueInput(
                        existing: widget._existing,
                        glucoseController: _glucoseController,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              const Row(
                children: [
                  Icon(Icons.description_outlined),
                  SizedBox(width: 5),
                  Text("TAP TO ADD NOTES"),
                ],
              ),
              const SizedBox(height: 15),
              Material(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _notesController,
                  maxLines: 7,
                  maxLength: 255,
                  decoration: const InputDecoration(
                    fillColor: Color(0xFFFEFAAA),
                    counterText: "",
                    filled: true,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  SizedBox(
                    width: 100,
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

                        if (_glucoseController.text.isEmpty) {
                          await error();
                          return;
                        }

                        // NOTE: Beware of SQL Injection in notes argument
                        if (widget._existing == null) {
                          await widget._database.rawInsert(
                              "INSERT INTO GlucoseRecord (glucose_level, notes, is_a1c, blood_test_date) VALUES (${_glucoseController.text}, '${_notesController.text}', ${_isA1C.toString()}, '${date.toIso8601String()}')");
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
            ],
          ),
        );
      },
    );
  }
}

class GlucoseValueInput extends StatefulWidget {
  final GlucoseRecord? existing;
  final TextEditingController _glucoseController;

  const GlucoseValueInput({
    super.key,
    required TextEditingController glucoseController,
    required this.existing,
  }) : _glucoseController = glucoseController;

  @override
  State<GlucoseValueInput> createState() => _GlucoseValueInputState();
}

class _GlucoseValueInputState extends State<GlucoseValueInput> {
  Units _unit = Units.mmolPerLiter;

  final _converterController = TextEditingController();

  @override
  void initState() {
    _converterController.addListener(() {
      if (_converterController.text.isEmpty) {
        return;
      }

      if (_unit == Units.mmolPerLiter) {
        widget._glucoseController.text = _converterController.text;
      } else {
        widget._glucoseController.text =
            mgDLToMmolL(double.parse(_converterController.text))
                .toStringAsFixed(3);
      }
    });

    if (widget.existing != null) {
      _converterController.text =
          widget.existing!.glucoseLevel.toStringAsFixed(2);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget._glucoseController.text.isNotEmpty) {
      if (_unit == Units.milligramsPerDeciliter) {
        _converterController.text =
            mmolLToMgDL(double.parse(widget._glucoseController.text))
                .toStringAsFixed(2);
      } else {
        _converterController.text = widget._glucoseController.text;
      }
    }

    return Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(
                  Icons.bloodtype_outlined,
                  color: bloodColor,
                  size: 24,
                ),
                Text(
                  "GLUCOSE",
                  style: TextStyle(
                    color: bloodColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 40,
              child: TextField(
                controller: _converterController,
                style: const TextStyle(
                  fontSize: 16,
                ),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  fillColor: Colors.black.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  isDense: true,
                  filled: true,
                ),
              ),
            ),
            ToggleSwitch(
              onToggle: (index) {
                switch (index) {
                  case 0:
                    setState(() {
                      _unit = Units.mmolPerLiter;
                    });
                  case 1:
                    setState(() {
                      _unit = Units.milligramsPerDeciliter;
                    });
                }
              },
              initialLabelIndex: _unit == Units.mmolPerLiter ? 0 : 1,
              fontSize: 12,
              labels: const ["mmol/L", "mg/dL"],
              radiusStyle: true,
              activeBgColor: const [fgColor],
              inactiveBgColor: Colors.black.withOpacity(0.2),
            )
          ],
        ),
      ),
    );
  }
}

class CustomDatePicker extends StatelessWidget {
  final BoxConstraints constraints;
  final ValueNotifier<DateTime?> _date;

  const CustomDatePicker({
    super.key,
    required ValueNotifier<DateTime?> date,
    required this.existing,
    required this.constraints,
  }) : _date = date;

  final GlucoseRecord? existing;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            firstDate: DateTime.fromMillisecondsSinceEpoch(0),
            initialDate: _date.value != null ? _date.value! : DateTime.now(),
            lastDate: DateTime.now(),
          );

          if (date == null) {
            return;
          }

          _date.value = date;
        },
        child: Ink(
          padding: const EdgeInsets.all(4),
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 0.2,
                blurRadius: 3,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.calendar_month_outlined,
                size: 32,
                color: Colors.black.withOpacity(0.6),
              ),
              const SizedBox(width: 5),
              SizedBox(
                width: (constraints.maxWidth / 2) - 60,
                child: ValueListenableBuilder(
                  valueListenable: _date,
                  builder: (context, value, child) {
                    DateTime? date;

                    if (value != null) {
                      date = _date.value;
                    } else if (existing != null) {
                      date = existing!.bloodTestDate;
                    }

                    return AutoSizeText(
                      date != null
                          ? DateFormat("dd/MM/yyyy").format(date)
                          : "DD/MM/YYYY",
                      maxLines: 1,
                      maxFontSize: 16,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTimePicker extends StatelessWidget {
  final BoxConstraints constraints;
  final ValueNotifier<TimeOfDay?> _time;

  const CustomTimePicker({
    super.key,
    required ValueNotifier<TimeOfDay?> time,
    required this.existing,
    required this.constraints,
  }) : _time = time;

  final GlucoseRecord? existing;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          final time = await showTimePicker(
            context: context,
            initialTime: _time.value != null ? _time.value! : TimeOfDay.now(),
          );

          if (time == null) {
            return;
          }

          _time.value = time;
        },
        child: Ink(
          padding: const EdgeInsets.all(4),
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 0.2,
                blurRadius: 3,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.schedule,
                size: 32,
                color: Colors.black.withOpacity(0.6),
              ),
              const SizedBox(width: 5),
              SizedBox(
                width: (constraints.maxWidth / 2) - 60,
                child: ValueListenableBuilder(
                    valueListenable: _time,
                    builder: (context, value, child) {
                      DateTime? time;

                      if (value != null) {
                        time = DateTime.now().copyWith(
                          hour: value.hour,
                          minute: value.minute,
                        );
                      } else if (existing != null) {
                        time = existing!.bloodTestDate;
                      }

                      return AutoSizeText(
                        time != null
                            ? DateFormat("hh:mm").format(time)
                            : "HH:MM",
                        maxLines: 1,
                        maxFontSize: 16,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      );
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
