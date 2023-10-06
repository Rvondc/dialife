import 'package:dialife/blood_glucose_tracking/blood_glucose_tracking.dart';
import 'package:dialife/bmi_tracking/bmi_tracking.dart';
import 'package:dialife/insulin_tracking/insulin_tracking.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
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
              builder: (context) => const BloodGlucoseTracking(),
              settings: const RouteSettings(name: "/blood-glucose-tracking"),
            );
          case "/bmi-tracking":
            return MaterialPageRoute(
              builder: (context) => const BMITracking(),
              settings: const RouteSettings(name: "/bmi-tracking"),
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

    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: Text(widget.title),
      // ),
      body: Container(
        color: const Color.fromARGB(255, 100, 44, 141),
        constraints: const BoxConstraints.expand(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Sample Landing Page",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            Container(
              margin: const EdgeInsets.all(margin),
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed("/blood-glucose-tracking");
                },
                child: const Text("Blood Glucose Tracking"),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(margin),
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed("/insulin-tracking");
                },
                child: const Text("Insulin and Medication Tracking"),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(margin),
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed("/bmi-tracking");
                },
                child: const Text("Weight and BMI Tracking"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
