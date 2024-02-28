import 'dart:ui' as ui;
import 'dart:convert';
import 'dart:io';

import 'package:dialife/activity_log/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:dialife/activity_log/activity_log.dart';
import 'package:dialife/activity_log/entities.dart';
import 'package:dialife/activity_log/input_form.dart';
import 'package:dialife/activity_log/record_editor.dart';
import 'package:dialife/contact_list/contact_list.dart';
import 'package:dialife/contact_list/input_form.dart';
import 'package:dialife/edit_user.dart';
import 'package:dialife/edit_user_birthdate.dart';
import 'package:dialife/education/diabetes_sections.dart';
import 'package:dialife/education/education.dart';
import 'package:dialife/emergency_numbers.dart';
import 'package:dialife/nutrition_and_activity.dart';
import 'package:dialife/nutrition_log/entities.dart';
import 'package:dialife/nutrition_log/input_form.dart';
import 'package:dialife/nutrition_log/nutrition_log.dart';
import 'package:dialife/blood_glucose_tracking/calculate_average.dart';
import 'package:dialife/blood_glucose_tracking/entities.dart';
import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:dialife/blood_glucose_tracking/input_form.dart';
import 'package:dialife/blood_glucose_tracking/record_editor.dart';
import 'package:dialife/blood_glucose_tracking/utils.dart';
import 'package:dialife/bmi_tracking/bmi_tracking.dart';
import 'package:dialife/bmi_tracking/entities.dart';
import 'package:dialife/bmi_tracking/input_form.dart';
import 'package:dialife/bmi_tracking/record_editor.dart';

import 'package:dialife/doctors_appointment/entities.dart';
import 'package:dialife/doctors_appointment/input_form.dart';
import 'package:dialife/local_notifications/local_notifications.dart';
import 'package:dialife/medication_tracking/entities.dart';
import 'package:dialife/medication_tracking/input_form.dart';

import 'package:dialife/medication_tracking/medication_tracking.dart';
import 'package:dialife/nutrition_log/record_editor.dart';
import 'package:dialife/passcode.dart';
import 'package:dialife/setup.dart';
import 'package:dialife/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:sqflite/sqflite.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  await LocalNotification.init();

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
      title: 'DiaLife',
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
                user: args["user"],
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
                user: args["user"],
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
            );
        }

        return null;
      },
    );
  }
}

