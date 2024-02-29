import 'package:dialife/blood_glucose_tracking/entities.dart';
import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:dialife/blood_glucose_tracking/utils.dart';
import 'package:dialife/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sqflite/sqflite.dart';

class GlucoseRecordEditor extends StatefulWidget {
  final Database db;
  final User user;

  const GlucoseRecordEditor({
    super.key,
    required this.user,
    required this.db,
  });

  @override
  State<GlucoseRecordEditor> createState() => _GlucoseRecordEditorState();
}

class _GlucoseRecordEditorState extends State<GlucoseRecordEditor> {
  @override
  Widget build(BuildContext context) {
    const loading = Scaffold(
      body: SpinKitCircle(color: fgColor),
    );

    void reset() {
      setState(() {});
    }

    return waitForFuture(
      loading: loading,
      future: widget.db.query("GlucoseRecord"),
      builder: (context, data) {
        final parsedData = GlucoseRecord.fromListOfMaps(data);
        // final parsedData = GlucoseRecord.mock(
        //   count: 50,
        //   daySpan: 365,
        //   a1cInDay: true,
        // );

        parsedData.sort((a, b) => a.bloodTestDate.compareTo(b.bloodTestDate));

        return _GlucoseRecordEditorInternalScaffold(
          records: parsedData.reversed.toList(),
          user: widget.user,
          reset: reset,
          db: widget.db,
        );
      },
    );
  }
}

class _GlucoseRecordEditorInternalScaffold extends StatefulWidget {
  final Database db;
  final User user;
  final void Function() reset;
  final List<GlucoseRecord> records;

  const _GlucoseRecordEditorInternalScaffold({
    required this.db,
    required this.reset,
    required this.user,
    required this.records,
  });

  @override
  State<_GlucoseRecordEditorInternalScaffold> createState() =>
      _GlucoseRecordEditorInternalScaffoldState();
}

class _GlucoseRecordEditorInternalScaffoldState
    extends State<_GlucoseRecordEditorInternalScaffold> {
  bool _isMmolPerLiter = true;

  @override
  Widget build(BuildContext context) {
    if (widget.records.isEmpty) {
      // TODO:
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text("Glucose Records"),
        actions: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 40,
                child: Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: _isMmolPerLiter,
                    activeColor: fgColor,
                    trackOutlineColor: MaterialStateProperty.all(Colors.grey),
                    onChanged: (onChanged) {
                      setState(() {
                        _isMmolPerLiter = !_isMmolPerLiter;
                      });
                    },
                  ),
                ),
              ),
              Text(
                _isMmolPerLiter ? "mmol/L" : "mg/dL",
                style: const TextStyle(height: 0.1, fontSize: 8),
              ),
            ],
          ),
        ],
      ),
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
            child: _GlucoseRecordEditorInternal(
              db: widget.db,
              user: widget.user,
              reset: widget.reset,
              records: widget.records,
              isMmolPerLiter: _isMmolPerLiter,
            ),
          ),
        ),
      ),
    );
  }
}

class _GlucoseRecordEditorInternal extends StatefulWidget {
  final Database db;
  final User user;
  final void Function() reset;
  final List<GlucoseRecord> records;
  final bool isMmolPerLiter;

  const _GlucoseRecordEditorInternal({
    required this.db,
    required this.reset,
    required this.user,
    required this.records,
    required this.isMmolPerLiter,
  });

  @override
  State<_GlucoseRecordEditorInternal> createState() =>
      __GlucoseRecordEditorInternalState();
}

class __GlucoseRecordEditorInternalState
    extends State<_GlucoseRecordEditorInternal> {
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
                "/blood-glucose-tracking/input",
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
              onDismissed: (direction) async {
                await widget.db.delete(
                  "GlucoseRecord",
                  where: "id = ?",
                  whereArgs: [current.id],
                );
              },
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                child: glucoseRecordListTile(
                    current.bloodTestDate,
                    current.notes,
                    widget.isMmolPerLiter
                        ? current.glucoseLevel
                        : mmolLToMgDL(current.glucoseLevel),
                    widget.isMmolPerLiter
                        ? Units.mmolPerLiter
                        : Units.milligramsPerDeciliter,
                    current.isA1C),
              ),
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
            ),
          );
        },
        itemCount: widget.records.length,
      ),
    );
  }
}
