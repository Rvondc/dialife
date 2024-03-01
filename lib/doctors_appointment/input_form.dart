import 'package:dialife/doctors_appointment/entities.dart';
import 'package:dialife/local_notifications/local_notifications.dart';
import 'package:dialife/user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class NewDoctorsAppointmentForm extends StatefulWidget {
  final User _user;
  final Database _db;

  const NewDoctorsAppointmentForm({
    super.key,
    required User user,
    required Database db,
  })  : _user = user,
        _db = db;

  @override
  State<NewDoctorsAppointmentForm> createState() =>
      _NewDoctorsAppointmentFormState();
}

class _NewDoctorsAppointmentFormState extends State<NewDoctorsAppointmentForm> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _doctorController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();

  DateTime? _date;
  TimeOfDay? _time;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text("New Appointment"),
      ),
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _validateData();
          // Navigator.of(context).pop();
        },
        label: Text(
          "Set Appointment",
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

  Widget content() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 25,
          left: 10,
          right: 10,
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
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.5,
                    horizontal: 15,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Appointment Info",
                        style: GoogleFonts.istokWeb(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: _doctorController,
                            onChanged: (value) {
                              setState(() {
                                _doctorController.text = value;
                              });
                            },
                            style: GoogleFonts.istokWeb(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              hintText: "Doctors Name",
                              hintStyle: const TextStyle(
                                fontSize: 18,
                                color: Color(0xFFC8C8C8),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 15,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: _purposeController,
                            onChanged: (value) {
                              setState(() {
                                _purposeController.text = value;
                              });
                            },
                            style: GoogleFonts.istokWeb(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              hintText: "Appointment Purpose",
                              hintStyle: const TextStyle(
                                fontSize: 18,
                                color: Color(0xFFC8C8C8),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 15,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                        ),
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
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.5,
                    horizontal: 15,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Date & Time",
                        style: GoogleFonts.istokWeb(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(DateTime.now().year),
                                  lastDate: DateTime(DateTime.now().year + 10))
                              .then((selectedDate) {
                            if (selectedDate != null) {
                              _date = selectedDate;
                              _dateController.text =
                                  DateFormat('dd/MM/yyyy').format(selectedDate);
                            }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(7.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_month_outlined,
                                  size: 32,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    readOnly: true,
                                    controller: _dateController,
                                    style: GoogleFonts.istokWeb(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "DD/MM/YYYY",
                                      hintStyle: const TextStyle(
                                        fontSize: 18,
                                        color: Color(0xFFC8C8C8),
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
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.transparent,
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );

                          if (pickedTime != null) {
                            _time = pickedTime;
                            _timeController.text = DateFormat('hh:mm a').format(
                              DateTime(
                                DateTime.now().year,
                                DateTime.now().month,
                                DateTime.now().day,
                                pickedTime.hour,
                                pickedTime.minute,
                              ),
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(7.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.timer_sharp,
                                  size: 32,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    readOnly: true,
                                    controller: _timeController,
                                    style: GoogleFonts.istokWeb(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "HH:MM AM/PM",
                                      hintStyle: const TextStyle(
                                        fontSize: 18,
                                        color: Color(0xFFC8C8C8),
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
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Colors.transparent,
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _validateData() {
    if (_dateController.text.isEmpty ||
        _timeController.text.isEmpty ||
        _doctorController.text.isEmpty ||
        _purposeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Submission'),
          duration: Duration(milliseconds: 800),
        ),
      );
    } else {
      _addDataToDb().whenComplete(() => Navigator.of(context).pop());
    }
  }

  Future<void> _addDataToDb() async {
    Database db = widget._db;

    // TODO: Add local notifications
    Map<String, dynamic>? lastRecord;
    if (await getLastRecord(db, "DoctorsAppointmentRecords") != null) {
      lastRecord = await getLastRecord(db, "DoctorsAppointmentRecords");
    }
    int lastDoctorsAppointmentId =
        lastRecord != null ? lastRecord['id'] + 1 : 1;

    final appointmentTime = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _time!.hour,
      _time!.minute,
    );

    final id = await LocalNotification.schedNotif(
      title: "Doctors Appointment",
      body:
          "Appointment with Dr. ${_doctorController.text}. Purpose: ${_purposeController.text}",
      payload: "payload",
      delay: appointmentTime.difference(DateTime.now()),
      id: lastDoctorsAppointmentId + 500,
    );

    if (id == null) {
      return;
    }

    DoctorsAppointmentRecord newRecord = DoctorsAppointmentRecord(
      id: lastDoctorsAppointmentId,
      doctorName: _doctorController.text,
      appointmentDatetime: appointmentTime,
      appointmentPurpose: _purposeController.text,
    );

    await db.insert('DoctorsAppointmentRecords', newRecord.toMap());
  }

  Future<Map<String, dynamic>?> getLastRecord(
      Database db, String tableName) async {
    final result =
        await db.rawQuery('SELECT * FROM $tableName ORDER BY id DESC LIMIT 1');
    return result.isEmpty ? null : result.first;
  }
}
