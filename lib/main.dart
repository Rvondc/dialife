import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart' as crs;
import 'package:dialife/api/api.dart';
import 'package:dialife/chat/doctor_chat.dart';
import 'package:dialife/doctor_connections/doctor_connections.dart';
import 'package:dialife/expanded_root.dart';
import 'package:dialife/lab_results/lab_results.dart';
import 'package:dialife/root.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dialife/activity_log/activity_log.dart';
import 'package:dialife/activity_log/input_form.dart';
import 'package:dialife/activity_log/record_editor.dart';
import 'package:dialife/contact_list/contact_list.dart';
import 'package:dialife/contact_list/input_form.dart';
import 'package:dialife/edit_user.dart';
import 'package:dialife/edit_user_birthdate.dart';
import 'package:dialife/education/diabetes_sections.dart';
import 'package:dialife/education/education.dart';
import 'package:dialife/nutrition_log/input_form.dart';
import 'package:dialife/nutrition_log/nutrition_log.dart';
import 'package:dialife/blood_glucose_tracking/entities.dart';
import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:dialife/blood_glucose_tracking/input_form.dart';
import 'package:dialife/blood_glucose_tracking/record_editor.dart';
import 'package:dialife/bmi_tracking/bmi_tracking.dart';
import 'package:dialife/bmi_tracking/input_form.dart';
import 'package:dialife/bmi_tracking/record_editor.dart';

import 'package:dialife/doctors_appointment/entities.dart';
import 'package:dialife/doctors_appointment/input_form.dart';
import 'package:dialife/local_notifications/local_notifications.dart';
import 'package:dialife/medication_tracking/entities.dart';
import 'package:dialife/medication_tracking/input_form.dart';

