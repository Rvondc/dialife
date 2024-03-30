import 'package:collection/collection.dart';
import 'package:dialife/api/api.dart';
import 'package:dialife/api/entities.dart';
import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:dialife/nutrition_log/entities.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sqflite/sqflite.dart';

class NutritionLogInput extends StatelessWidget {
  final Database db;
  final DateTime? now;
  final NutritionRecord? existing;

  const NutritionLogInput({
    super.key,
    required this.db,
    required this.now,
    required this.existing,
  });

  @override
  Widget build(BuildContext context) {
    return _NutritionLogInternalScaffold(
      db: db,
      now: now,
      existing: existing,
    );
  }
}

class _NutritionLogInternalScaffold extends StatelessWidget {
  final Database db;
  final DateTime? now;
  final NutritionRecord? existing;

  const _NutritionLogInternalScaffold({
    required this.existing,
    required this.now,
    required this.db,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(title: const Text("Nutrition Log Form")),
      body: SafeArea(
        child: SingleChildScrollView(
          child: _NutritionLogInternal(
            db: db,
            now: now,
            existing: existing,
          ),
        ),
      ),
    );
  }
}

class _NutritionLogInternal extends StatefulWidget {
  final Database db;
  final DateTime? now;
  final NutritionRecord? existing;

  const _NutritionLogInternal({
    required this.existing,
    required this.now,
    required this.db,
  });

  @override
  State<_NutritionLogInternal> createState() => _NutritionLogInternalState();
}

class _NutritionLogInternalState extends State<_NutritionLogInternal> {
  // final _proteinController = TextEditingController();
  // final _carbsController = TextEditingController();
  // final _fatsController = TextEditingController();
  // final _waterController = TextEditingController();
  final _notesController = TextEditingController();
  final ValueNotifier<DateTime?> _date = ValueNotifier(null);
  final ValueNotifier<TimeOfDay?> _time = ValueNotifier(null);

  final _dropDownController = SingleValueDropDownController();
  final _foodController = TextEditingController();
  List<String> _foods = [];

