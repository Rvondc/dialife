import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:dialife/blood_glucose_tracking/utils.dart';
import 'package:dialife/nutrition_log/entities.dart';
import 'package:dialife/nutrition_log/no_data.dart';
import 'package:dialife/nutrition_log/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

class NutritionLog extends StatefulWidget {
  final Database db;
  const NutritionLog({
    super.key,
    required this.db,
  });

  @override
  State<NutritionLog> createState() => _NutritionLogState();
}

class _NutritionLogState extends State<NutritionLog> {
  @override
  Widget build(BuildContext context) {
    reset() {
      setState(() {});
    }

    return waitForFuture(
      loading: const Scaffold(
        body: SpinKitCircle(color: fgColor),
      ),
      future: Future.wait(
        [
          widget.db.query("NutritionRecord"),
          widget.db.query("WaterRecord"),
        ],
      ),
      builder: (context, data) {
        final parsedNutritionRecordData =
            NutritionRecord.fromListOfMaps(data[0]);

        final waterRecords = WaterRecord.fromListOfMaps(data[1]);

        parsedNutritionRecordData
            .sort((a, b) => a.createdAt.compareTo(b.createdAt));

        return _NutritionLogInternalScaffold(
          reset: reset,
          nutritionRecords: parsedNutritionRecordData,
          waterRecords: waterRecords,
          db: widget.db,
        );
      },
    );
  }
}

class _NutritionLogInternalScaffold extends StatelessWidget {
  final List<NutritionRecord> nutritionRecords;
  final List<WaterRecord> waterRecords;
  final Database db;
  final void Function() reset;

  const _NutritionLogInternalScaffold({
    required this.db,
    required this.reset,
    required this.nutritionRecords,
    required this.waterRecords,
  });