import 'package:dialife/medication_tracking/medication_tracking.dart';
import 'package:dialife/nutrition_log/record_editor.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:path/path.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:sqflite/sqflite.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  await LocalNotification.init();
  MonitoringAPI.init();

  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: 'PulsePilot',
      theme: ThemeData(
        primaryColor: Colors.white,
        useMaterial3: true,
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case "/":
            return MaterialPageRoute(
              builder: (context) => const Root(),
              settings: const RouteSettings(name: "/"),
            );
          case "/more":
            final args = settings.arguments as Map<String, dynamic>;

            return MaterialPageRoute(
              builder: (context) => ExapndedRoot(
                db: args['db'],
                user: args['user'],
                generatePdfFile: args['generatePdfFile'],
              ),
              settings: const RouteSettings(name: "/more"),
            );
          case "/edit-user":
            return MaterialPageRoute(
              builder: (context) => const EditUser(),
              settings: const RouteSettings(name: "/edit-user"),
            );
          case "/edit-user/address":
            final args = settings.arguments as Map<String, dynamic>;

            return MaterialPageRoute(
              builder: (context) => EditUserBirthDate(
                barangay: args["barangay"],
                municipality: args["municipality"],
                province: args["province"],
                zipCode: args["zip_code"],
                provinceMap: args["province_map"],
                addressDescription: args["address_description"],
              ),
              settings: const RouteSettings(name: "/edit-user/address"),
            );
          case "/blood-glucose-tracking":
            final args = settings.arguments as Map<String, dynamic>;

            return MaterialPageRoute(
              builder: (context) => GlucoseTracking(
                db: args["db"],
                user: args["user"],
              ),
              settings: const RouteSettings(name: "/blood-glucose-tracking"),
            );
          case "/blood-glucose-tracking/editor":
            final args = settings.arguments as Map<String, dynamic>;

            return MaterialPageRoute(
              builder: (context) => GlucoseRecordEditor(
                db: args["db"],
                user: args["user"],
              ),
              settings:
                  const RouteSettings(name: "/blood-glucose-tracking/editor"),
            );
          case "/blood-glucose-tracking/input":
            final args = settings.arguments as Map<String, dynamic>;

            return MaterialPageRoute(
              builder: (context) => GlucoseRecordInputForm(
                existing: args["existing"],
                db: args["db"],
                user: args["user"],
              ),
              settings:
                  const RouteSettings(name: "/blood-glucose-tracking/input"),
            );
          case "/bmi-tracking":
            final args = settings.arguments as Map<String, dynamic>;

            return MaterialPageRoute(
              builder: (context) => BMITracking(
                db: args["db"],
                user: args["user"],
              ),
              settings: const RouteSettings(name: "/bmi-tracking"),
            );
          case "/bmi-tracking/editor":
            final args = settings.arguments as Map<String, dynamic>;

            return MaterialPageRoute(
              builder: (context) => BMIRecordEditor(
                db: args["db"],
                user: args["user"],
              ),
              settings: const RouteSettings(name: "/bmi-tracking/editor"),
            );
          case "/bmi-tracking/input":
            final args = settings.arguments as Map<String, dynamic>;

            return MaterialPageRoute(
              builder: (context) => BMIRecordForm(
                existing: args["existing"],
                db: args["db"],
                user: args["user"],
              ),
              settings: const RouteSettings(name: "/bmi-tracking/input"),
            );
          case "/medication-tracking":
            // debugPrint("Settings arguments:" + settings.arguments.toString());
            final args = settings.arguments as Map<String, dynamic>;
            // debugPrint(args["user"].toString());

            return MaterialPageRoute(
              builder: (context) => MedicationTracking(
                db: args["db"],
                user: args["user"],
              ),
              settings: const RouteSettings(name: "/medication-tracking"),
            );
          case "/medication-tracking/input":
            // debugPrint(settings.arguments.toString());
            final args = settings.arguments as Map<String, dynamic>;
            // debugPrint("args : ${args.toString()}");

            return MaterialPageRoute(
              builder: (context) => NewMedicationReminderInputForm(
                db: args["db"],
                existing: args["existing"],
              ),
              settings: const RouteSettings(
                name: "/medication-tracking/input",
              ),
            );
          case "/doctors-appointment/input":
            final args = settings.arguments as Map<String, dynamic>;

            return MaterialPageRoute(
              builder: (context) => NewDoctorsAppointmentForm(
                db: args["db"],
                existing: args["existing"],
              ),
              settings: const RouteSettings(
                name: "/doctors-appointment/input",
              ),
            );
          case "/nutrition-log":
            final args = settings.arguments as Map<String, dynamic>;

            return MaterialPageRoute(
              builder: (context) => NutritionLog(
                db: args["db"],
              ),
              settings: const RouteSettings(name: "/nutrition-log"),
            );
          case "/nutrition-log/input":
            final args = settings.arguments as Map<String, dynamic>;

            return MaterialPageRoute(
              builder: (context) => NutritionLogInput(
                db: args["db"],
                now: args["now"],
                existing: args["existing"],
              ),
              settings: const RouteSettings(name: "/nutrition-log/input"),
            );
          case "/nutrition-log/editor":
            final args = settings.arguments as Map<String, dynamic>;

            return MaterialPageRoute(
              builder: (context) => NutritionRecordEditor(db: args["db"]),
              settings: const RouteSettings(name: "/nutrition-log/editor"),
            );

          case "/activity-log":
            final args = settings.arguments as Map<String, dynamic>;

            return MaterialPageRoute(
              builder: (context) => ActivityLog(db: args["db"]),
              settings: const RouteSettings(name: "/activity-log"),
            );
          case "/activity-log/input":
            final args = settings.arguments as Map<String, dynamic>;

            return MaterialPageRoute(
              builder: (context) => ActivityLogInput(
                db: args["db"],
                now: args["now"],
                existing: args["existing"],
              ),
              settings: const RouteSettings(name: "/activity-log/input"),
            );
          case "/activity-log/editor":
            final args = settings.arguments as Map<String, dynamic>;

            return MaterialPageRoute(
              builder: (context) => ActivityRecordEditor(db: args["db"]),
              settings: const RouteSettings(name: "/activity-log/editor"),
            );
          case "/contact-list":
            return MaterialPageRoute(
              builder: (context) => const ContactList(),
              settings: const RouteSettings(name: "/contact-list"),
            );
          case "/contact-list/input":
            final args = settings.arguments as Map<String, dynamic>;

            return MaterialPageRoute(
              builder: (context) => ContactListInput(db: args["db"]),
              settings: const RouteSettings(name: "/contact-list/input"),
            );
          case "/education":
            return MaterialPageRoute(
              builder: (context) => const Education(),
              settings: const RouteSettings(name: "/education"),
            );
          case "/education/diabetes":
            final args = settings.arguments as Map<String, dynamic>;

            return MaterialPageRoute(
              builder: (context) => DiabetesList(
                lang: args["lang"],
              ),
              settings: const RouteSettings(name: '/education/diabetes'),
            );
          case "/monitoring":
            return MaterialPageRoute(
              builder: (context) => const DoctorConnections(),
              settings: const RouteSettings(name: '/monitoring'),
            );
          case "/monitoring/chat":
            final args = settings.arguments as Map<String, dynamic>;

            return MaterialPageRoute(
              builder: (context) => DoctorChat(doctor: args['doctor']),
              settings: const RouteSettings(name: '/monitoring/chat'),
            );
          case "/lab-results":
            return MaterialPageRoute(
              builder: (context) => const LabResults(),
              settings: const RouteSettings(name: '/lab-results'),
            );
        }

        return null;
      },
    );
  }
}

