import 'package:dialife/blood_glucose_tracking/entities.dart';
import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:dialife/blood_glucose_tracking/utils.dart';
import 'package:dialife/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sqflite/sqflite.dart';

class GlucoseRecordEditor extends StatelessWidget {
  const GlucoseRecordEditor({super.key});

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
              future: data.query("GlucoseRecord"),
              builder: (context, data) {
                // final parsedData = GlucoseRecord.fromListOfMaps(data);
                final parsedData = GlucoseRecord.mock(
                  count: 50,
                  daySpan: 365,
                  a1cInDay: true,
                );

                parsedData
                    .sort((a, b) => a.bloodTestDate.compareTo(b.bloodTestDate));

                return _GlucoseRecordEditorInternalScaffold(
                    records: parsedData);
              },
            );
          },
        );
      },
    );
  }
}

class _GlucoseRecordEditorInternalScaffold extends StatefulWidget {
  final List<GlucoseRecord> records;

  const _GlucoseRecordEditorInternalScaffold({
    super.key,
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
  final List<GlucoseRecord> records;
  final bool isMmolPerLiter;

  const _GlucoseRecordEditorInternal({
    super.key,
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
              confirmDismiss: (direction) async {
                final result = ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 1, milliseconds: 500),
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
              key: ValueKey(index),
              onDismissed: (direction) async {
                changed = true;
                // TODO: Delete record in database
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
            ),
          );
        },
        itemCount: widget.records.length,
      ),
    );
  }
}
