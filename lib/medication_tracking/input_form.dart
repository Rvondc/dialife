import 'package:dialife/local_notifications/local_notifications.dart';
import 'package:dialife/medication_tracking/entities.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sqflite/sqflite.dart';

class NewMedicationReminderInputForm extends StatefulWidget {
  final MedicationRecordDetails? _existing;
  final Database _db;
  // final User _user;

  const NewMedicationReminderInputForm({
    super.key,
    required Database db,
    MedicationRecordDetails? existing,
  })  : _db = db,
        _existing = existing;

  @override
  State<NewMedicationReminderInputForm> createState() =>
      _NewMedicationReminderInputFormState();
}

class _NewMedicationReminderInputFormState
    extends State<NewMedicationReminderInputForm> {
  final TextEditingController _medicineNameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final List _days = [
    ["M", false],
    ["T", false],
    ["W", false],
    ["TH", false],
    ["F", false],
    ["SA", false],
    ["SU", false],
  ];

  final List<String> _medicineRoutes = [
    "Inhalation",
    "Intradermal (ID)",
    "Intramuscular (IM)",
    "Intravenous (IV)",
    "Ocular",
    "Oral",
    "Otic",
    "Rectal",
    "Subcutaneous (SC)",
    "Topical",
    "Transdermal",
    "Vaginal",
  ];

  final List<String> _medicineForms = [
    "Capsule",
    "Creams or ointments ",
    "Drops",
    "Inhalers",
    "Injectables",
    "Implants ",
    "Liquid",
    "Patches",
    "Powders",
    "Spray",
    "Suppositories ",
    "Tablet",
  ];
  String medicationRouteDropdownValue = 'Inhalation';
  String medicationFormDropdownValue = "Capsule";

  List _timesPicked = [];

  @override
  void initState() {
    super.initState();
    if (widget._existing == null) {
      return;
    }

    _medicineNameController.text = widget._existing!.medicineName;
    _dosageController.text =
        widget._existing!.medicineDosage.toStringAsFixed(2);
    // _dateController.text =
    //     DateFormat('dd/MM/yyyy').format(widget._existing!.medicationDatetime);

    Future.delayed(
      Duration.zero,
      () async {
        final unparsed = await widget._db.rawQuery(
          "SELECT * FROM MedicationRecordDetails WHERE medication_reminder_record_id = ?",
          [
            widget._existing!.medicationReminderRecordId,
          ],
        );

        final parsed = MedicationRecordDetails.fromListOfMaps(unparsed);
        final duplicates = parsed
            .map((e) => TimeOfDay(
                  hour: e.medicationDatetime.hour,
                  minute: e.medicationDatetime.minute,
                ))
            .toSet()
            .toList();

        final days = parsed
            .map((e) => DateFormat("EE").format(e.medicationDatetime))
            .toSet()
            .toList();

        setState(() {
          _timesPicked = duplicates;
          for (var day in days) {
            switch (day) {
              case "Mon":
                _days[0] = ["M", true];
              case "Tue":
                _days[1] = ["T", true];
              case "Wed":
                _days[2] = ["W", true];
              case "Thu":
                _days[3] = ["TH", true];
              case "Fri":
                _days[4] = ["F", true];
              case "Sat":
                _days[5] = ["S", true];
              case "Sun":
                _days[6] = ["SU", true];
            }
          }
        });
      },
    );
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat('h:mm a');
    return format.format(dt);
  }

  String _hoursMinutes(TimeOfDay time) {
    return _formatTime(time).split(" ")[0];
  }

  String _meridiem(TimeOfDay time) {
    return _formatTime(time).split(" ")[1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text("New Reminder"),
      ),
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _validateData();
        },
        label: Text(
          widget._existing == null ? "Add Reminder" : "Save Reminder",
          style: GoogleFonts.istokWeb(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: const Color(0xFF6078F8),
        elevation: 4,
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
      body: content(),
    );
  }

  Widget addTime(index) {
    return Material(
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Chip(
            label: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: _hoursMinutes(_timesPicked[index]),
                    style: GoogleFonts.istokWeb(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' ${_meridiem(_timesPicked[index])}',
                    style: GoogleFonts.istokWeb(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            labelStyle: GoogleFonts.istokWeb(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            backgroundColor: const Color(0xFF326BFD),
            side: BorderSide.none,
          ),
          Positioned(
            top: -2,
            right: -4,
            child: Material(
              shape: const CircleBorder(),
              color: Colors.blueGrey.shade50,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _timesPicked.removeAt(index);
                  });
                },
                child: const Icon(
                  Icons.close,
                  color: Color(0xFF326BFD),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget content() {
    return SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 25,
            left: 10,
            right: 10,
            bottom: 100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.5),
                    child: Column(
                      children: [
                        Text(
                          'NEW REMINDER',
                          style: GoogleFonts.istokWeb(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Image.asset(
                          'assets/medicine.png',
                          width: 250,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(
                        top: 12.5,
                        bottom: 60,
                        left: 15,
                        right: 15,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Medicine Name',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _medicineNameController,
                            onChanged: (value) {
                              setState(() {
                                _medicineNameController.text = value;
                              });
                            },
                            style: GoogleFonts.istokWeb(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 15,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Medicine Route',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                width: 2,
                              ),
                            ),
                            child: DropdownButton<String>(
                              value: medicationRouteDropdownValue,
                              icon: const Icon(Icons.arrow_drop_down),
                              iconSize: 32,
                              isExpanded: true,
                              elevation: 0,
                              padding: const EdgeInsets.only(left: 12),
                              underline: Container(),
                              style: GoogleFonts.istokWeb(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              menuMaxHeight:
                                  MediaQuery.of(context).size.height * 0.5,
                              borderRadius: BorderRadius.circular(10),
                              dropdownColor: Colors.grey.shade300,
                              items: _medicineRoutes
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  medicationRouteDropdownValue = newValue!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Medicine Form',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                width: 2,
                              ),
                            ),
                            child: DropdownButton<String>(
                              value: medicationFormDropdownValue,
                              icon: const Icon(Icons.arrow_drop_down),
                              iconSize: 32,
                              isExpanded: true,
                              elevation: 0,
                              padding: const EdgeInsets.only(left: 12),
                              underline: Container(),
                              style: GoogleFonts.istokWeb(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              menuMaxHeight:
                                  MediaQuery.of(context).size.height * 0.5,
                              borderRadius: BorderRadius.circular(10),
                              dropdownColor: Colors.grey.shade300,
                              items: _medicineForms
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  medicationFormDropdownValue = newValue!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Dosage',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.5,
                                padding: const EdgeInsets.only(
                                  left: 10,
                                  top: 3,
                                  bottom: 3,
                                  right: 3,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Symbols.vaccines,
                                      size: 32,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        controller: _dosageController,
                                        onChanged: (value) {
                                          setState(() {
                                            _dosageController.text = value;
                                          });
                                        },
                                        style: GoogleFonts.istokWeb(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: "0 (Miligrams)",
                                          hintStyle: const TextStyle(
                                            fontSize: 14,
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey.shade200,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 15,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: Colors.transparent,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: Colors.transparent,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "mg",
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Text(
                                'Time & Schedule ',
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Expanded(child: Divider(thickness: 2)),
                            ],
                          ),
                          Wrap(
                            spacing: 5,
                            children: List.generate(
                              _timesPicked.length,
                              (index) => addTime(index),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 5,
                      child: ElevatedButton(
                        onPressed: () async {
                          //Show Time Picker
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );

                          if (pickedTime != null) {
                            setState(() {
                              _timesPicked.add(pickedTime);
                              _timesPicked = _timesPicked.toSet().toList();
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6078F8),
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(15),
                          elevation: 4,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.5,
                    horizontal: 15,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medication Duration',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Icon(
                            Icons.calendar_month_outlined,
                            color: Colors.grey,
                            size: 40,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: TextField(
                              readOnly: true,
                              controller: _dateController,
                              style: GoogleFonts.istokWeb(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                hintText: 'DD/MM/YYYY',
                                hintStyle: GoogleFonts.istokWeb(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFC8C8C8),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFE1E1E1),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 15,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onTap: () async {
                                await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(DateTime.now().year),
                                  lastDate: DateTime(DateTime.now().year + 10),
                                ).then(
                                  (selectedDate) {
                                    if (selectedDate != null) {
                                      _dateController.text =
                                          DateFormat('dd/MM/yyyy')
                                              .format(selectedDate);
                                    }
                                  },
                                );
                              },
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Medication Frequency',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Divider(thickness: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          _days.length,
                          (index) => GestureDetector(
                            onTap: () {
                              setState(() {
                                _days[index][1] = !_days[index][1];
                              });
                            },
                            child: Center(
                              child: Container(
                                width:
                                    MediaQuery.of(context).size.width * 0.115,
                                height:
                                    MediaQuery.of(context).size.width * 0.115,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _days[index][1]
                                      ? const Color(0xFF6078F8)
                                      : Colors.grey.shade200,
                                ),
                                child: Center(
                                  child: Text(
                                    _days[index][0],
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: _days[index][1]
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _hasMedicationFrequency(List<dynamic> days) {
    return days.any((day) => day[1] == true);
  }

  _validateData() {
    if (_medicineNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please Enter Medicine Name'),
        duration: Duration(milliseconds: 800),
      ));
    } else if (_dosageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please Enter Dosage Amount'),
        duration: Duration(milliseconds: 800),
      ));
    } else if (_timesPicked.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please Set Medication Time'),
        duration: Duration(milliseconds: 800),
      ));
    } else if (_dateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please Select Medication Duration Date'),
        duration: Duration(milliseconds: 800),
      ));
    } else if (!_hasMedicationFrequency(_days)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please Select Medication Frequency'),
        duration: Duration(milliseconds: 800),
      ));
    } else {
      _addReminderToDb().whenComplete(() => Navigator.of(context).pop());
    }
  }

  Future<void> _addReminderToDb() async {
    Database db = widget._db;

    // splitEndDate = [day, month, year]
    List<String> splitEndDate = _dateController.text.split('/');
    DateTime now = DateTime.now();
    List<int> desiredWeekdays = [];
    DateTime startDate = DateTime(
      now.year,
      now.month,
      now.day,
    );
    DateTime endDate = DateTime(
      int.parse(splitEndDate[2]),
      int.parse(splitEndDate[1]),
      int.parse(splitEndDate[0]),
    );

    // MedicationReminderRecord last record
    Map<String, dynamic>? lastRecord;
    if (await getLastRecord(db, "MedicationReminderRecords") != null) {
      lastRecord = await getLastRecord(db, "MedicationReminderRecords");
    }
    int lastRecordId = lastRecord != null ? lastRecord['id'] : 0;

    // MedicationReminderRecord to be inserted
    MedicationReminderRecord record = MedicationReminderRecord(
      id: lastRecordId + 1,
      startsAt: startDate,
      endsAt: endDate,
    );

    // Insert record to MedicationReminderRecords table
    if (widget._existing == null) {
      await db.insert('MedicationReminderRecords', record.toMap());
    } else {
      await db.update(
        "MedicationReminderRecords",
        record.toMap(),
        where: 'id = ?',
        whereArgs: [widget._existing!.medicationReminderRecordId],
      );
    }

    // debugPrint("Record: ${record.toMap()}");

    // get desired weekdays
    for (var i = 0; i < _days.length; i++) {
      //_days[i][1] = true/false
      if (_days[i][1]) {
        desiredWeekdays.add(i + 1);
      }
    }

    // MedicationRecordDetails last record
    Map<String, dynamic>? lastMedicationRecordDetails;
    if (await getLastRecord(db, "MedicationRecordDetails") != null) {
      lastMedicationRecordDetails =
          await getLastRecord(db, "MedicationRecordDetails");
    }
    int lastMedicationRecordDetailsId = lastMedicationRecordDetails != null
        ? lastMedicationRecordDetails['id']
        : 0;

    bool deleted = false;

    for (var date = startDate;
        date.isBefore(endDate.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))) {
      // debugPrint(date.toString());
      if (desiredWeekdays.contains(date.weekday)) {
        for (var time in _timesPicked) {
          int year = date.year;
          int month = date.month;
          int day = date.day;
          int hour = time.hour;
          int minute = time.minute;

          // MedicationRecordDetails to be inserted

          // Insert record to MedicationRecordDetails table
          // if (widget._existing == null) {
          //   await db.insert('MedicationRecordDetails', details.toMap());
          // } else {
          //   final detailsWithoutId = details.toMap();
          //   detailsWithoutId.remove("id");
          //   debugPrint(detailsWithoutId.toString());

          //   await db.update(
          //     "MedicationRecordDetails",
          //     detailsWithoutId,
          //     where: "medication_reminder_record_id = ?",
          //     whereArgs: [widget._existing!.medicationReminderRecordId],
          //   );
          // }

          DateTime now = DateTime.now();
          Duration difference =
              DateTime(year, month, day, hour, minute).difference(now);

          // TODO: Save notification ID and delete corresponding notits
          final notifId = await LocalNotification.schedNotif(
            title: "Medication Reminder",
            body: "Time to take ${_medicineNameController.text}",
            payload: "payload",
            delay: difference,
            id: lastMedicationRecordDetailsId + 1,
          );

          if (notifId == null) {
            continue;
          }

          MedicationRecordDetails details = MedicationRecordDetails(
            id: lastMedicationRecordDetailsId + 1,
            medicationReminderRecordId: record.id,
            medicineName: _medicineNameController.text,
            medicineRoute: medicationRouteDropdownValue,
            medicineForm: medicationFormDropdownValue,
            medicineDosage: double.parse(_dosageController.text),
            medicationDatetime: DateTime(year, month, day, hour, minute),
            notifId: notifId,
          );

          lastMedicationRecordDetailsId++;

          if (widget._existing == null) {
            await db.insert("MedicationRecordDetails", details.toMap());
          } else {
            if (!deleted) {
              final notifRecords = await db.rawQuery(
                "SELECT * FROM MedicationRecordDetails WHERE medication_reminder_record_id = ?",
                [widget._existing!.medicationReminderRecordId],
              );

              final parsedIds =
                  MedicationRecordDetails.fromListOfMaps(notifRecords)
                      .map((element) => element.notifId)
                      .toList();

              for (var id in parsedIds) {
                await LocalNotification.cancel(id);
              }

              await db.delete(
                "MedicationRecordDetails",
                where: "medication_reminder_record_id = ?",
                whereArgs: [widget._existing!.medicationReminderRecordId],
              );

              deleted = true;
            }

            await db.insert("MedicationRecordDetails", details.toMap());
          }

          // debugPrint("Details: ${details.medicationDatetime}");
          // debugPrint(DateTime(year, month, day, hour, minute).toString());

          // debugPrint(difference.inSeconds.toString());
        }
      }
    }

    // debugPrint(
    //     "Medication Reminder Records : ${await db.rawQuery("SELECT * FROM MedicationReminderRecords")}");
    // debugPrint(
    //     "Medication Reminder Details : ${await db.rawQuery("SELECT * FROM MedicationRecordDetails")}");
  }

  Future<Map<String, dynamic>?> getLastRecord(
      Database db, String tableName) async {
    final result =
        await db.rawQuery('SELECT * FROM $tableName ORDER BY id DESC LIMIT 1');
    return result.isEmpty ? null : result.first;
  }
}
