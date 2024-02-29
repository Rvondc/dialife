import 'dart:io';

import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:dialife/blood_glucose_tracking/utils.dart';
import 'package:dialife/nutrition_log/entities.dart';
import 'package:dialife/nutrition_log/no_data.dart';
import 'package:dialife/nutrition_log/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:multi_circular_slider/multi_circular_slider.dart';
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
      loading: const SpinKitCircle(color: fgColor),
      future: Future.wait(
        [widget.db.query("NutritionRecord")],
      ),
      builder: (context, data) {
        final parsedNutritionRecordData =
            NutritionRecord.fromListOfMaps(data[0]);
        // final parsedNutritionRecordData = NutritionRecord.mock(
        //   count: 20,
        //   daySpan: 30,
        // );

        parsedNutritionRecordData
            .sort((a, b) => a.createdAt.compareTo(b.createdAt));

        return _NutritionLogInternalScaffold(
          reset: reset,
          records: parsedNutritionRecordData,
          db: widget.db,
        );
      },
    );
  }
}

class _NutritionLogInternalScaffold extends StatelessWidget {
  final List<NutritionRecord> records;
  final Database db;
  final void Function() reset;

  const _NutritionLogInternalScaffold({
    required this.db,
    required this.reset,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
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
                for (var record in records) {
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
            records: records,
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

class _NutritionLogInternal extends StatelessWidget {
  final List<NutritionRecord> records;
  final Database db;
  final void Function() reset;

  const _NutritionLogInternal({
    required this.reset,
    required this.db,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    final recordByDays = dayConsolidateNutritionRecord(records);
    final recordDays = validDaysNutritionRecord(records);

    final latestRecordProtein = recordByDays[recordDays.last]!.fold(
      0.0,
      (previousValue, element) => previousValue + element.proteinInGrams,
    );

    final latestRecordFats = recordByDays[recordDays.last]!.fold(
      0.0,
      (previousValue, element) => previousValue + element.fatsInGrams,
    );

    final latestRecordCarbs = recordByDays[recordDays.last]!.fold(
      0.0,
      (previousValue, element) => previousValue + element.carbohydratesInGrams,
    );

    final latestRecordGlasses = recordByDays[recordDays.last]!.fold(
      0,
      (previousValue, element) => previousValue + element.glassesOfWater,
    );

    final recordSum =
        latestRecordProtein + latestRecordCarbs + latestRecordFats;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(
            left: 10,
            right: 10,
            top: 30,
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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: proteinColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            width: 15,
                            height: 15,
                          ),
                          const SizedBox(width: 5),
                          const Text("Protein"),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: carbsColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            width: 15,
                            height: 15,
                          ),
                          const SizedBox(width: 5),
                          const Text("Carbohydrates"),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: fatsColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            width: 15,
                            height: 15,
                          ),
                          const SizedBox(width: 5),
                          const Text("Fats"),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                MultiCircularSlider(
                  values: [
                    latestRecordProtein / recordSum,
                    latestRecordCarbs / recordSum,
                    latestRecordFats / recordSum,
                  ],
                  colors: const [proteinColor, carbsColor, fatsColor],
                  size: 250,
                  innerWidget: Material(
                    borderRadius: BorderRadius.circular(100),
                    elevation: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        // color: Colors.grey.shade200,
                      ),
                      child: Image.asset("assets/nutrition_log.png"),
                    ),
                  ),
                  showTotalPercentage: false,
                  progressBarType: MultiCircularSliderType.circular,
                ),
              ],
            ),
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
                          "SUMMARY",
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

                            return formatter.format(recordDays.last);
                          }(),
                          style: GoogleFonts.montserrat(
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: proteinColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Protein",
                        style: GoogleFonts.montserrat(
                          letterSpacing: 2,
                          fontSize: 20,
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      Text(
                        "${latestRecordProtein.toStringAsFixed(2)}g",
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Colors.grey.shade200),
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: carbsColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Carbohydrates",
                        style: GoogleFonts.montserrat(
                          letterSpacing: 2,
                          fontSize: 20,
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      Text(
                        "${latestRecordCarbs.toStringAsFixed(2)}g",
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Colors.grey.shade200),
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: fatsColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Fats",
                        style: GoogleFonts.montserrat(
                          letterSpacing: 2,
                          fontSize: 20,
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      Text(
                        "${latestRecordFats.toStringAsFixed(2)}g",
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Colors.grey.shade200),
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: glassesColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Water",
                        style: GoogleFonts.montserrat(
                          letterSpacing: 2,
                          fontSize: 20,
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      Text(
                        "$latestRecordGlasses glasses",
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Colors.grey.shade200),
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
              arguments: {"db": db},
            );

            reset();
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
