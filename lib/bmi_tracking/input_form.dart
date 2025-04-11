import 'package:carousel_slider/carousel_slider.dart';
import 'package:dialife/api/api.dart';
import 'package:dialife/api/entities.dart';
import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:dialife/bmi_tracking/entities.dart';
import 'package:dialife/bmi_tracking/utils.dart';
import 'package:dialife/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class BMIRecordForm extends StatelessWidget {
  final User _user;
  final Database _db;
  final BMIRecord? _existing;

  const BMIRecordForm({
    super.key,
    required User user,
    required Database db,
    required BMIRecord? existing,
  })  : _user = user,
        _db = db,
        _existing = existing;

  @override
  Widget build(BuildContext context) {
    return _BMIRecordInputFormInternalScaffold(
      db: _db,
      user: _user,
      existing: _existing,
    );
  }
}

class _BMIRecordInputFormInternalScaffold extends StatelessWidget {
  final User _user;
  final Database _db;
  final BMIRecord? _existing;

  const _BMIRecordInputFormInternalScaffold({
    required User user,
    required Database db,
    required BMIRecord? existing,
  })  : _user = user,
        _db = db,
        _existing = existing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("BMI Form")),
      backgroundColor: Colors.grey.shade200,
      body: SingleChildScrollView(
        child: _BMIRecordInputFormInternal(
          db: _db,
          existing: _existing,
          user: _user,
        ),
      ),
    );
  }
}

class _BMIRecordInputFormInternal extends StatefulWidget {
  final User _user;
  final Database _db;
  final BMIRecord? _existing;

  const _BMIRecordInputFormInternal({
    required User user,
    required Database db,
    required BMIRecord? existing,
  })  : _user = user,
        _db = db,
        _existing = existing;

  @override
  State<_BMIRecordInputFormInternal> createState() =>
      _BMIRecordInputFormInternalState();
}

enum Action {
  changeHeightUnit,
  changeWeightUnit,
}