class Root extends StatefulWidget {
  const Root({super.key});

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  List<GlucoseRecord>? _glucoseRecords;
  List<BMIRecord>? _bmiRecords;
  List<NutritionRecord>? _nutritionRecords;
  List<ActivityRecord>? _activityRecords;
  bool _authenticated = false;
  late User _user;
  List<DoctorsAppointmentRecord>? _doctorsAppointmentRecords;
  List<MedicationRecordDetails>? _medicationRecordDetails;
  @override
  Widget build(BuildContext context) {
    void reset() {
      setState(() {});
    }

    void resetNutritionRecords() {
      setState(() {
        _nutritionRecords = null;
      });
    }

    void resetActivityRecords() {
      setState(() {
        _activityRecords = null;
      });
    }

    void setAuthenticated(bool auth) {
      setState(() {
        _authenticated = auth;
      });
    }

    return PageView(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.grey.shade200,
            toolbarHeight: 40,
            elevation: 0,
            leading: IconButton(
              hoverColor: Colors.transparent,
              onPressed: !_authenticated
                  ? null
                  : () async {
                      await Navigator.of(context).pushNamed("/edit-user");

                      reset();
                    },
              icon: Icon(
                Icons.person_outline,
                color: _authenticated ? Colors.black : Colors.grey,
                size: 24,
              ),
            ),
            actions: [
              IconButton(
                hoverColor: Colors.transparent,
                onPressed: !_authenticated ? null : generatePdfFile,
                icon: const Icon(Icons.print_outlined),
              ),
              IconButton(
                hoverColor: Colors.transparent,
                onPressed: !_authenticated
                    ? null
                    : () {
                        Navigator.of(context).pushNamed("/contact-list");
                      },
                icon: Image.asset(
                  "assets/messenger_logo.png",
                  width: 48,
                  opacity: _authenticated
                      ? const AlwaysStoppedAnimation(1)
                      : const AlwaysStoppedAnimation(0.4),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.grey.shade200,
          body: FutureBuilder(
            future: getDatabasesPath(),
            builder: (context, data) {
              const loading = SpinKitCircle(color: fgColor);

              if (data.connectionState != ConnectionState.done ||
                  data.data == null) {
                return loading;
              }

              return FutureBuilder(
                future: initAppDatabase(data.data!),
                builder: (context, dbContainer) {
                  if (dbContainer.connectionState != ConnectionState.done ||
                      dbContainer.data == null) {
                    return loading;
                  }

                  return FutureBuilder(
                    future: Future.wait(
                      [
                        dbContainer.data!.query("User"),
                        loadMunicipalityData(),
                      ],
                    ),
                    builder: (context, AsyncSnapshot<List<dynamic>> data) {
                      if (data.connectionState != ConnectionState.done ||
                          data.data == null) {
                        return loading;
                      }

                      final municipalityData =
                          data.data![1] as Map<String, dynamic>;
                      final vals = municipalityData.values
                          .map((region) => region["province_list"])
                          .toList()
                          .cast<Map<String, dynamic>>();

                      final provinceList = vals
                          .map((provinceList) => provinceList.entries.toList())
                          .flattened
                          .toList();

                      final provinceMap = {
                        for (var element in provinceList)
                          element.key: element.value
                      };

                      () async {
                        if (!mounted) return;
                        await Future.wait([
                          precacheImage(
                            const AssetImage("assets/glucose_logo.png"),
                            context,
                          ),
                          precacheImage(
                            const AssetImage("assets/nutrition_log.png"),
                            context,
                          ),
                          precacheImage(
                            const AssetImage("assets/activity_log.png"),
                            context,
                          ),
                          precacheImage(
                            const AssetImage("assets/messenger_logo.png"),
                            context,
                          ),
                          precacheImage(
                            const AssetImage("assets/eye_problems.png"),
                            context,
                          ),
                          precacheImage(
                            const AssetImage("assets/foot_problems.png"),
                            context,
                          ),
                          GoogleFonts.pendingFonts([
                            GoogleFonts.montserrat(),
                            GoogleFonts.istokWeb(),
                            GoogleFonts.italianno(),
                          ]),
                        ]);

                        FlutterNativeSplash.remove();
                      }();

                      if (data.data![0].isEmpty) {
                        return SafeArea(
                          child: UserSetup(
                            reset: reset,
                            provinceMap: provinceMap,
                            db: dbContainer.data!,
                          ),
                        );
                      }

                      if (!_authenticated) {
                        return Passcode(setAuth: setAuthenticated);
                      }

                      final user = User.fromMap(data.data![0].first);
                      _user = user;

                      return Container(
                        constraints: const BoxConstraints.expand(),
                        child: ListView(
                          children: [
                            Text(
                              'DiaLife',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.italianno(
                                fontSize: 60,
                                color: const Color.fromRGBO(76, 102, 240, 1.0),
                              ),
                            ),
                            // Current health status text label
                            RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                    text: "Welcome, ",
                                    style: GoogleFonts.istokWeb(
                                      fontSize: 20,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "${user.firstName}!",
                                    style: GoogleFonts.istokWeb(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),

                            // Container for health progress bar
                            GestureDetector(
                              onTap: () async {
                                await Navigator.of(context).pushNamed(
                                  "/blood-glucose-tracking",
                                  arguments: {
                                    "user": user,
                                    "db": dbContainer.data!,
                                  },
                                );

                                setState(() {
                                  _glucoseRecords = null;
                                });
                              },
                              child: Container(
                                width: double.infinity,
                                height: 280,
                                margin: const EdgeInsets.only(
                                  left: 10,
                                  right: 10,
                                  top: 10,
                                ),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.25),
                                      blurRadius: 4.0,
                                      spreadRadius: 0.0,
                                      offset: const Offset(0.0, 4.0),
                                    ),
                                  ],
                                ),
                                // TODO: Create glucose tracking component (MARKER)
                                child: waitForFuture(
                                  future: Future.wait(
                                    [
                                      dbContainer.data!.query("GlucoseRecord"),
                                      dbContainer.data!.query("BMIRecord"),
                                      dbContainer.data!
                                          .query("NutritionRecord"),
                                      dbContainer.data!.query("ActivityRecord"),
                                       dbContainer.data!
                                      .query("MedicationRecordDetails"),
                                      dbContainer.data!
                                      .query("DoctorsAppointmentRecords"),
                                    ],
                                  ),
                                  loading: const SpinKitCircle(color: fgColor),
                                  builder: (context, data) {
                                    if (_glucoseRecords == null ||
                                        _bmiRecords == null ||
                                        _nutritionRecords == null ||
                                        _activityRecords == null) {
                                      final glucoseRecords =
                                          GlucoseRecord.fromListOfMaps(data[0]);

                                      final bmiRecords =
                                          BMIRecord.fromListOfMaps(data[1]);

                                      final nutritionRecords =
                                          NutritionRecord.fromListOfMaps(
                                              data[2]);

                                      final activityRecords =
                                          ActivityRecord.fromListOfMaps(
                                              data[3]);
                                      
                                      final medicationRecordDetails =
                                      MedicationRecordDetails.fromListOfMaps(
                                          data[4]);

                                  final doctorsAppointmentRecords =
                                      DoctorsAppointmentRecord.fromListOfMaps(
                                          data[5]);

                                      glucoseRecords.sort(
                                        (a, b) => a.bloodTestDate
                                            .compareTo(b.bloodTestDate),
                                      );

                                      bmiRecords.sort(
                                        (a, b) =>
                                            a.createdAt.compareTo(b.createdAt),
                                      );

                                      nutritionRecords.sort(
                                        (a, b) =>
                                            a.createdAt.compareTo(b.createdAt),
                                      );

                                      activityRecords.sort(
                                        (a, b) =>
                                            a.createdAt.compareTo(b.createdAt),
                                      );
                                      
                                       doctorsAppointmentRecords.sort((a, b) => a
                                      .appointmentDatetime
                                      .compareTo(b.appointmentDatetime));

                                      Future.delayed(Duration.zero, () {
                                        setState(() {
                                          _glucoseRecords = glucoseRecords;
                                          _bmiRecords = bmiRecords;
                                          _nutritionRecords = nutritionRecords;
                                          _activityRecords = activityRecords;
                                          _medicationRecordDetails =
                                          medicationRecordDetails;
                                      _doctorsAppointmentRecords =
                                          doctorsAppointmentRecords;
                                        });
                                      });
                                    }

                                    if (_glucoseRecords == null) {
                                      return const SpinKitCircle(
                                          color: fgColor);
                                    }

                                    return Column(
                                      children: [
                                        const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(width: 20),
                                            Text(
                                              "Glucose Level",
                                              style: TextStyle(fontSize: 20),
                                            ),
                                            Icon(
                                              Icons.info_outline,
                                              color: fgColor,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 30,
                                          ),
                                          child: Material(
                                            elevation: 5,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Container(
                                              height: 55,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: const Color(0xFF67E88B),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 100,
                                              child: Column(
                                                children: [
                                                  Container(
                                                    width: 3,
                                                    height: 20,
                                                    color:
                                                        const Color(0xFFCBCF10),
                                                  ),
                                                  const Text("Latest"),
                                                  const SizedBox(height: 5),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Builder(
                                                        builder: (context) {
                                                          if (_glucoseRecords ==
                                                                  null ||
                                                              _glucoseRecords!
                                                                  .isEmpty) {
                                                            return const Text(
                                                              "--",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 20,
                                                              ),
                                                            );
                                                          }

                                                          return Text(
                                                            _glucoseRecords!
                                                                .last
                                                                .glucoseLevel
                                                                .toStringAsFixed(
                                                                    2),
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      const SizedBox(width: 3),
                                                      const Text(
                                                        "mmol/L",
                                                        style: TextStyle(
                                                          color:
                                                              Colors.blueGrey,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: 100,
                                              child: Column(
                                                children: [
                                                  Container(
                                                    width: 3,
                                                    height: 20,
                                                    color:
                                                        const Color(0xFF102ECF),
                                                  ),
                                                  const Text("Week Average"),
                                                  const SizedBox(height: 5),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Builder(
                                                        builder: (context) {
                                                          double? average =
                                                              calcAverageGlucoseRecord(
                                                            DateTime.now()
                                                                .subtract(
                                                                    const Duration(
                                                                        days:
                                                                            7)),
                                                            DateTime.now(),
                                                            _glucoseRecords!,
                                                          );

                                                          if (average == null) {
                                                            return const Text(
                                                              "--",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 20,
                                                              ),
                                                            );
                                                          }

                                                          return Text(
                                                            average
                                                                .toStringAsFixed(
                                                                    2),
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      const SizedBox(width: 3),
                                                      const Text(
                                                        "mmol/L",
                                                        style: TextStyle(
                                                          color:
                                                              Colors.blueGrey,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: 100,
                                              child: Column(
                                                children: [
                                                  Container(
                                                    width: 3,
                                                    height: 20,
                                                    color:
                                                        const Color(0xFF866000),
                                                  ),
                                                  const Text("Last Updated"),
                                                  const SizedBox(height: 5),
                                                  LastUpdatedSection(
                                                      records: _glucoseRecords),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 5,
                                          ),
                                          child: const Divider(
                                            color: Colors.black,
                                            endIndent: 20,
                                            indent: 20,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            await Navigator.of(context)
                                                .pushNamed(
                                              "/blood-glucose-tracking/editor",
                                              arguments: {
                                                "user": user,
                                                "db": dbContainer.data!,
                                              },
                                            );

                                            setState(() {
                                              _glucoseRecords = null;
                                            });
                                          },
                                          style: ButtonStyle(
                                            overlayColor:
                                                MaterialStateProperty.all(
                                              Colors.white.withOpacity(0.3),
                                            ),
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                              fgColor,
                                            ),
                                            shape: MaterialStateProperty.all(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                          child: const Text(
                                            "VIEW FULL HISTORY",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                            // Currently empty container
                            Container(
                              margin: const EdgeInsets.only(
                                right: 10,
                                left: 10,
                                top: 15,
                              ),
                              width: double.infinity,
                              height: 68,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 4.0,
                                    spreadRadius: 0.0,
                                    offset: const Offset(0.0, 4.0),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushNamed("/education");
                              },
                              child: Container(
                                margin: const EdgeInsets.only(
                                  right: 10,
                                  left: 10,
                                  top: 15,
                                ),
                                width: double.infinity,
                                padding: const EdgeInsets.all(8),
                                height: 68,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.25),
                                      blurRadius: 4.0,
                                      spreadRadius: 0.0,
                                      offset: const Offset(0.0, 4.0),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD9D9D9),
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      child: Image.asset(
                                          "assets/educational_material_logo.png"),
                                    ),
                                    Text(
                                      "Reading Materials",
                                      style: GoogleFonts.istokWeb(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          ),
                        ),

                        // Currently empty container
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 16,
                            left: 10,
                            right: 10,
                          ),
                          child: Material(
                            borderRadius: BorderRadius.circular(10),
                            elevation: 4,
                            child: GestureDetector(
                              onTap: () async {
                                await Navigator.of(context).pushNamed(
                                    "/doctors-appointment/input",
                                    arguments: {
                                      "user": user,
                                      "db": dbContainer.data!,
                                    });

                                reset();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 12,
                                        left: 15,
                                      ),
                                      child: Row(
                                        // mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.notifications_none,
                                            size: 32,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            "Doctor's Appointment",
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(thickness: 1),
                                    Builder(
                                      builder: (context) {
                                        // debugPrint(
                                        //     "D O C T O R S  A P P O I N T M E N T  R E C O R D S ${_doctorsAppointmentRecords!.first.toMap()}");
                                        if (_doctorsAppointmentRecords ==
                                                null ||
                                            _doctorsAppointmentRecords
                                                    ?.isEmpty ==
                                                true) {
                                          return const Text("No Appointments");
                                        }

                                        DoctorsAppointmentRecord lastRecord =
                                            _doctorsAppointmentRecords!.first;

                                        debugPrint(lastRecord.doctorName);

                                        return Material(
                                          child: Container(
                                            padding: const EdgeInsets.all(15),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Dr. ${lastRecord.doctorName}",
                                                      style: GoogleFonts.inter(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                        lastRecord
                                                            .appointmentPurpose,
                                                        style:
                                                            GoogleFonts.inter(
                                                          fontSize: 12,
                                                        )),
                                                  ],
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      DateFormat("MMMM d, yyyy")
                                                          .format(lastRecord
                                                              .appointmentDatetime),
                                                      style: GoogleFonts.inter(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                      DateFormat("H:mm a")
                                                          .format(lastRecord
                                                              .appointmentDatetime),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const Divider(thickness: 1),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 16,
                            left: 10,
                            right: 10,
                          ),
                          child: AspectRatio(
                            aspectRatio: 1.48,
                            child: Material(
                              borderRadius: BorderRadius.circular(10),
                              elevation: 4,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: GestureDetector(
                                        onTap: () async {
                                          await Navigator.of(context).pushNamed(
                                            "/medication-tracking",
                                            arguments: {
                                              "db": dbContainer.data!,
                                              "user": user
                                            },
                                          );

                                          reset();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.only(
                                            top: 8,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  ShaderMask(
                                                    blendMode: BlendMode.srcIn,
                                                    shaderCallback:
                                                        (Rect bounds) {
                                                      return ui.Gradient.linear(
                                                        const Offset(0.0, 27.0),
                                                        const Offset(0.0, 0.0),
                                                        [
                                                          const Color(
                                                              0xFFF50812),
                                                          const Color(
                                                              0xFF3300FD)
                                                        ],
                                                      );
                                                    },
                                                    child: const Icon(
                                                      Symbols.pill,
                                                      size: 27,
                                                      weight: 500,
                                                    ),
                                                  ),
                                                  Text(
                                                    "MEDICATIONS",
                                                    style:
                                                        GoogleFonts.montserrat(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Builder(builder: (context) {
                                                if (_medicationRecordDetails ==
                                                        null ||
                                                    _medicationRecordDetails!
                                                        .isEmpty) {
                                                  return const Text(
                                                      "  No Medications");
                                                } else {
                                                  final groupedRecords =
                                                      groupBy(
                                                          _medicationRecordDetails!,
                                                          (record) => record
                                                                  .medicationDatetime
                                                                  .copyWith(
                                                                hour: 0,
                                                                minute: 0,
                                                                second: 0,
                                                                millisecond: 0,
                                                                microsecond: 0,
                                                              ));
                                                  // debugPrint(groupedRecords
                                                  //     .values.length
                                                  //     .toString());

                                                  final filtered =
                                                      groupedRecords.keys
                                                          .where((param) {
                                                    return param.isAfter(
                                                        DateTime.now().copyWith(
                                                            day: DateTime.now()
                                                                    .day -
                                                                1));
                                                  }).toList();
                                                  filtered.sort(
                                                    (a, b) => a.compareTo(b),
                                                  );

                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Column(children: [
                                                      ...groupedRecords[
                                                              filtered[0]]!
                                                          .take(4)
                                                          .map((record) {
                                                        return Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const SizedBox(
                                                                  height: 2),
                                                              Text(
                                                                record
                                                                    .medicineName,
                                                                style:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              Text(
                                                                  "To Take -> ${DateFormat("h:mm a").format(record.medicationDatetime)}",
                                                                  style:
                                                                      GoogleFonts
                                                                          .inter(
                                                                    fontSize:
                                                                        10,
                                                                    color: Colors
                                                                        .grey
                                                                        .shade400,
                                                                  )),
                                                            ]);
                                                      })
                                                    ]),
                                                  );
                                                }
                                              }),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: Container(),
                                        ),
                                        Container(
                                          width: 1,
                                          color: const Color(0xFFC4C4C4),
                                        ),
                                        Expanded(
                                          flex: 6,
                                          child: GestureDetector(
                                            onTap: () async {
                                              await Navigator.of(context)
                                                  .pushNamed(
                                                "/bmi-tracking",
                                                arguments: {
                                                  "db": dbContainer.data!,
                                                  "user": user,
                                                },
                                              );

                                              // TODO:
                                              setState(() {
                                                _bmiRecords = null;
                                              });
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.only(
                                                top: 8,
                                              ),
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10),
                                                ),
                                              ),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    "Your Current BMI Level",
                                                    style: GoogleFonts.inter(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Image.asset(
                                                    user.isMale
                                                        ? "assets/bmi_male.png"
                                                        : "assets/bmi_female.png",
                                                    width: 230,
                                                  ),
                                                  const Divider(
                                                    height: 0,
                                                    endIndent: 0,
                                                    indent: 0,
                                                  ),
                                                  Expanded(
                                                    child: Builder(
                                                      builder: (context) {
                                                        if (_bmiRecords ==
                                                            null) {
                                                          // TODO: Loading
                                                          return Container();
                                                        } else if (_bmiRecords!
                                                            .isEmpty) {
                                                          // TODO: No Data
                                                          return const Align(
                                                            alignment: Alignment
                                                                .center,
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          8.0),
                                                              child:
                                                                  AutoSizeText(
                                                                "Please enter your Body Mass Index (BMI)",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                maxLines: 2,
                                                                minFontSize: 4,
                                                              ),
                                                            ),
                                                          );
                                                        }

                                                        final latestBmiRecord =
                                                            _bmiRecords!.first;
                                                        double fraction;

                                                        if (latestBmiRecord
                                                                .bmi <
                                                            19) {
                                                          fraction = 0.23 *
                                                              (latestBmiRecord
                                                                      .bmi /
                                                                  19.0);
                                                        } else if (latestBmiRecord
                                                                    .bmi >=
                                                                19 &&
                                                            latestBmiRecord
                                                                    .bmi <=
                                                                24) {
                                                          fraction = (0.27 *
                                                                  ((latestBmiRecord
                                                                              .bmi -
                                                                          19) /
                                                                      5)) +
                                                              0.23;
                                                        } else if (latestBmiRecord
                                                                    .bmi >
                                                                24 &&
                                                            latestBmiRecord
                                                                    .bmi <=
                                                                29) {
                                                          fraction = (0.27 *
                                                                  ((latestBmiRecord
                                                                              .bmi -
                                                                          24) /
                                                                      5)) +
                                                              0.5;
                                                        } else {
                                                          fraction = clampDouble(
                                                              (0.23 *
                                                                  ((latestBmiRecord
                                                                              .bmi -
                                                                          29) /
                                                                      11)),
                                                              0,
                                                              1);
                                                        }

                                                        return BMIGraph(
                                                            frac: fraction);
                                                      },
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
                                ),
                              ),
                            ),
                            NutritionAndActivity(
                              db: dbContainer.data!,
                              resetNutritionRecords: resetNutritionRecords,
                              resetActivityRecords: resetActivityRecords,
                              nutritionRecords: _nutritionRecords ?? [],
                              activityRecords: _activityRecords ?? [],
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
        const EmergencyNumbers(),
      ],
    );
  }

  generatePdfFile() async {
    final path = await FilePicker.platform.getDirectoryPath();
    if (!await Permission.storage.status.isGranted) {
      await Permission.storage.request();
    }

    if (path == null) {
      return;
    }

    final pdf = pw.Document();
    final img = await rootBundle.load('assets/dialife_launcher_logo.png');

    final italianno = await PdfGoogleFonts.italiannoRegular();
    final montserrat = await PdfGoogleFonts.montserratRegular();
    final montserratBold = await PdfGoogleFonts.montserratBold();

    final weekScope = DateScope.week(DateTime.now());
    final glucoseRecords = (_glucoseRecords ?? [])
        .reversed
        .where((rec) =>
            weekScope.start.isBefore(rec.bloodTestDate) &&
            weekScope.end.isAfter(rec.bloodTestDate))
        .toList();

    final activityRecords = (_activityRecords ?? [])
        .reversed
        .where((rec) =>
            weekScope.start.isBefore(rec.createdAt) &&
            weekScope.end.isAfter(rec.createdAt))
        .toList();

    final activityRecordsByDay = dayConsolidateActivityRecord(activityRecords);
    final activityRecordsValidDays =
        validDaysActivityRecord(activityRecords).reversed;

    final nutritionRecords = (_nutritionRecords ?? []).reversed;

    BMIRecord? latestBMIRecord;
    if (_bmiRecords == null || _bmiRecords!.isEmpty) {
      latestBMIRecord = null;
    } else {
      latestBMIRecord = _bmiRecords?.reversed.first;
    }

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 32,
        ),
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Expanded(child: pw.SizedBox()),
                  pw.Image(
                    pw.MemoryImage(img.buffer.asUint8List()),
                    width: 48,
                  ),
                  pw.SizedBox(width: 12),
                  pw.Text(
                    "Dialife",
                    style: pw.TextStyle(
                      font: italianno,
                      color: PdfColor.fromInt(
                        fgColor.alpha |
                            fgColor.red >> 8 |
                            fgColor.green >> 16 |
                            fgColor.blue >> 24,
                      ),
                      fontSize: 32,
                    ),
                  ),
                  pw.Expanded(child: pw.SizedBox()),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                      text: "Name:   ",
                      style: pw.TextStyle(font: montserrat),
                    ),
                    pw.TextSpan(
                      text: _user.name,
                      style: pw.TextStyle(
                        font: montserratBold,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 5),
              pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                      text: "Age & Sex:   ",
                      style: pw.TextStyle(font: montserrat),
                    ),
                    pw.TextSpan(
                      text:
                          "${(_user.exactAge.inDays / 365).floor()}, ${_user.isMale ? "Male" : "Female"}",
                      style: pw.TextStyle(
                        font: montserratBold,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 5),
              pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                      text: "Birthday:   ",
                      style: pw.TextStyle(font: montserrat),
                    ),
                    pw.TextSpan(
                      text: DateFormat("MMM. dd, yyyy").format(_user.birthday),
                      style: pw.TextStyle(
                        font: montserratBold,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 5),
              pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                      text: "Contact No.:   ",
                      style: pw.TextStyle(font: montserrat),
                    ),
                    pw.TextSpan(
                      text: _user.contactNumber,
                      style: pw.TextStyle(
                        font: montserratBold,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 5),
              pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                      text: "Address:   ",
                      style: pw.TextStyle(font: montserrat),
                    ),
                    pw.TextSpan(
                      text:
                          "Brgy. ${_user.barangay.toLowerCase().capitalize()}, ${_user.municipality.toLowerCase().capitalize()}, ${_user.province.toLowerCase().capitalize()}",
                      style: pw.TextStyle(
                        font: montserratBold,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 5),
              pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                      text: "BMI Level:   ",
                      style: pw.TextStyle(font: montserrat),
                    ),
                    pw.TextSpan(
                      text: latestBMIRecord == null
                          ? "(No Data)"
                          : "${latestBMIRecord.bmi.toStringAsFixed(2)} (${DateFormat("MMM. dd, yyyy").format(latestBMIRecord.createdAt)})",
                      style: pw.TextStyle(
                        font: montserratBold,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),
              pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                      text: "Glucose Log (7 days): \n",
                      style: pw.TextStyle(font: montserratBold),
                    ),
                    pw.WidgetSpan(
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.only(top: 8),
                        child: pw.Table(
                          border: pw.TableBorder.all(),
                          children: <pw.TableRow>[
                            pw.TableRow(
                              children: [
                                pw.Text(
                                  "Date",
                                  textAlign: pw.TextAlign.center,
                                ),
                                pw.Text(
                                  "Glucose Level",
                                  textAlign: pw.TextAlign.center,
                                ),
                              ],
                            ),
                            ...[
                              () {
                                if (glucoseRecords.isEmpty) {
                                  return pw.TableRow(
                                    children: [
                                      pw.Padding(
                                        padding:
                                            const pw.EdgeInsets.only(left: 8),
                                        child: pw.Text("(No Data)"),
                                      ),
                                      pw.Padding(
                                        padding:
                                            const pw.EdgeInsets.only(left: 8),
                                        child: pw.Text("(No Data)"),
                                      ),
                                    ],
                                  );
                                }

                                return null;
                              }()
                            ].whereNotNull(),
                            ...glucoseRecords.map((rec) {
                              return pw.TableRow(
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.only(left: 8),
                                    child: pw.Text(
                                      DateFormat("MMM. dd, hh:mm a")
                                          .format(rec.bloodTestDate),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.only(left: 8),
                                    child: pw.Text(
                                        "${rec.glucoseLevel} mmol/L or ${mmolLToMgDL(rec.glucoseLevel)} mg/dL${rec.isA1C ? " (A1C)" : ""}"),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
              pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                      text: "Activity Log (7 days): \n",
                      style: pw.TextStyle(font: montserratBold),
                    ),
                    pw.WidgetSpan(
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.only(top: 8),
                        child: pw.Table(
                          border: pw.TableBorder.all(),
                          children: <pw.TableRow>[
                            pw.TableRow(
                              children: [
                                pw.Text(
                                  "Date",
                                  textAlign: pw.TextAlign.center,
                                ),
                                pw.Text(
                                  "Type",
                                  textAlign: pw.TextAlign.center,
                                ),
                                pw.Text(
                                  "Frequency",
                                  textAlign: pw.TextAlign.center,
                                ),
                                pw.Text(
                                  "Duration",
                                  textAlign: pw.TextAlign.center,
                                ),
                              ],
                            ),
                            ...[
                              () {
                                if (activityRecords.isEmpty) {
                                  return pw.TableRow(
                                    children: [
                                      pw.Padding(
                                        padding:
                                            const pw.EdgeInsets.only(left: 8),
                                        child: pw.Text("(No Data)"),
                                      ),
                                      pw.Padding(
                                        padding:
                                            const pw.EdgeInsets.only(left: 8),
                                        child: pw.Text("(No Data)"),
                                      ),
                                      pw.Padding(
                                        padding:
                                            const pw.EdgeInsets.only(left: 8),
                                        child: pw.Text("(No Data)"),
                                      ),
                                      pw.Padding(
                                        padding:
                                            const pw.EdgeInsets.only(left: 8),
                                        child: pw.Text("(No Data)"),
                                      ),
                                    ],
                                  );
                                }

                                return null;
                              }()
                            ].whereNotNull(),
                            ...(activityRecordsValidDays
                                .map((date) {
                                  final records = activityRecordsByDay[date]!;

                                  return records.map((rec) {
                                    return pw.TableRow(
                                      children: [
                                        pw.Padding(
                                          padding:
                                              const pw.EdgeInsets.only(left: 8),
                                          child: pw.Text(
                                            DateFormat("MMM. dd, hh:mm a")
                                                .format(rec.createdAt),
                                          ),
                                        ),
                                        pw.Padding(
                                          padding:
                                              const pw.EdgeInsets.only(left: 8),
                                          child: pw.Text(rec.type.asString),
                                        ),
                                        pw.Padding(
                                          padding:
                                              const pw.EdgeInsets.only(left: 8),
                                          child:
                                              pw.Text(rec.frequency.toString()),
                                        ),
                                        pw.Padding(
                                          padding:
                                              const pw.EdgeInsets.only(left: 8),
                                          child:
                                              pw.Text("${rec.duration} mins"),
                                        ),
                                      ],
                                    );
                                  }).toList();
                                })
                                .flattened
                                .toList()),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.Expanded(child: pw.SizedBox()),
              pw.Text(
                "Generated On: ${DateTime.now()}",
                style: const pw.TextStyle(fontSize: 8),
              ),
            ],
          );
        },
      ),
    );

    pdf.addPage(pw.Page(
      margin: const pw.EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 32,
      ),
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Expanded(child: pw.SizedBox()),
                pw.Image(
                  pw.MemoryImage(img.buffer.asUint8List()),
                  width: 48,
                ),
                pw.SizedBox(width: 12),
                pw.Text(
                  "Dialife",
                  style: pw.TextStyle(
                    font: italianno,
                    color: PdfColor.fromInt(
                      fgColor.alpha |
                          fgColor.red >> 8 |
                          fgColor.green >> 16 |
                          fgColor.blue >> 24,
                    ),
                    fontSize: 32,
                  ),
                ),
                pw.Expanded(child: pw.SizedBox()),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.RichText(
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(
                    text: "Nutrition Log (7 days): \n",
                    style: pw.TextStyle(font: montserratBold),
                  ),
                  pw.WidgetSpan(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 8),
                      child: pw.Table(
                        border: pw.TableBorder.all(),
                        children: <pw.TableRow>[
                          pw.TableRow(
                            children: [
                              pw.Text(
                                "Date",
                                textAlign: pw.TextAlign.center,
                              ),
                              pw.Text(
                                "Protein",
                                textAlign: pw.TextAlign.center,
                              ),
                              pw.Text(
                                "Fats",
                                textAlign: pw.TextAlign.center,
                              ),
                              pw.Text(
                                "Carbohydrates",
                                textAlign: pw.TextAlign.center,
                              ),
                              pw.Text(
                                "Glasses of Water",
                                textAlign: pw.TextAlign.center,
                              ),
                            ],
                          ),
                          ...[
                            () {
                              if (nutritionRecords.isEmpty) {
                                return pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding:
                                          const pw.EdgeInsets.only(left: 8),
                                      child: pw.Text("(No Data)"),
                                    ),
                                    pw.Padding(
                                      padding:
                                          const pw.EdgeInsets.only(left: 8),
                                      child: pw.Text("(No Data)"),
                                    ),
                                    pw.Padding(
                                      padding:
                                          const pw.EdgeInsets.only(left: 8),
                                      child: pw.Text("(No Data)"),
                                    ),
                                    pw.Padding(
                                      padding:
                                          const pw.EdgeInsets.only(left: 8),
                                      child: pw.Text("(No Data)"),
                                    ),
                                    pw.Padding(
                                      padding:
                                          const pw.EdgeInsets.only(left: 8),
                                      child: pw.Text("(No Data)"),
                                    ),
                                  ],
                                );
                              }

                              return null;
                            }()
                          ].whereNotNull(),
                          ...nutritionRecords.map((rec) {
                            return pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.only(left: 8),
                                  child: pw.Text(
                                    DateFormat("MMM. dd, hh:mm a")
                                        .format(rec.createdAt),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.only(left: 8),
                                  child: pw.Text(
                                    "${rec.proteinInGrams.toStringAsFixed(2)} grams",
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.only(left: 8),
                                  child: pw.Text(
                                    "${rec.fatsInGrams.toStringAsFixed(2)} grams",
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.only(left: 8),
                                  child: pw.Text(
                                    "${rec.carbohydratesInGrams.toStringAsFixed(2)} grams",
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.only(left: 8),
                                  child: pw.Text(
                                    "${rec.glassesOfWater.toString()} ${rec.glassesOfWater > 1 ? "glasses" : "glass"}",
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.Expanded(child: pw.SizedBox()),
            pw.Text(
              "Generated On: ${DateTime.now()}",
              style: const pw.TextStyle(fontSize: 8),
            ),
          ],
        );
      },
    ));

    final directory = Directory(path);
    final file = File(join(directory.path, "patient-data.pdf"));

    if (await file.exists()) {
      await file.delete();
    }

    await file.writeAsBytes(await pdf.save());
    await file.create();
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
    assert(frac >= 0 && frac <= 1);

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

    return Stack(
      children: [
        const Positioned.fill(
          bottom: 20,
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
            padding: const EdgeInsets.only(
              left: 7,
              right: 7,
              top: 10,
              bottom: 30,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: frontOffset,
                  child: const SizedBox(),
                ),
                Container(
                  constraints: const BoxConstraints(maxHeight: 30),
                  decoration: BoxDecoration(
                    color: pointerColor,
                    boxShadow: const [
                      BoxShadow(
                        spreadRadius: 3,
                        offset: Offset(0, 0),
                        color: Colors.white,
                      )
                    ],
                  ),
                  width: 2,
                ),
                Expanded(
                  flex: backOffset,
                  child: const SizedBox(),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 8.0,
                left: 4,
                right: 4,
              ),
              child: AutoSizeText.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "$category, ",
                      style: GoogleFonts.inter(
                        color: pointerColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: description,
                      style: GoogleFonts.inter(
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                minFontSize: 4,
                overflow: TextOverflow.fade,
                maxLines: 1,
              ),
            ),
          ),
        ),
      ],
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
          protein DECIMAL(5, 2) NOT NULL,
          fat DECIMAL(5, 2) NOT NULL,
          carbohydrates DECIMAL(5, 2) NOT NULL,
          water INTEGER NOT NULL,
          notes VARCHAR(255) NOT NULL,
          created_at DATETIME NOT NULL
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
          FOREIGN KEY(medication_reminder_record_id) REFERENCES MedicationReminderRecords(id)

        )
      """);

      await db.execute("""

        CREATE TABLE Doctor (
          id INTEGER PRIMARY KEY NOT NULL,
          facebook_id VARCHAR(20) NOT NULL,
          name VARCHAR(255) NOT NULL,
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
          appointment_purpose VARCHAR(255) NOT NULL
        )
      """);

      // return db.execute(
      //     "INSERT INTO BMIRecord (height, weight, created_at, notes) VALUES (1.73, 77.08, '2023-10-13', 'After lunch'), (1.73, 77.5, '2023-10-12', 'Before bed'), (1.73, 78.2, '2023-10-11', 'Deserunt deserunt eu duis sit minim deserunt et aute et ea dolore.')");

    },
    version: 2,
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