class DoctorsAppointment extends StatefulWidget {
  const DoctorsAppointment({
    super.key,
    required List<DoctorsAppointmentRecord>? doctorsAppointmentRecords,
    required this.resetRecords,
    required this.db,
  }) : _doctorsAppointmentRecords = doctorsAppointmentRecords;

  final List<DoctorsAppointmentRecord>? _doctorsAppointmentRecords;
  final void Function() resetRecords;
  final Database db;

  @override
  State<DoctorsAppointment> createState() => _DoctorsAppointmentState();
}

class _DoctorsAppointmentState extends State<DoctorsAppointment> {
  final _carouselController = crs.CarouselSliderController();

  int _page = 0;

  @override
  Widget build(BuildContext context) {
    if (widget._doctorsAppointmentRecords == null ||
        widget._doctorsAppointmentRecords?.isEmpty == true) {
      return const Text("No Appointments");
    }

    final validRecent = widget._doctorsAppointmentRecords!.where((rec) =>
        rec.appointmentDatetime
            .difference(
              DateTime.now(),
            )
            .inMinutes >
        -5);

    if (validRecent.isEmpty) {
      return const Text("No Appointments");
    }

    return Material(
      child: Container(
        color: Colors.white.withOpacity(0.8),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
        ),
        child: Column(
          children: [
            crs.CarouselSlider(
              options: crs.CarouselOptions(
                aspectRatio: 8,
                padEnds: false,
                enlargeCenterPage: true,
                enlargeFactor: 0.36,
                enableInfiniteScroll: false,
                viewportFraction: 1,
                onPageChanged: (index, reason) {
                  setState(() {
                    _page = index;
                  });
                },
              ),
              carouselController: _carouselController,
              items: validRecent.map((rec) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Dr. ${rec.doctorName}",
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () async {
                                await Navigator.of(context).pushNamed(
                                    "/doctors-appointment/input",
                                    arguments: {
                                      "db": widget.db,
                                      "existing": rec,
                                    });

                                widget.resetRecords();
                              },
                              child: const Icon(
                                Icons.edit_outlined,
                                color: fgColor,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        Text(rec.appointmentPurpose,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                            )),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          DateFormat("MMMM d, yyyy")
                              .format(rec.appointmentDatetime),
                          style: GoogleFonts.inter(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          DateFormat("h:mm a").format(rec.appointmentDatetime),
                        ),
                      ],
                    ),
                  ],
                );
              }).toList(),
            ),
            () {
              if (validRecent.length > 1) {
                return AnimatedSmoothIndicator(
                  activeIndex: _page,
                  effect: const ScrollingDotsEffect(
                    dotColor: Colors.grey,
                    fixedCenter: true,
                    dotHeight: 5,
                    dotWidth: 5,
                    spacing: 4,
                  ),
                  count: validRecent.length,
                );
              } else {
                return const SizedBox();
              }
            }(),
          ],
        ),
      ),
    );
  }
}

