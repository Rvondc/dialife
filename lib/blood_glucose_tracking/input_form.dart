import 'package:auto_size_text/auto_size_text.dart';
import 'package:dialife/blood_glucose_tracking/entities.dart';
import 'package:dialife/user.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GlucoseRecordInputForm extends StatelessWidget {
  final User user;

  final GlucoseRecord? existing;

  const GlucoseRecordInputForm({
    super.key,
    required this.user,
    required this.existing,
  });

  @override
  Widget build(BuildContext context) {
    return _GlucoseRecordInputFormInternalScaffold(existing: existing);
  }
}

class _GlucoseRecordInputFormInternalScaffold extends StatelessWidget {
  final GlucoseRecord? existing;

  const _GlucoseRecordInputFormInternalScaffold({
    super.key,
    required this.existing,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(title: const Text("Glucose Input")),
      body: _GlucoseRecordInputFormInternal(existing: existing),
    );
  }
}

class _GlucoseRecordInputFormInternal extends StatelessWidget {
  final GlucoseRecord? existing;

  const _GlucoseRecordInputFormInternal({
    super.key,
    required this.existing,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.only(
            top: 20,
            left: 10,
            right: 10,
          ),
          width: constraints.maxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "User Profile",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.4),
                  fontSize: 24,
                ),
              ),
              Text(
                "Jane Doe",
                style: TextStyle(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomDatePicker(
                    existing: existing,
                    constraints: constraints,
                  ),
                  const SizedBox(width: 10),
                  GlucoseValueInput(existing: existing),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomTimePicker(
                    existing: existing,
                    constraints: constraints,
                  ),
                  const SizedBox(width: 25),
                  TextButton(
                    onPressed: () {},
                    child: const Text("Submit"),
                  ),
                  const SizedBox(width: 25),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class GlucoseValueInput extends StatelessWidget {
  final GlucoseRecord? existing;

  const GlucoseValueInput({
    super.key,
    required this.existing,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 48,
        child: Material(
          elevation: 5,
          borderRadius: BorderRadius.circular(8),
          child: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
                gapPadding: 0,
              ),
              prefixIcon: const Icon(
                Icons.bloodtype_outlined,
                color: Colors.red,
                size: 32,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomDatePicker extends StatelessWidget {
  final BoxConstraints constraints;

  const CustomDatePicker({
    super.key,
    required this.existing,
    required this.constraints,
  });

  final GlucoseRecord? existing;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          showDatePicker(
            context: context,
            firstDate: DateTime.fromMillisecondsSinceEpoch(0),
            initialDate: DateTime.now(),
            lastDate: DateTime.now(),
          );
        },
        child: Ink(
          padding: const EdgeInsets.all(4),
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 0.2,
                blurRadius: 3,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.calendar_month_outlined,
                size: 32,
                color: Colors.black.withOpacity(0.6),
              ),
              const SizedBox(width: 5),
              SizedBox(
                width: (constraints.maxWidth / 2) - 60,
                child: AutoSizeText(
                  existing != null
                      ? DateFormat.EEEE().format(existing!.bloodTestDate)
                      : "DD/MM/YYYY",
                  maxLines: 1,
                  style: existing != null
                      ? null
                      : TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.black.withOpacity(0.6),
                        ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTimePicker extends StatelessWidget {
  final BoxConstraints constraints;

  const CustomTimePicker({
    super.key,
    required this.existing,
    required this.constraints,
  });

  final GlucoseRecord? existing;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
        },
        child: Ink(
          padding: const EdgeInsets.all(4),
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 0.2,
                blurRadius: 3,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.schedule,
                size: 32,
                color: Colors.black.withOpacity(0.6),
              ),
              const SizedBox(width: 5),
              SizedBox(
                width: (constraints.maxWidth / 2) - 60,
                child: AutoSizeText(
                  existing != null
                      ? DateFormat.EEEE().format(existing!.bloodTestDate)
                      : "HH:MM",
                  maxLines: 1,
                  style: existing != null
                      ? null
                      : TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.black.withOpacity(0.6),
                        ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
