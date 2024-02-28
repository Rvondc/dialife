import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:dialife/user.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class BMITrackingNoData extends StatelessWidget {
  final User user;
  final Database db;

  const BMITrackingNoData({
    super.key,
    required this.user,
    required this.db,
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
                "New to BMI Tracker?",
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
                                "bmi_tracking.dialife.csv") {
                              // TODO: Error
                              return;
                            }

                            final file = File(platformFile.path!);

                            for (var line in await file.readAsLines()) {
                              final parts = line.split(",");

                              await db.rawInsert(
                                  "INSERT INTO BMIRecord (id, height, weight, notes, created_at) VALUES (?, ?, ?, ?, ?)",
                                  [
                                    parts[0].trim(),
                                    double.parse(parts[1].trim()) * 100,
                                    double.parse(parts[2].trim()),
                                    utf8.decode(base64.decode(parts[3].trim())),
                                    parts[4].trim(),
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
                              "/bmi-tracking/input",
                              arguments: {
                                "db": db,
                                "user": user,
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