  @override
  void initState() {
    super.initState();

    _date.value = widget.now;
    if (widget.existing == null) {
      return;
    }

    // _proteinController.text =
    //     widget.existing!.proteinInGrams.toStringAsFixed(1);
    // _carbsController.text =
    //     widget.existing!.carbohydratesInGrams.toStringAsFixed(1);
    // _fatsController.text = widget.existing!.fatsInGrams.toStringAsFixed(1);
    // _waterController.text = widget.existing!.glassesOfWater.toString();
    _notesController.text = widget.existing!.notes;
    _foods = widget.existing!.foods;
    _dropDownController.setDropDown(
      DropDownValueModel(
        name: widget.existing!.dayDescription,
        value: widget.existing!.dayDescription,
      ),
    );

    _date.value = widget.existing!.createdAt;
    _time.value = TimeOfDay(
      hour: widget.existing!.createdAt.hour,
      minute: widget.existing!.createdAt.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
        top: 30,
      ),
      child: Column(
        children: [
          Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    "NUTRITION LOG",
                    style: GoogleFonts.istokWeb(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Image.asset(
                    "assets/nutrition_log.png",
                    width: 280,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              width: double.infinity,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 2,
                      left: 10,
                      right: 10,
                      bottom: 10,
                    ),
                    child: DropDownTextField(
                      onChanged: (value) {
                        setState(() {});
                      },
                      textFieldDecoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.timelapse),
                        labelText: 'Meal Time',
                        fillColor: Colors.grey.shade200,
                        filled: true,
                      ),
                      controller: _dropDownController,
                      dropDownList: const [
                        DropDownValueModel(
                          name: "Breakfast",
                          value: "Breakfast",
                        ),
                        DropDownValueModel(
                          name: "Morning Snacks",
                          value: "Morning Snacks",
                        ),
                        DropDownValueModel(
                          name: "Lunch",
                          value: "Lunch",
                        ),
                        DropDownValueModel(
                          name: "Afternoon Snacks",
                          value: "Afternoon Snacks",
                        ),
                        DropDownValueModel(
                          name: "Dinner",
                          value: "Dinner",
                        ),
                        DropDownValueModel(
                          name: "Evening Snacks",
                          value: "Evening Snacks",
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "Food Ate At: ${_dropDownController.dropDownValue == null ? "(Pick a Meal Time)" : _dropDownController.dropDownValue!.value}",
                    style: GoogleFonts.istokWeb(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        direction: Axis.horizontal,
                        children: _foods.mapIndexed((index, food) {
                          return IntrinsicWidth(
                            child: Container(
                              margin:
                                  const EdgeInsets.only(right: 8, bottom: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: fgColor,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 8,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    food,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _foods.removeAt(index);
                                      });
                                    },
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: FloatingActionButton(
                          onPressed: () async {
                            _foodController.text = "";

                            await showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: IntrinsicHeight(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Food",
                                            style: GoogleFonts.istokWeb(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 24,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          TextField(
                                            style: GoogleFonts.istokWeb(),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp("[0-9a-zA-Z]"))
                                            ],
                                            decoration: InputDecoration(
                                              hintText: "(E.g. 1 cup of rice)",
                                              isDense: true,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            controller: _foodController,
                                          ),
                                          const SizedBox(height: 32),
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: TextButton(
                                              onPressed: () async {
                                                if (_foodController
                                                    .text.isEmpty) {
                                                  Navigator.of(context).pop();
                                                  return;
                                                }

                                                setState(() {
                                                  _foods = [
                                                    ..._foods,
                                                    _foodController.text
                                                  ];
                                                });

                                                Navigator.of(context).pop();
                                              },
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        fgColor),
                                              ),
                                              child: Text(
                                                "Save",
                                                style: GoogleFonts.istokWeb(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: fgColor,
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(
                  //     horizontal: 10,
                  //   ),
                  //   child: Row(
                  //     children: [
                  //       Expanded(
                  //         child: TextField(
                  //           controller: _waterController,
                  //           inputFormatters: [
                  //             FilteringTextInputFormatter.digitsOnly
                  //           ],
                  //           maxLines: 1,
                  //           keyboardType: TextInputType.number,
                  //           decoration: InputDecoration(
                  //             contentPadding: EdgeInsets.zero,
                  //             border: OutlineInputBorder(
                  //                 borderRadius: BorderRadius.circular(8)),
                  //             prefixIcon: const Icon(Icons.water_drop_outlined),
                  //             labelText: 'Water (glasses)',
                  //             fillColor: Colors.grey.shade200,
                  //             filled: true,
                  //           ),
                  //         ),
                  //       ),
                  //       const SizedBox(width: 10),
                  //       Expanded(
                  //         child: TextField(
                  //           controller: _carbsController,
                  //           keyboardType: TextInputType.number,
                  //           inputFormatters: [
                  //             FilteringTextInputFormatter.digitsOnly
                  //           ],
                  //           maxLines: 1,
                  //           decoration: InputDecoration(
                  //             contentPadding: EdgeInsets.zero,
                  //             border: OutlineInputBorder(
                  //                 borderRadius: BorderRadius.circular(8)),
                  //             prefixIcon: const Icon(
                  //               Icons.breakfast_dining_outlined,
                  //             ),
                  //             labelText: 'Carbs (grams)',
                  //             fillColor: Colors.grey.shade200,
                  //             filled: true,
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
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
                        "INGREDIENTS",
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

                  if (_dropDownController.dropDownValue == null) {
                    await error();
                    return;
                  }

                  if (widget.existing == null) {
                    await widget.db.rawInsert(
                      "INSERT INTO NutritionRecord (day_description, foods_csv, notes, created_at) VALUES (?, ?, ?, ?)",
                      [
                        _dropDownController.dropDownValue!.value,
                        _foods.reduce((value, element) => "$value,$element"),
                        _notesController.text,
                        date.toIso8601String(),
                      ],
                    );
                  } else {
                    await widget.db.rawUpdate(
                      "UPDATE NutritionRecord SET day_description = ?, foods_csv = ?, notes = ?, created_at = ? WHERE id = ?",
                      [
                        _dropDownController.dropDownValue!.value,
                        _foods.reduce((value, element) => "$value,$element"),
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

                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }

                  MonitoringAPI.recordSyncAll(
                    await APIPatientRecordUploadable.normalizedRecords(),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(fgColor),
                  overlayColor: MaterialStateProperty.all(
                    Colors.white.withOpacity(0.3),
                  ),
                  shape: MaterialStateProperty.all(
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
                                      await widget.db.delete("NutritionRecord",
                                          where: "id = ?",
                                          whereArgs: [widget.existing!.id]);

                                      MonitoringAPI.recordSyncAll(
                                        await APIPatientRecordUploadable
                                            .normalizedRecords(),
                                      );

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
