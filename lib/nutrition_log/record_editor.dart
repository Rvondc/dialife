import 'package:auto_size_text/auto_size_text.dart';
import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:dialife/blood_glucose_tracking/utils.dart';
import 'package:dialife/nutrition_log/entities.dart';
import 'package:dialife/nutrition_log/nutrition_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class NutritionRecordEditor extends StatefulWidget {
  final Database db;

  const NutritionRecordEditor({
    super.key,
    required this.db,
  });

  @override
  State<NutritionRecordEditor> createState() => _NutritionRecordEditorState();
}

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

class _NutritionEditorInternalScaffold extends StatelessWidget {
  final void Function() reset;
  final List<NutritionRecord> records;
  final Database db;

  const _NutritionEditorInternalScaffold({
    super.key,
    required this.records,
    required this.reset,
    required this.db,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text("Nutrition Records"),
      ),
      body: SafeArea(
        child: _NutritionEditorInternal(
          db: db,
          records: records,
          reset: reset,
        ),
      ),
    );
  }
}

class _NutritionEditorInternal extends StatelessWidget {
  final void Function() reset;
  final List<NutritionRecord> records;
  final Database db;

  const _NutritionEditorInternal({
    super.key,
    required this.reset,
    required this.records,
    required this.db,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: ListView.builder(
        itemCount: records.length,
        itemBuilder: (context, index) {
          final current = records[index];

          return Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Dismissible(
              key: ValueKey(index),
              onDismissed: (direction) async {
                await db.delete(
                  "NutritionRecord",
                  where: "id = ?",
                  whereArgs: [current.id],
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
                        "db": db,
                        "existing": current,
                      },
                    );

                    reset();
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
                    trailing: IntrinsicWidth(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: proteinColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                width: 10,
                                height: 10,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                "${current.proteinInGrams.toStringAsFixed(1)}g",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 7),
                              Container(
                                decoration: BoxDecoration(
                                  color: carbsColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                width: 10,
                                height: 10,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                "${current.carbohydratesInGrams.toStringAsFixed(1)}g",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: fatsColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                width: 10,
                                height: 10,
                              ),
                              Text(
                                "${current.fatsInGrams.toStringAsFixed(1)}g",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 7),
                              Container(
                                decoration: BoxDecoration(
                                  color: glassesColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                width: 10,
                                height: 10,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                "${current.glassesOfWater.toStringAsFixed(1)} gl",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    subtitle: AutoSizeText(
                      "Ingredients: ${current.notes.isEmpty ? "--" : current.notes}",
                      maxLines: 3,
                      overflow: TextOverflow.fade,
                    ),
                    // TODO: Add trailing
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
