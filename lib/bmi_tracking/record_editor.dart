import 'package:dialife/api/api.dart';
import 'package:dialife/api/entities.dart';
import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:dialife/blood_glucose_tracking/utils.dart';
import 'package:dialife/bmi_tracking/bmi_tracking.dart';
import 'package:dialife/bmi_tracking/entities.dart';
import 'package:dialife/main.dart';
import 'package:dialife/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sqflite/sqflite.dart';

class BMIRecordEditor extends StatefulWidget {
  final Database db;
  final User user;

  const BMIRecordEditor({
    super.key,
    required this.db,
    required this.user,
  });

  @override
  State<BMIRecordEditor> createState() => _BMIRecordEditorState();
}

class _BMIRecordEditorState extends State<BMIRecordEditor> {
  @override
  Widget build(BuildContext context) {
    const loading = Scaffold(
      body: SpinKitCircle(color: fgColor),
    );

    reset() {
      setState(() {});
    }

    return waitForFuture(
      future: getDatabasesPath(),
      loading: loading,
      builder: (context, data) {
        return waitForFuture(
          loading: loading,
          future: initAppDatabase(data),
          builder: (context, data) {
            return waitForFuture(
              loading: loading,
              future: data.query("BMIRecord"),
              builder: (context, data) {
                final parsedData = BMIRecord.fromListOfMaps(data);
                // final parsedData = BMIRecord.mock(400, 365);
                parsedData.sort((a, b) => a.createdAt.compareTo(b.createdAt));

                return _BMIRecordEditorInternalScaffold(
                  records: parsedData,
                  reset: reset,
                  db: widget.db,
                  user: widget.user,
                );
              },
            );
          },
        );
      },
    );
  }
}

class _BMIRecordEditorInternalScaffold extends StatelessWidget {
  final List<BMIRecord> records;
  final void Function() reset;
  final Database db;
  final User user;

  const _BMIRecordEditorInternalScaffold({
    required this.records,
    required this.reset,
    required this.db,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {}

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(title: const Text("BMI Records")),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 10,
              right: 10,
              top: 0,
              bottom: 0,
            ),
            child: _BMIRecordEditorInternal(
              records: records,
              reset: reset,
              db: db,
              user: user,
            ),
          ),
        ),
      ),
    );
  }
}

class _BMIRecordEditorInternal extends StatefulWidget {
  final List<BMIRecord> records;
  final void Function() reset;
  final Database db;
  final User user;

  const _BMIRecordEditorInternal({
    required this.user,
    required this.db,
    required this.reset,
    required this.records,
  });

  @override
  State<_BMIRecordEditorInternal> createState() =>
      _BMIRecordEditorInternalState();
}

class _BMIRecordEditorInternalState extends State<_BMIRecordEditorInternal> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return true;
      },
      child: ListView.builder(
        itemBuilder: (context, index) {
          final current = widget.records[index];
          return GestureDetector(
            onTap: () async {
              await Navigator.of(context).pushNamed(
                "/bmi-tracking/input",
                arguments: {
                  "db": widget.db,
                  "user": widget.user,
                  "existing": current,
                },
              );

              widget.reset();
            },
            child: Dismissible(
              key: ValueKey(index),
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

                if (await result.closed == SnackBarClosedReason.action) {
                  return false;
                }

                return true;
              },
              onDismissed: (direction) async {
                await widget.db.delete(
                  "BMIRecord",
                  where: "id = ?",
                  whereArgs: [current.id],
                );

                MonitoringAPI.uploadPatientRecord(
                  await APIPatientRecordUploadable.latestCompiled(),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                child: bmiRecordListTile(
                    current.createdAt, current.notes, current.bmi),
              ),
            ),
          );
        },
        itemCount: widget.records.length,
      ),
    );
  }
}