class BMIGraph extends StatelessWidget {
  final double frac;

  const BMIGraph({
    required this.frac,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    assert(frac >= 0 && frac <= 1, "fraction must be between 0 and 1");

    int frontOffset = (frac * 100).toInt();
    int backOffset = ((1 - frac) * 100).toInt();
    String category;
    String description;

    Color pointerColor;

    if (frac >= 0 && frac <= 0.23) {
      category = "Underweight";
      description = "You have low BMI";
      pointerColor = const Color(0xFFEAA902);
    } else if (frac > 0.23 && frac <= 0.5) {
      category = "Normal";
      description = "You are Healthy!";
      pointerColor = const Color(0xFF46B265);
    } else if (frac > 0.5 && frac <= 0.77) {
      category = "Overweight";
      description = "You have high BMI";
      pointerColor = const Color(0xFFE8E26D);
    } else {
      category = "Obese";
      description = "You have extreme BMI";
      pointerColor = const Color(0xFFB84141);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Stack(
        children: [
          const Positioned.fill(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Divider(
                    color: Color(0xFFEAA902),
                    thickness: 3,
                    indent: 7,
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: Color(0xFF46B265),
                    thickness: 3,
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: Color(0xFFE8E26D),
                    thickness: 3,
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: Color(0xFFB84141),
                    thickness: 3,
                    endIndent: 7,
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.zero,
              child: Row(
                children: [
                  Expanded(
                    flex: frontOffset,
                    child: const SizedBox(),
                  ),
                  Container(
                    constraints: const BoxConstraints(
                      minHeight: 30,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: pointerColor,
                      boxShadow: [
                        BoxShadow(
                          spreadRadius: 2,
                          offset: const Offset(0, 0),
                          color: Colors.black.withOpacity(0.6),
                        )
                      ],
                    ),
                    width: 4,
                  ),
                  Expanded(
                    flex: backOffset,
                    child: const SizedBox(),
                  ),
                ],
              ),
            ),
          ),
          // Positioned(
          //   child: Align(
          //     alignment: Alignment.bottomCenter,
          //     child: Padding(
          //       padding: const EdgeInsets.only(
          //         bottom: 8.0,
          //         left: 4,
          //         right: 4,
          //       ),
          //       child: AutoSizeText.rich(
          //         TextSpan(
          //           children: [
          //             TextSpan(
          //               text: "$category, ",
          //               style: GoogleFonts.inter(
          //                 color: pointerColor,
          //                 fontWeight: FontWeight.bold,
          //                 letterSpacing: 1.1,
          //                 shadows: const [
          //                   Shadow(
          //                     // bottomLeft
          //                     offset: Offset(-1, -1),
          //                     color: Colors.black,
          //                   ),
          //                   Shadow(
          //                     // bottomRight
          //                     offset: Offset(1, -1),
          //                     color: Colors.black,
          //                   ),
          //                   Shadow(
          //                     // topRight
          //                     offset: Offset(1, 1),
          //                     color: Colors.black,
          //                   ),
          //                   Shadow(
          //                     // topLeft
          //                     offset: Offset(-1, 1),
          //                     color: Colors.black,
          //                   ),
          //                 ],
          //               ),
          //             ),
          //             TextSpan(
          //               text: description,
          //               style: GoogleFonts.inter(
          //                 color: Colors.black,
          //               ),
          //             ),
          //           ],
          //         ),
          //         textAlign: TextAlign.center,
          //         minFontSize: 4,
          //         overflow: TextOverflow.fade,
          //         maxLines: 1,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class LastUpdatedSection extends StatelessWidget {
  const LastUpdatedSection({
    super.key,
    required List<GlucoseRecord>? records,
  }) : _records = records;

  final List<GlucoseRecord>? _records;

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      if (_records == null || _records!.isEmpty) {
        return const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "--",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(width: 3),
            Text(
              "Hours Ago",
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 12,
              ),
            ),
          ],
        );
      }

      final inHours =
          DateTime.now().difference(_records!.last.bloodTestDate).inHours;
      final inMinutes =
          DateTime.now().difference(_records!.last.bloodTestDate).inMinutes;
      final inSeconds =
          DateTime.now().difference(_records!.last.bloodTestDate).inSeconds;

      int time;
      String descriptionText;

      if (inHours == 1) {
        descriptionText = "Hour Ago";
        time = inHours;
      } else if (inHours < 1 && inMinutes > 1) {
        descriptionText = "Mins Ago";
        time = inMinutes;
      } else if (inHours < 1 && inMinutes == 1) {
        descriptionText = "Min Ago";
        time = inMinutes;
      } else if (inMinutes < 1 && inSeconds > 0) {
        descriptionText = "Secs Ago";
        time = inSeconds;
      } else {
        descriptionText = "Hours Ago";
        time = inHours;
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            time.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(width: 3),
          SizedBox(
            width: 70,
            child: AutoSizeText(
              descriptionText,
              minFontSize: 8,
              maxLines: 1,
              style: const TextStyle(
                color: Colors.blueGrey,
              ),
            ),
          ),
        ],
      );
    });
  }
}

