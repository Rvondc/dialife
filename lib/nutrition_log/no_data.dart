import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class NutritionLogNoData extends StatelessWidget {
  final Database db;

  const NutritionLogNoData({
    required this.db,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
          height: 300,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const AutoSizeText(
                "New to Nutrition Log?",
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 48),
              ),
              const Text("You don't have any data: "),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () async {
                            await FilePicker.platform.clearTemporaryFiles();
                            final fileResult =
                                await FilePicker.platform.pickFiles(
                              allowedExtensions: ["csv"],
                              type: FileType.custom,
                            );

                            if (fileResult == null) {
                              return;
                            }

                            final platformFile = fileResult.files.first;
                            if (platformFile.path == null) {
                              return;
                            }

                            if (platformFile.name !=
                                "nutrition_log.dialife.csv") {
                              // TODO: Error
                              return;
                            }

                            final file = File(platformFile.path!);

                            for (var line in await file.readAsLines()) {
                              final parts = line.split(",");

                              await db.rawInsert(
                                  "INSERT INTO NutritionRecord (id, protein, fat, carbohydrates, water, notes, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)",
                                  [
                                    parts[0].trim(),
                                    parts[1].trim(),
                                    parts[2].trim(),
                                    parts[3].trim(),
                                    parts[4].trim(),
                                    utf8.decode(base64.decode(parts[5].trim())),
                                    parts[6].trim(),
                                  ]);
                            }

                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                          color: fgColor,
                          iconSize: 48,
                          icon: const Icon(Icons.import_export),
                        ),
                      ),
                      const Text("IMPORT"),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () async {
                            await Navigator.of(context).pushNamed(
                              "/nutrition-log/editor",
                              arguments: {
                                "db": db,
                              },
                            );

                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                          color: fgColor,
                          iconSize: 48,
                          icon: const Icon(Icons.add),
                        ),
                      ),
                      const Text("ADD"),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