  @override
  Widget build(BuildContext context) {
    if (nutritionRecords.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(title: const Text("Glucose")),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: NutritionLogNoData(
              db: db,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text("Nutrition Log"),
        actions: [
          IconButton(
            onPressed: () async {
              await FilePicker.platform.clearTemporaryFiles();
              final directory = await FilePicker.platform.getDirectoryPath();
              if (!await Permission.storage.status.isGranted) {
                await Permission.storage.request();
              }

              if (directory == null) {
                return;
              }

              final path = Directory(directory);
              final file = File(join(path.path, "nutrition_log.dialife.csv"));

              if (await file.exists()) {
                await file.delete();
              }

              try {
                for (var record in nutritionRecords) {
                  await file.writeAsString("${record.toCSVRow()}\n",
                      mode: FileMode.writeOnlyAppend);
                }

                await file.create();
              } catch (e) {
                // TODO: Handle failure
                rethrow;
              }
            },
            icon: const Icon(
              Symbols.export_notes_rounded,
              color: Colors.black,
              size: 32,
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: fgColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () async {
          await Navigator.of(context)
              .pushNamed("/nutrition-log/input", arguments: {
            "db": db,
          });

          reset();
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: _NutritionLogInternal(
            reset: reset,
            db: db,
            nutritionRecords: nutritionRecords,
            waterRecords: waterRecords,
          ),
        ),
      ),
    );
  }
}

const proteinColor = Color(0xFF67E88B);
const carbsColor = Color(0xFFE6E959);
const fatsColor = Color(0xFFE89D67);
const glassesColor = Color(0xFF67BAE8);

class _NutritionLogInternal extends StatefulWidget {
  final List<NutritionRecord> nutritionRecords;
  final List<WaterRecord> waterRecords;
  final Database db;
  final void Function() reset;

  const _NutritionLogInternal({
    required this.reset,
    required this.db,
    required this.waterRecords,
    required this.nutritionRecords,
  });

  @override
  State<_NutritionLogInternal> createState() => _NutritionLogInternalState();
}

class _NutritionLogInternalState extends State<_NutritionLogInternal> {
  final _waterController = TextEditingController();

  DateTime _waterTaken = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final nutritionRecordByDays =
        dayConsolidateNutritionRecord(widget.nutritionRecords);
    final nutritionRecordDays =
        validDaysNutritionRecord(widget.nutritionRecords);
    final waterRecordByDays = dayConsolidateWaterRecord(widget.waterRecords);
    final waterRecordDays = validDaysWaterRecord(widget.waterRecords);

    int glassesDrank;

    if (waterRecordDays.isEmpty) {
      glassesDrank = 0;
    } else {
      glassesDrank =
          waterRecordByDays[waterRecordDays.last]!.map((e) => e.glasses).sum;
    }

    // final latestRecordProtein = recordByDays[recordDays.last]!.fold(
    //   0.0,
    //   (previousValue, element) => previousValue + 0,
    // );

    // final latestRecordFats = recordByDays[recordDays.last]!.fold(
    //   0.0,
    //   (previousValue, element) => previousValue + 0,
    // );

    // final latestRecordCarbs = recordByDays[recordDays.last]!.fold(
    //   0.0,
    //   (previousValue, element) => previousValue + 0,
    // );

    // final latestRecordGlasses = recordByDays[recordDays.last]!.fold(
    //   0,
    //   (previousValue, element) => 0,
    // );

    // final recordSum =
    //     latestRecordProtein + latestRecordCarbs + latestRecordFats;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(
            left: 10,
            right: 10,
            bottom: 15,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          width: double.infinity,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "Water Intake",
                          style: GoogleFonts.montserrat(
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          () {
                            final formatter = DateFormat("dd / MM / yyyy");

                            if (waterRecordDays.isEmpty) {
                              return "No Records";
                            }

                            return formatter.format(waterRecordDays.last);
                          }(),
                          style: GoogleFonts.montserrat(
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Image.asset(
                          "assets/water.png",
                          // width: 150,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: glassesDrank.toString(),
                                    style: GoogleFonts.istokWeb(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  TextSpan(
                                    text: glassesDrank > 1
                                        ? " glasses"
                                        : " glass",
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                            IconButton(
                              onPressed: () async {
                                _waterController.text = "";

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
                                                "Glasses of Water",
                                                style: GoogleFonts.istokWeb(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 24,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              TextField(
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly
                                                ],
                                                style: GoogleFonts.istokWeb(),
                                                decoration: InputDecoration(
                                                  hintText: "(E.g. 1)",
                                                  isDense: true,
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                ),
                                                controller: _waterController,
                                              ),
                                              const SizedBox(height: 32),
                                              Row(
                                                children: [
                                                  Text(
                                                    DateFormat("hh:mm a")
                                                        .format(_waterTaken),
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      letterSpacing: 2.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const Expanded(
                                                      child: SizedBox()),
                                                  TextButton(
                                                    onPressed: () async {
                                                      if (_waterController
                                                          .text.isEmpty) {
                                                        return;
                                                      }

                                                      widget.db.rawInsert(
                                                        "INSERT INTO WaterRecord (glasses, time) VALUES (?, ?)",
                                                        [
                                                          _waterController.text,
                                                          _waterTaken
                                                              .toIso8601String(),
                                                        ],
                                                      );

                                                      Navigator.of(context)
                                                          .pop();

                                                      widget.reset();
                                                    },
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all(fgColor),
                                                    ),
                                                    child: Text(
                                                      "Save",
                                                      style:
                                                          GoogleFonts.istokWeb(
                                                              color:
                                                                  Colors.white),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              icon: IntrinsicWidth(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: fgColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.add,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      Icon(
                                        Symbols.glass_cup_rounded,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                final time = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now());

                                if (time == null) return;

                                setState(() {
                                  _waterTaken = DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day,
                                    time.hour,
                                    time.minute,
                                  );
                                });
                              },
                              icon: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: fgColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Symbols.nest_clock_farsight_analog,
                                      size: 32,
                                      color: Colors.white,
                                    ),
                                    const Expanded(child: SizedBox()),
                                    Text(
                                      DateFormat("hh:mm a").format(_waterTaken),
                                      style: GoogleFonts.montserrat(
                                        letterSpacing: 2.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ...nutritionRecordByDays[nutritionRecordDays.last]!
                      .map((record) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Meal Records",
                              style: GoogleFonts.istokWeb(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Expanded(child: SizedBox()),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                () {
                                  final formatter =
                                      DateFormat("dd / MM / yyyy");

                                  if (nutritionRecordDays.isEmpty) {
                                    return "No Records";
                                  }

                                  return formatter
                                      .format(nutritionRecordDays.last);
                                }(),
                                style: GoogleFonts.montserrat(
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        Text(
                          "${record.dayDescription} at ${DateFormat("h:mm a").format(record.createdAt)}",
                          style:
                              GoogleFonts.istokWeb(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          children: record.foods.map((food) {
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
                                child: Text(
                                  food,
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  }).toList(),
                  // Row(
                  //   children: [
                  //     Container(
                  //       width: 30,
                  //       height: 30,
                  //       decoration: BoxDecoration(
                  //         color: proteinColor,
                  //         borderRadius: BorderRadius.circular(20),
                  //       ),
                  //     ),
                  //     const SizedBox(width: 8),
                  //     Text(
                  //       "Protein",
                  //       style: GoogleFonts.montserrat(
                  //         letterSpacing: 2,
                  //         fontSize: 20,
                  //       ),
                  //     ),
                  //     const Expanded(child: SizedBox()),
                  //     Text(
                  //       "${latestRecordProtein.toStringAsFixed(2)}g",
                  //       style: GoogleFonts.montserrat(
                  //         fontSize: 20,
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // Divider(color: Colors.grey.shade200),
                  // Row(
                  //   children: [
                  //     Container(
                  //       width: 30,
                  //       height: 30,
                  //       decoration: BoxDecoration(
                  //         color: carbsColor,
                  //         borderRadius: BorderRadius.circular(20),
                  //       ),
                  //     ),
                  //     const SizedBox(width: 8),
                  //     Text(
                  //       "Carbohydrates",
                  //       style: GoogleFonts.montserrat(
                  //         letterSpacing: 2,
                  //         fontSize: 20,
                  //       ),
                  //     ),
                  //     const Expanded(child: SizedBox()),
                  //     Text(
                  //       "${latestRecordCarbs.toStringAsFixed(2)}g",
                  //       style: GoogleFonts.montserrat(
                  //         fontSize: 20,
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // Divider(color: Colors.grey.shade200),
                  // Row(
                  //   children: [
                  //     Container(
                  //       width: 30,
                  //       height: 30,
                  //       decoration: BoxDecoration(
                  //         color: fatsColor,
                  //         borderRadius: BorderRadius.circular(20),
                  //       ),
                  //     ),
                  //     const SizedBox(width: 8),
                  //     Text(
                  //       "Fats",
                  //       style: GoogleFonts.montserrat(
                  //         letterSpacing: 2,
                  //         fontSize: 20,
                  //       ),
                  //     ),
                  //     const Expanded(child: SizedBox()),
                  //     Text(
                  //       "${latestRecordFats.toStringAsFixed(2)}g",
                  //       style: GoogleFonts.montserrat(
                  //         fontSize: 20,
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // Divider(color: Colors.grey.shade200),
                  // Row(
                  //   children: [
                  //     Container(
                  //       width: 30,
                  //       height: 30,
                  //       decoration: BoxDecoration(
                  //         color: glassesColor,
                  //         borderRadius: BorderRadius.circular(20),
                  //       ),
                  //     ),
                  //     const SizedBox(width: 8),
                  //     Text(
                  //       "Water",
                  //       style: GoogleFonts.montserrat(
                  //         letterSpacing: 2,
                  //         fontSize: 20,
                  //       ),
                  //     ),
                  //     const Expanded(child: SizedBox()),
                  //     Text(
                  //       "$latestRecordGlasses glasses",
                  //       style: GoogleFonts.montserrat(
                  //         fontSize: 20,
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // Divider(color: Colors.grey.shade200),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        TextButton(
          onPressed: () async {
            await Navigator.of(context).pushNamed(
              "/nutrition-log/editor",
              arguments: {"db": widget.db},
            );

            widget.reset();
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
            "View History",
            style: GoogleFonts.istokWeb(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