Future<Map<String, dynamic>> loadMunicipalityData() async {
  final raw =
      await rootBundle.loadString("assets/municipalities_and_barangays.json");
  final data = jsonDecode(raw) as Map<String, dynamic>;

  return data;
}

// NOTE: For table creation on first time initialization
Future<Database> initAppDatabase(String path) async {
  return openDatabase(
    join(path, "app.db"),
    onCreate: (db, version) async {
      await db.execute("""
        CREATE TABLE User (
          id INTEGER NOT NULL PRIMARY KEY,
          web_id INTEGER,
          recovery_id TEXT,
          first_name VARCHAR(255) NOT NULL,
          last_name VARCHAR(255) NOT NULL,
          middle_name VARCHAR(255),
          is_male BOOLEAN NOT NULL,
          birthdate DATETIME NOT NULL,
          province VARCHAR(50) NOT NULL,
          municipality VARCHAR(50) NOT NULL,
          barangay VARCHAR(50) NOT NULL,
          address_description VARCHAR(255) NOT NULL,
          zip_code VARCHAR(10) NOT NULL,
          contact_number VARCHAR(20) NOT NULL
        )
       """);

      await db.execute("""
        CREATE TABLE GlucoseRecord (
          id INTEGER NOT NULL PRIMARY KEY,
          glucose_level DECIMAL(5, 2) NOT NULL,
          notes VARCHAR(255) NOT NULL,
          is_a1c BOOLEAN NOT NULl,
          blood_test_date DATETIME
        )
       """);

      await db.execute("""
        CREATE TABLE BMIRecord (
          id INTEGER PRIMARY KEY NOT NULL,
          height DECIMAL(3, 2) NOT NULL,
          notes VARCHAR(255) NOT NULL,
          weight DECIMAL(5, 2) NOT NULL,
          created_at DATETIME NOT NULL
        ) 
      """);

      await db.execute("""
        CREATE TABLE NutritionRecord (
          id INTEGER PRIMARY KEY NOT NULL,
          -- protein DECIMAL(5, 2) NOT NULL,
          -- fat DECIMAL(5, 2) NOT NULL,
          -- carbohydrates DECIMAL(5, 2) NOT NULL,
          -- water INTEGER NOT NULL,
          notes VARCHAR(255) NOT NULL,
          day_description VARCHAR(20) NOT NULL,
          foods_csv TEXT NOT NULL,
          created_at DATETIME NOT NULL
        )
      """);

      await db.execute("""
        CREATE TABLE WaterRecord (
          id INTEGER PRIMARY KEY NOT NULL,
          glasses INTEGER NOT NULL,
          time DATETIME NOT NULL
        )
      """);

      await db.execute("""
        CREATE TABLE MedicationReminderRecords (
          id INTEGER PRIMARY KEY NOT NULL,
          starts_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
          ends_at DATETIME NOT NULL
        )
      """);

      await db.execute("""
        CREATE TABLE ActivityRecord (
          id INTEGER PRIMARY KEY NOT NULL,
          type VARCHAR(15) NOT NULL,
          duration INTEGER NOT NULL,
          frequency INTEGER NOT NULL,
          created_at DATETIME NOT NULL,
          notes VARCHAR(255) NOT NULL
        )
      """);

      await db.execute("""
        CREATE TABLE MedicationRecordDetails (
          id INTEGER PRIMARY KEY NOT NULL,
          medication_reminder_record_id INTEGER NOT NULL,
          medicine_name VARCHAR(255) NOT NULL,
          medicine_route VARCHAR(255) NOT NULL,
          medicine_form VARCHAR(255) NOT NULL,
          medicine_dosage DECIMAL(5, 2) NOT NULL,
          medication_datetime DATETIME NOT NULL,
          actual_taken_time DATETIME,
          notification_id INTEGER NOT NULL,
          FOREIGN KEY(medication_reminder_record_id) REFERENCES MedicationReminderRecords(id)
        )
      """);

      await db.execute("""
        CREATE TABLE Doctor (
          id INTEGER PRIMARY KEY NOT NULL,
          facebook_id VARCHAR(20),
          name VARCHAR(255) NOT NULL,
          contact_number VARCHAR(20),
          address VARCHAR(255) NOT NULL,
          description VARCHAR(255) NOT NULL
        )
      """);

      await db.execute("""
        CREATE TABLE Passcode (
          id INTEGER PRIMARY KEY NOT NULL,
          code VARCHAR(4) NOT NULL 
        )
      """);

      await db.execute("""
        CREATE TABLE DoctorsAppointmentRecords (
          id INTEGER PRIMARY KEY NOT NULL,
          doctor_name VARCHAR(255) NOT NULL,
          apointment_datetime DATETIME NOT NULL,
          appointment_purpose VARCHAR(255) NOT NULL,
          notification_id INTEGER NOT NULL
        )
      """);
    },
    version: 6,
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion != 5 && newVersion == 6) {
        await db.rawQuery(
          'ALTER TABLE MedicationRecordDetails ADD actual_taken_time DATETIME',
        );

        final records =
            await db.rawQuery("SELECT * FROM MedicationRecordDetails");

        final parsed = MedicationRecordDetails.fromListOfMaps(records);

        for (var record in parsed) {
          if (record.actualTakenTime == null) {
            await db.rawUpdate(
              "UPDATE MedicationRecordDetails SET actual_taken_time = ? WHERE id = ?",
              [
                record.medicationDatetime.toIso8601String(),
                record.id,
              ],
            );
          }
        }
      }
    },
  );
}

DateTime findClosestFutureDate(Map<DateTime, dynamic> map) {
  final now = DateTime.now();
  DateTime closestDate = now;

  map.forEach((date, value) {
    if (date.isAfter(now)) {
      final difference = (now.difference(date).inMilliseconds).abs();
      if (difference < (now.difference(closestDate).inMilliseconds.abs())) {
        closestDate = date;
      }
    }
  });

  return closestDate;
}