class _BMIRecordInputFormInternalState
    extends State<_BMIRecordInputFormInternal> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _finalHeightController = TextEditingController();
  final _finalWeightController = TextEditingController();

  Action? _currentAction;
  bool _isCentimeter = true;
  bool _isKilograms = true;
  DateTime? _date = DateTime.now();
  TimeOfDay? _time = TimeOfDay.now();

  @override
  void initState() {
    void onChangeWeightHandler() {
      if (_weightController.text.isEmpty) {
        return;
      }

      if (_isKilograms) {
        _finalWeightController.text = _weightController.text;
      } else {
        _finalWeightController.text =
            poundsToKilograms(double.parse(_weightController.text))
                .toStringAsFixed(2);
      }
    }

    _weightController.addListener(onChangeWeightHandler);

    void onChangeHeightHandler() {
      if (_heightController.text.isEmpty) {
        return;
      }

      if (_isCentimeter) {
        _finalHeightController.text = _heightController.text;
      } else {
        _finalHeightController.text =
            inchesToCentimeters(double.parse(_heightController.text))
                .toStringAsFixed(2);
      }
    }

    _heightController.addListener(onChangeHeightHandler);

    // NOTE:
    if (widget._existing == null) {
      return;
    }

    _heightController.text =
        (widget._existing!.heightInMeters * 100).toString();
    _weightController.text = (widget._existing!.weightInKilograms).toString();
    _date = widget._existing!.createdAt;
    _time = TimeOfDay(
      hour: widget._existing!.createdAt.hour,
      minute: widget._existing!.createdAt.minute,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_weightController.text.isNotEmpty &&
        _currentAction == Action.changeWeightUnit) {
      if (!_isKilograms) {
        _weightController.text =
            kilogramsToPounds(double.parse(_weightController.text))
                .toStringAsFixed(2);
      } else {
        _weightController.text =
            poundsToKilograms(double.parse(_weightController.text))
                .toStringAsFixed(2);
      }
    }

    if (_heightController.text.isNotEmpty &&
        _currentAction == Action.changeHeightUnit) {
      if (!_isCentimeter) {
        _heightController.text =
            centimetersToInches(double.parse(_heightController.text))
                .toStringAsFixed(2);
      } else {
        _heightController.text =
            inchesToCentimeters(double.parse(_heightController.text))
                .toStringAsFixed(2);
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
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.only(
                top: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    "BMI Calculator",
                    style: GoogleFonts.istokWeb(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Stack(
                    children: [
                      Positioned(
                        left: 0,
                        bottom: 0,
                        child: Icon(
                          widget._user.isMale ? Icons.male : Icons.female,
                          size: 32,
                          color: widget._user.isMale
                              ? Colors.blue
                              : const Color.fromARGB(255, 255, 92, 147),
                        ),
                      ),
                      Image.asset(
                        widget._user.isMale
                            ? "assets/bmi_male.png"
                            : "assets/bmi_female.png",
                        width: 400,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Text(
                            "${(widget._user.exactAge.inDays / 365).floor()} Years Old",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.istokWeb(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Material(
            elevation: 4,
            borderRadius: BorderRadiusDirectional.circular(10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadiusDirectional.circular(10),
              ),
              padding: const EdgeInsets.only(
                top: 16,
              ),
              child: Column(
                children: [
                  Text(
                    "INPUT YOUR HEIGHT AND WEIGHT",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.istokWeb(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // NOTE: Input
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 6 / 5,
                            child: Material(
                              shadowColor: fgColor,
                              elevation: 8,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  children: [
                                    Text(
                                      "HEIGHT",
                                      style: GoogleFonts.istokWeb(),
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(
                                            flex: 5,
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: TextField(
                                                maxLength: 5,
                                                textAlign: TextAlign.center,
                                                controller: _heightController,
                                                style: GoogleFonts.istokWeb(
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  border: InputBorder.none,
                                                  counterText: "",
                                                  hintText: "0.00",
                                                  hintStyle:
                                                      GoogleFonts.istokWeb(
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  TextInputFormatter
                                                      .withFunction(
                                                    (oldValue, newValue) {
                                                      final text =
                                                          newValue.text;
                                                      return text.isEmpty
                                                          ? newValue
                                                          : double.tryParse(
                                                                      text) ==
                                                                  null
                                                              ? oldValue
                                                              : newValue;
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            flex: 2,
                                            child: Stack(
                                              children: [
                                                Positioned.fill(
                                                  child: CarouselSlider(
                                                    items: [
                                                      Text(
                                                        "cm",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: GoogleFonts
                                                            .istokWeb(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        "in",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: GoogleFonts
                                                            .istokWeb(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                    options: CarouselOptions(
                                                      height: 0,
                                                      initialPage:
                                                          _isCentimeter ? 0 : 1,
                                                      onPageChanged:
                                                          (index, reason) {
                                                        setState(() {
                                                          _currentAction = Action
                                                              .changeHeightUnit;
                                                          _isCentimeter =
                                                              index == 0;
                                                        });
                                                      },
                                                      enableInfiniteScroll:
                                                          false,
                                                      viewportFraction: 0.4,
                                                      enlargeCenterPage: true,
                                                      aspectRatio: 2,
                                                      pageSnapping: true,
                                                      scrollDirection:
                                                          Axis.vertical,
                                                    ),
                                                  ),
                                                ),
                                                const Positioned.fill(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Divider(
                                                        color: Colors.black,
                                                      ),
                                                      Divider(
                                                        color: Colors.black,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 6 / 5,
                            child: Material(
                              shadowColor: fgColor,
                              elevation: 8,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  children: [
                                    Text(
                                      "WEIGHT",
                                      style: GoogleFonts.istokWeb(),
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(
                                            flex: 5,
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: TextField(
                                                textAlign: TextAlign.center,
                                                maxLength: 5,
                                                controller: _weightController,
                                                style: GoogleFonts.istokWeb(
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  border: InputBorder.none,
                                                  hintText: "0.00",
                                                  hintStyle:
                                                      GoogleFonts.istokWeb(
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  counterText: "",
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  TextInputFormatter
                                                      .withFunction(
                                                    (oldValue, newValue) {
                                                      final text =
                                                          newValue.text;
                                                      return text.isEmpty
                                                          ? newValue
                                                          : double.tryParse(
                                                                      text) ==
                                                                  null
                                                              ? oldValue
                                                              : newValue;
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            flex: 2,
                                            child: Stack(
                                              children: [
                                                Positioned.fill(
                                                  child: CarouselSlider(
                                                    items: [
                                                      Text(
                                                        "lb",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: GoogleFonts
                                                            .istokWeb(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        "kg",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: GoogleFonts
                                                            .istokWeb(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                    options: CarouselOptions(
                                                      height: 0,
                                                      initialPage:
                                                          _isKilograms ? 1 : 0,
                                                      onPageChanged:
                                                          (index, reason) {
                                                        setState(() {
                                                          _currentAction = Action
                                                              .changeWeightUnit;
                                                          _isKilograms =
                                                              index == 1;
                                                        });
                                                      },
                                                      enableInfiniteScroll:
                                                          false,
                                                      viewportFraction: 0.4,
                                                      enlargeCenterPage: true,
                                                      aspectRatio: 2,
                                                      pageSnapping: true,
                                                      scrollDirection:
                                                          Axis.vertical,
                                                    ),
                                                  ),
                                                ),
                                                const Positioned.fill(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Divider(
                                                        color: Colors.black,
                                                      ),
                                                      Divider(
                                                        color: Colors.black,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
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
                                initialDate:
                                    _date != null ? _date! : DateTime.now(),
                                firstDate: DateTime(1),
                                lastDate: DateTime.now(),
                              );

                              if (date == null) {
                                return;
                              }

                              setState(() {
                                _date = date;
                              });
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFFE1E1E1),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                ),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Builder(
                                builder: (context) {
                                  final formatter =
                                      DateFormat("dd / MM / yyyy");

                                  String result;

                                  if (_date != null) {
                                    result = formatter.format(_date!);
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
                                initialTime:
                                    _time != null ? _time! : TimeOfDay.now(),
                              );
                              if (time == null) {
                                return;
                              }

                              setState(() {
                                _time = time;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE1E1E1),
                                borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                              child: Builder(
                                builder: (context) {
                                  final formatter = DateFormat("hh : mm a");

                                  String result;

                                  if (_time != null) {
                                    result = formatter.format(
                                      DateTime.now().copyWith(
                                        hour: _time!.hour,
                                        minute: _time!.minute,
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
          Builder(builder: (context) {
            if (widget._existing == null) {
              return const SizedBox(
                height: 50,
              );
            }

            return Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
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
                                await widget._db.delete("BMIRecord",
                                    where: "id = ?",
                                    whereArgs: [widget._existing!.id]);

                                if ((await User.currentUser).webId != null) {
                                  try {
                                    await MonitoringAPI.syncBmiRecords();

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          duration:
                                              Duration(milliseconds: 1000),
                                          content: Text('Synced BMI records'),
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
                                              'Failed to sync BMI records'),
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
                ),
              ],
            );
          }),
          Center(
            child: SizedBox(
              width: 150,
              child: TextButton(
                onPressed: () async {
                  if (_heightController.text.isEmpty ||
                      _weightController.text.isEmpty ||
                      _date == null ||
                      _time == null) {
                    await ScaffoldMessenger.of(context)
                        .showSnackBar(
                          const SnackBar(
                            duration: Duration(milliseconds: 300),
                            content: Text('Incomplete Form'),
                          ),
                        )
                        .closed;

                    return;
                  }

                  final date = _date!.copyWith(
                    hour: _time!.hour,
                    minute: _time!.minute,
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
                        final current = widget._existing!.createdAt;
                        _time = TimeOfDay(
                          hour: current.hour,
                          minute: current.minute,
                        );
                      } else {
                        _time = null;
                      }
                    });

                    return;
                  }

                  final weightInKilograms = _isKilograms
                      ? double.parse(_weightController.text)
                      : poundsToKilograms(double.parse(_weightController.text));

                  final heightInCentimeters = _isCentimeter
                      ? double.parse(_heightController.text)
                      : inchesToCentimeters(
                          double.parse(_heightController.text));

                  if (widget._existing == null) {
                    await widget._db.rawInsert(
                        "INSERT INTO BMIRecord (height, notes, weight, created_at) VALUES (?, ?, ?, ?)",
                        [
                          heightInCentimeters.toStringAsFixed(2),
                          "",
                          weightInKilograms.toStringAsFixed(2),
                          date.toIso8601String(),
                        ]);
                  } else {
                    await widget._db.rawUpdate(
                      "UPDATE BMIRecord SET height = ?, notes = ?, weight = ?, created_at = ? WHERE id = ?",
                      [
                        heightInCentimeters.toStringAsFixed(2),
                        "",
                        weightInKilograms.toStringAsFixed(2),
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

                  if ((await User.currentUser).webId != null) {
                    await MonitoringAPI.syncBmiRecords().then((_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            duration: Duration(milliseconds: 1000),
                            content: Text('Synced BMI records'),
                          ),
                        );
                      }
                    }).catchError((_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            duration: Duration(milliseconds: 1000),
                            content: Text('Failed to sync BMI records'),
                          ),
                        );
                      }
                    });
                  }

                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(fgColor),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  overlayColor: WidgetStateProperty.all(
                    Colors.white.withOpacity(0.5),
                  ),
                ),
                child: Text(
                  "Submit",
                  style: GoogleFonts.istokWeb(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
