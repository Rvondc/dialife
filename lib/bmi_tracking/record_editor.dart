import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:dialife/blood_glucose_tracking/utils.dart';
import 'package:dialife/bmi_tracking/bmi_tracking.dart';
import 'package:dialife/bmi_tracking/entities.dart';
import 'package:dialife/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sqflite/sqflite.dart';

class BMIRecordEditor extends StatelessWidget {
  const BMIRecordEditor({super.key});

  @override
  Widget build(BuildContext context) {
    const loading = Scaffold(
      body: SpinKitCircle(color: fgColor),
    );

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

                return _BMIRecordEditorInternalScaffold(records: parsedData);
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

  const _BMIRecordEditorInternalScaffold({
    super.key,
    required this.records,
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
            child: _BMIRecordEditorInternal(records: records),
          ),
        ),
      ),
    );
  }
}

class _BMIRecordEditorInternal extends StatefulWidget {
  final List<BMIRecord> records;

  const _BMIRecordEditorInternal({
    super.key,
    required this.records,
  });

  @override
  State<_BMIRecordEditorInternal> createState() =>
      _BMIRecordEditorInternalState();
}

class _BMIRecordEditorInternalState extends State<_BMIRecordEditorInternal> {
  @override
  Widget build(BuildContext context) {
    bool changed = false;

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(changed);
        return true;
      },
      child: ListView.builder(
        itemBuilder: (context, index) {
          final current = widget.records[index];
          return GestureDetector(
            onTap: () {},
            child: Dismissible(
              key: ValueKey(index),
              onDismissed: (direction) async {
                changed = true;
                // TODO: Delete record in database
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
