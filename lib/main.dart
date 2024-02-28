import 'dart:ui' as ui;
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
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
import 'package:dialife/setup.dart';
import 'package:dialife/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        useMaterial3: true,
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case "/":
            return MaterialPageRoute(
              builder: (context) => const Root(),
              settings: const RouteSettings(name: "/"),
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
  List<DoctorsAppointmentRecord>? _doctorsAppointmentRecords;
  List<MedicationRecordDetails>? _medicationRecordDetails;

  @override
  Widget build(BuildContext context) {
    void reset() {
      setState(() {});
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade200,
        toolbarHeight: 40,
        elevation: 0,
        leading: IconButton(
          hoverColor: Colors.transparent,
          onPressed: () {},
          icon: const Icon(
            Icons.person_outline,
            color: Colors.black,
            size: 24,
          ),
        ),
        actions: [
          IconButton(
            hoverColor: Colors.transparent,
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert,
              color: Colors.black,
              size: 24,
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
                    for (var element in provinceList) element.key: element.value
                  };

                  if (data.data![0].isEmpty) {
                    return SafeArea(
                      child: UserSetup(
                        reset: reset,
                        provinceMap: provinceMap,
                        db: dbContainer.data!,
                      ),
                    );
                  }

                  final user = User.fromMap(data.data![0].first);

                  return Container(
                    constraints: const BoxConstraints.expand(),
                    child: ListView(
                      children: [
                        Text(
                          'DiaLife',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.italianno(
                            fontSize: 59,
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
                                      .query("MedicationRecordDetails"),
                                  dbContainer.data!
                                      .query("DoctorsAppointmentRecords"),
                                ],
                              ),
                              loading: const SpinKitCircle(color: fgColor),
                              builder: (context, data) {
                                if (_glucoseRecords == null ||
                                    _bmiRecords == null ||
                                    _medicationRecordDetails == null ||
                                    _doctorsAppointmentRecords == null) {
                                  final glucoseRecords =
                                      GlucoseRecord.fromListOfMaps(data[0]);

                                  final bmiRecords =
                                      BMIRecord.fromListOfMaps(data[1]);

                                  final medicationRecordDetails =
                                      MedicationRecordDetails.fromListOfMaps(
                                          data[2]);

                                  final doctorsAppointmentRecords =
                                      DoctorsAppointmentRecord.fromListOfMaps(
                                          data[3]);

                                  glucoseRecords.sort(
                                    (a, b) => a.bloodTestDate
                                        .compareTo(b.bloodTestDate),
                                  );

                                  bmiRecords.sort(
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
                                      _medicationRecordDetails =
                                          medicationRecordDetails;
                                      _doctorsAppointmentRecords =
                                          doctorsAppointmentRecords;
                                    });
                                  });
                                }

                                if (_glucoseRecords == null) {
                                  return const SpinKitCircle(color: fgColor);
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
                                                color: const Color(0xFFCBCF10),
                                              ),
                                              const Text("Latest"),
                                              const SizedBox(height: 5),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
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
                                                                FontWeight.bold,
                                                            fontSize: 20,
                                                          ),
                                                        );
                                                      }

                                                      return Text(
                                                        _glucoseRecords!
                                                            .last.glucoseLevel
                                                            .toStringAsFixed(2),
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 20,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  const SizedBox(width: 3),
                                                  const Text(
                                                    "mmol/L",
                                                    style: TextStyle(
                                                      color: Colors.blueGrey,
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
                                                color: const Color(0xFF102ECF),
                                              ),
                                              const Text("Week Average"),
                                              const SizedBox(height: 5),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Builder(
                                                    builder: (context) {
                                                      double? average =
                                                          calcAverageGlucoseRecord(
                                                        DateTime.now().subtract(
                                                            const Duration(
                                                                days: 7)),
                                                        DateTime.now(),
                                                        _glucoseRecords!,
                                                      );

                                                      if (average == null) {
                                                        return const Text(
                                                          "--",
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 20,
                                                          ),
                                                        );
                                                      }

                                                      return Text(
                                                        average
                                                            .toStringAsFixed(2),
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 20,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  const SizedBox(width: 3),
                                                  const Text(
                                                    "mmol/L",
                                                    style: TextStyle(
                                                      color: Colors.blueGrey,
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
                                                color: const Color(0xFF866000),
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
                                        await Navigator.of(context).pushNamed(
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
                                        overlayColor: MaterialStateProperty.all(
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
                                    Container(
                                      width: 1,
                                      color: const Color(0xFFC4C4C4),
                                    ),
                                    Expanded(
                                      flex: 6,
                                      child: GestureDetector(
                                        onTap: () async {
                                          await Navigator.of(context).pushNamed(
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
                                              bottomRight: Radius.circular(10),
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Text(
                                                "Your Current BMI Level",
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
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
                                                    if (_bmiRecords == null) {
                                                      // TODO: Loading
                                                      return Container();
                                                    } else if (_bmiRecords!
                                                        .isEmpty) {
                                                      // TODO: No Data
                                                      return const Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      8.0),
                                                          child: AutoSizeText(
                                                            "Please enter your Body Mass Index (BMI)",
                                                            textAlign: TextAlign
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

                                                    if (latestBmiRecord.bmi <
                                                        19) {
                                                      fraction = 0.23 *
                                                          (latestBmiRecord.bmi /
                                                              19.0);
                                                    } else if (latestBmiRecord
                                                                .bmi >=
                                                            19 &&
                                                        latestBmiRecord.bmi <=
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
                                                        latestBmiRecord.bmi <=
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
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 15,
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
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
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

Future<Database> initAppDatabase(String path) async {
  return openDatabase(
    join(path, "app.db"),
    onCreate: (db, version) async {
      await db.execute("""
        CREATE TABLE User (
          id INTEGER NOT NULL PRIMARY KEY,
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
        CREATE TABLE MedicationReminderRecords (
          id INTEGER PRIMARY KEY NOT NULL,
          starts_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
          ends_at DATETIME NOT NULL
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
          FOREIGN KEY(medication_reminder_record_id) REFERENCES MedicationReminderRecords(id)
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
    version: 1,
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
