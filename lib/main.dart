import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:dialife/blood_glucose_tracking/input_form.dart';
import 'package:dialife/blood_glucose_tracking/record_editor.dart';
import 'package:dialife/bmi_tracking/bmi_tracking.dart';
import 'package:dialife/bmi_tracking/input_form.dart';
import 'package:dialife/bmi_tracking/record_editor.dart';
import 'package:dialife/insulin_tracking/insulin_tracking.dart';
import 'package:dialife/setup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
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
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
            return MaterialPageRoute(
              builder: (context) => const GlucoseTracking(),
              settings: const RouteSettings(name: "/blood-glucose-tracking"),
            );
          case "/blood-glucose-tracking/editor":
            return MaterialPageRoute(
              builder: (context) => const GlucoseRecordEditor(),
              settings:
                  const RouteSettings(name: "/blood-glucose-tracking/editor"),
            );
          case "/blood-glucose-tracking/input":
            return MaterialPageRoute(
              builder: (context) =>
                  const GlucoseRecordInputForm(existing: null),
              settings:
                  const RouteSettings(name: "/blood-glucose-tracking/input"),
            );
          case "/bmi-tracking":
            return MaterialPageRoute(
              builder: (context) => const BMITracking(),
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
  @override
  Widget build(BuildContext context) {
    const double margin = 8;

    reset() {
      setState(() {});
    }

    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // title: Text(widget.title),

        toolbarHeight: 40,
        elevation: 0,
        backgroundColor: Colors.transparent,
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
            future: initUserDatabase(data.data!),
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

                  return Container(
                    color: const Color.fromARGB(255, 100, 64, 141),
                    constraints: const BoxConstraints.expand(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // const Text(
                        //   "Sample Landing Page",
                        //   style: TextStyle(fontSize: 20, color: Colors.white),
                        // ),
                        // Container(
                        //   margin: const EdgeInsets.all(margin),
                        //   child: TextButton(
                        //     style: ButtonStyle(
                        //       backgroundColor:
                        //           MaterialStateProperty.all(Colors.white),
                        //     ),
                        //     onPressed: () {
                        //       Navigator.of(context)
                        //           .pushNamed("/blood-glucose-tracking");
                        //     },
                        //     child: const Text("Blood Glucose Tracking"),
                        //   ),
                        // ),
                        // Container(
                        //   margin: const EdgeInsets.all(margin),
                        //   child: TextButton(
                        //     style: ButtonStyle(
                        //       backgroundColor:
                        //           MaterialStateProperty.all(Colors.white),
                        //     ),
                        //     onPressed: () {
                        //       Navigator.of(context)
                        //           .pushNamed("/insulin-tracking");
                        //     },
                        //     child:
                        //         const Text("Insulin and Medication Tracking"),
                        //   ),
                        // ),
                        // Container(
                        //   margin: const EdgeInsets.all(margin),
                        //   child: TextButton(
                        //     style: ButtonStyle(
                        //       backgroundColor:
                        //           MaterialStateProperty.all(Colors.white),
                        //     ),
                        //     onPressed: () {
                        //       Navigator.of(context).pushNamed("/bmi-tracking");
                        //     },
                        //     child: const Text("Weight and BMI Tracking"),
                        //   ),
                        // ),

                        Text(
                          'DiaLife',
                          style: GoogleFonts.italianno(
                            fontSize: 59,
                            color: const Color.fromRGBO(76, 102, 240, 1.0),
                          ),
                        ),
                        // Current health status text label
                        Center(
                          child: SizedBox(
                            height: 23,
                            width: 198,
                            child: Text(
                              'Current Health Status',
                              style: GoogleFonts.inter(
                                fontSize: 19,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        // Container for health progress bar
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 8.0,
                            left: 30.0,
                            right: 30.0,
                          ),
                          child: Container(
                            width: double.infinity,
                            height: 280,
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
                            child: Column(
                              children: [
                                // GestureDetector(
                                //   onTap: () {
                                //     Navigator.pushNamed(context, '/ui');
                                //   },
                                //   child: const Padding(
                                //     padding: EdgeInsets.only(
                                //       top: 39.0,
                                //       left: 31.0,
                                //       right: 31.0,
                                //     ),
                                //     child: GlucoseStatusBar(),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ),

                        // Currently empty container
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 18.0,
                            left: 30.0,
                            right: 30.0,
                          ),
                          child: Container(
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
                        ),

                        // Empty containers
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 18.0,
                            left: 30.0,
                            right: 30.0,
                          ),
                          child: SizedBox(
                            height: 224,
                            child: Row(
                              children: [
                                Column(
                                  children: [
                                    Container(
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
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16.0),
                                      child: Container(
                                        width: 114,
                                        height: 104,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.25),
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
                                const SizedBox(
                                  width: 11.0,
                                ),
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
                        ),

                        // empty container
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 16.0,
                            left: 30.0,
                            right: 30.0,
                          ),
                          child: Container(
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

Future<Database> initUserDatabase(String path) async {
  return openDatabase(
    join(path, "user.db"),
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
    },
    version: 1,
  );
}
