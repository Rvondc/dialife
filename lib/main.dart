import 'package:dialife/blood_glucose_tracking/calculate_average.dart';
import 'package:dialife/blood_glucose_tracking/entities.dart';
import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:dialife/blood_glucose_tracking/input_form.dart';
import 'package:dialife/blood_glucose_tracking/record_editor.dart';
import 'package:dialife/blood_glucose_tracking/utils.dart';
import 'package:dialife/bmi_tracking/bmi_tracking.dart';
import 'package:dialife/bmi_tracking/input_form.dart';
import 'package:dialife/bmi_tracking/record_editor.dart';
import 'package:dialife/local_notifications/local_notifications.dart';
import 'package:dialife/medication_tracking/medication_tracking.dart';
import 'package:dialife/setup.dart';
import 'package:dialife/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:google_fonts/google_fonts.dart';

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
                user: args["user"],
              ),
              settings: const RouteSettings(name: "/blood-glucose-tracking"),
            );
          case "/blood-glucose-tracking/editor":
            return MaterialPageRoute(
              builder: (context) => const GlucoseRecordEditor(),
              settings:
                  const RouteSettings(name: "/blood-glucose-tracking/editor"),
            );
          case "/blood-glucose-tracking/input":
            final args = settings.arguments as Map<String, dynamic>;

            return MaterialPageRoute(
              builder: (context) => GlucoseRecordInputForm(
                existing: null,
                user: args["user"],
              ),
              settings:
                  const RouteSettings(name: "/blood-glucose-tracking/input"),
            );
          case "/bmi-tracking":
            final args = settings.arguments as Map<String, dynamic>;

            return MaterialPageRoute(
              builder: (context) => BMITracking(
                user: args["user"],
              ),
              settings: const RouteSettings(name: "/bmi-tracking"),
            );
          case "/bmi-tracking/editor":
            return MaterialPageRoute(
              builder: (context) => const BMIRecordEditor(),
              settings: const RouteSettings(name: "/bmi-tracking/editor"),
            );
          case "/bmi-tracking/input":
            return MaterialPageRoute(
              builder: (context) => const BMIRecordForm(),
              settings: const RouteSettings(name: "/bmi-tracking/input"),
            );
          case "/insulin-tracking":
            return MaterialPageRoute(
              builder: (context) => const InsulinTracking(),
              settings: const RouteSettings(name: "/insulin-tracking"),
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
  List<GlucoseRecord>? _records;

  @override
  Widget build(BuildContext context) {
    reset() {
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
                future: dbContainer.data!.query("User"),
                builder: (context, data) {
                  if (data.connectionState != ConnectionState.done ||
                      data.data == null) {
                    return loading;
                  }

                  if (data.data!.isEmpty) {
                    return SafeArea(
                      child: UserSetup(
                        reset: reset,
                        db: dbContainer.data!,
                      ),
                    );
                  }

                  final user = User.fromMap(data.data!.first);

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
                        Text(
                          'Current Health Status',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // Container for health progress bar
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              "/blood-glucose-tracking",
                              arguments: {"user": user},
                            );
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
                              future: dbContainer.data!.query("GlucoseRecord"),
                              loading: const SpinKitCircle(color: fgColor),
                              builder: (context, data) {
                                if (_records == null) {
                                  // final records =
                                  //     GlucoseRecord.fromListOfMaps(data);

                                  final records =
                                      GlucoseRecord.mock(count: 30, daySpan: 5);

                                  records.sort(
                                    (a, b) => a.bloodTestDate
                                        .compareTo(b.bloodTestDate),
                                  );

                                  Future.delayed(Duration.zero, () {
                                    setState(() {
                                      _records = records;
                                    });
                                  });
                                }

                                if (_records == null) {
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
                                                  Text(
                                                    _records!.last.glucoseLevel
                                                        .toStringAsFixed(2),
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20,
                                                    ),
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
                                                        _records!,
                                                      );

                                                      if (average == null) {
                                                        return const Text(
                                                            "No Data");
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
                                                  records: _records),
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
                                      onPressed: () {
                                        Navigator.of(context).pushNamed(
                                            "/blood-glucose-tracking/editor",
                                            arguments: {"user": user});
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

                        // Empty containers
                        Container(
                          margin: const EdgeInsets.only(
                            right: 10,
                            left: 10,
                            top: 15,
                          ),
                          height: 224,
                          child: Row(
                            children: [
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // NOTE: Medication
                                  Container(
                                    width: 114,
                                    height: 104,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.25),
                                          blurRadius: 4,
                                          spreadRadius: 0,
                                          offset: const Offset(0, 4),
                                        )
                                      ],
                                    ),
                                    child: Center(
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.notifications,
                                          size: 35,
                                        ),
                                        onPressed: () {
                                          // Navigator.pushNamed(
                                          //     context, '/notifPage');
                                        },
                                      ),
                                    ),
                                  ),
                                  // NOTE: BMI
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pushNamed(
                                          "/bmi-tracking",
                                          arguments: {"user": user});
                                    },
                                    child: Container(
                                      width: 114,
                                      height: 104,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.25),
                                            blurRadius: 4,
                                            spreadRadius: 0,
                                            offset: const Offset(0, 4),
                                          )
                                        ],
                                      ),
                                      // TODO: implement BMI tracking (MARKER)
                                      child: Column(
                                        children: [],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.25),
                                        blurRadius: 4,
                                        spreadRadius: 0,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // empty container
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

class LastUpdatedSection extends StatelessWidget {
  const LastUpdatedSection({
    super.key,
    required List<GlucoseRecord>? records,
  }) : _records = records;

  final List<GlucoseRecord>? _records;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          DateTime.now()
              .difference(_records!.last.bloodTestDate)
              .inHours
              .toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(width: 3),
        const Text(
          "Hours Ago",
          style: TextStyle(
            color: Colors.blueGrey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
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
    },
    version: 1,
  );
}
