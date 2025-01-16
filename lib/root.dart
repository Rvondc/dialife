import 'package:carousel_slider/carousel_slider.dart';
import 'package:dialife/activity_log/entities.dart';
import 'package:dialife/blood_glucose_tracking/entities.dart';
import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:dialife/bmi_tracking/entities.dart';
import 'package:dialife/carousel_items/activity_carousel.dart';
import 'package:dialife/carousel_items/bmi_carousel.dart';
import 'package:dialife/carousel_items/glucose_carousel.dart';
import 'package:dialife/carousel_items/medication_reminder_carousel.dart';
import 'package:dialife/carousel_items/nutrition_carousel.dart';
import 'package:dialife/carousel_items/reading_material_carousel.dart';
import 'package:dialife/carousel_items/water_intake_carousel.dart';
import 'package:dialife/doctors_appointment/entities.dart';
import 'package:collection/collection.dart';
import 'package:dialife/main.dart';
import 'package:dialife/medication_tracking/entities.dart';
import 'package:dialife/nutrition_log/entities.dart';
import 'package:dialife/passcode.dart';
import 'package:dialife/setup.dart';
import 'package:dialife/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite/sqflite.dart';

class Root extends StatefulWidget {
  const Root({super.key});

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  late List<GlucoseRecord> _glucoseRecords;
  late List<BMIRecord> _bmiRecords;
  late List<NutritionRecord> _nutritionRecords;
  late List<ActivityRecord> _activityRecords;
  late List<WaterRecord> _waterRecords;
  late List<DoctorsAppointmentRecord> _doctorsAppointmentRecords;
  late List<MedicationRecordDetails> _medicationRecordDetails;

  bool _loading = true;
  Map<String, dynamic> _provinceMap = {};
  Database? _db;

  User? _user;
  bool _authenticated = false;

  Future<void> _refreshUser() async {
    final user = User.fromMap((await _db!.query("User")).first);

    setState(() {
      _user = user;
    });
  }

  Future<void> _refreshGlucose() async {
    final path = await getDatabasesPath();
    final db = await initAppDatabase(path);

    final records = await db.query('GlucoseRecord');

    setState(() {
      _glucoseRecords =
          records.map((record) => GlucoseRecord.fromMap(record)).toList();
    });
  }

  Future<void> _refreshActivity() async {
    final path = await getDatabasesPath();
    final db = await initAppDatabase(path);

    final records = await db.query('ActivityRecord');

    setState(() {
      _activityRecords =
          records.map((record) => ActivityRecord.fromMap(record)).toList();
    });
  }

  Future<void> _refreshNutrition() async {
    final path = await getDatabasesPath();
    final db = await initAppDatabase(path);

    final records = await db.query('NutritionRecord');

    setState(() {
      _nutritionRecords =
          records.map((record) => NutritionRecord.fromMap(record)).toList();
    });
  }

  Future<void> _refreshBMI() async {
    final path = await getDatabasesPath();
    final db = await initAppDatabase(path);

    final records = await db.query('BMIRecord');

    setState(() {
      _bmiRecords = records.map((record) => BMIRecord.fromMap(record)).toList();
    });
  }

  Future<void> _refreshWaterIntake() async {
    final path = await getDatabasesPath();
    final db = await initAppDatabase(path);

    final records = await db.query('WaterRecord');

    setState(() {
      _waterRecords =
          records.map((record) => WaterRecord.fromMap(record)).toList();
    });
  }

  Future<void> _refreshMedication() async {
    final path = await getDatabasesPath();
    final db = await initAppDatabase(path);

    final records = await db.query('MedicationRecordDetails');

    setState(() {
      _medicationRecordDetails = records
          .map((record) => MedicationRecordDetails.fromMap(record))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();

    (() async {
      final path = await getDatabasesPath();
      final db = await initAppDatabase(path);

      _db = db;

      final [user, municipalityData] = await Future.wait([
        db.query('User'),
        loadMunicipalityData(),
      ]);

      final vals = (municipalityData as Map<String, dynamic>)
          .values
          .map((region) => region['province_list'])
          .cast<Map<String, dynamic>>()
          .toList();

      final provinceList = vals
          .map((provinceList) => provinceList.entries.toList())
          .flattened
          .toList();

      _provinceMap = {
        for (var element in provinceList) element.key: element.value
      };

      if ((user as List<Map<String, dynamic>>).isEmpty) {
        _user = null;
      } else {
        _user = User.fromMap(user.first);
      }

      final [
        rawGlucose,
        rawBMI,
        rawNutrition,
        rawActivity,
        rawMedication,
        rawAppointment,
        rawWater
      ] = await Future.wait([
        db.query('GlucoseRecord'),
        db.query('BMIRecord'),
        db.query('NutritionRecord'),
        db.query('ActivityRecord'),
        db.query('MedicationRecordDetails'),
        db.query('DoctorsAppointmentRecords'),
        db.query('WaterRecord'),
      ]);

      _glucoseRecords = GlucoseRecord.fromListOfMaps(
        rawGlucose as List<Map<String, dynamic>>,
      );

      _bmiRecords = BMIRecord.fromListOfMaps(
        rawBMI as List<Map<String, dynamic>>,
      );

      _nutritionRecords = NutritionRecord.fromListOfMaps(
        rawNutrition as List<Map<String, dynamic>>,
      );

      _activityRecords = ActivityRecord.fromListOfMaps(
        rawActivity as List<Map<String, dynamic>>,
      );

      _medicationRecordDetails = MedicationRecordDetails.fromListOfMaps(
        rawMedication as List<Map<String, dynamic>>,
      );

      _doctorsAppointmentRecords = DoctorsAppointmentRecord.fromListOfMaps(
        rawAppointment as List<Map<String, dynamic>>,
      );

      _waterRecords = WaterRecord.fromListOfMaps(
        rawWater as List<Map<String, dynamic>>,
      );

      if (mounted) {
        await Future.wait([
          precacheImage(const AssetImage('assets/pp_banner_1.png'), context),
          precacheImage(const AssetImage('assets/pp_banner_2.png'), context),
        ]);
      }

      await Future.delayed(
        const Duration(seconds: 1),
      );

      FlutterNativeSplash.remove();
      setState(() {
        _loading = false;
      });
    })();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: SpinKitCircle(color: fgColor),
        ),
      );
    }

    if (_user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFB2CFF6),
        body: SafeArea(
          child: UserSetup(
            reset: _refreshUser,
            provinceMap: _provinceMap,
            db: _db!,
          ),
        ),
      );
    }

    if (!_authenticated) {
      return Scaffold(
        body: SafeArea(
          child: Passcode(
            setAuth: (auth) {
              setState(() {
                _authenticated = auth;
              });
            },
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade50,
        title: SvgPicture.asset('assets/logo_simp.svg'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.contact_support_outlined),
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello, ${_user!.name}!",
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 12),
              Image.asset('assets/pp_banner_1.png'),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await Navigator.of(context).pushNamed(
                          '/blood-glucose-tracking',
                          arguments: {
                            'user': _user!,
                            'db': _db!,
                          },
                        );

                        _refreshGlucose();
                      },
                      child: Column(
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Material(
                              elevation: 1,
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/glucose.svg',
                                  width: 40,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Glucose Records',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(height: 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await Navigator.of(context).pushNamed(
                          '/medication-tracking',
                          arguments: {
                            'user': _user!,
                            'db': _db!,
                          },
                        );

                        _refreshMedication();
                      },
                      child: Column(
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Material(
                              elevation: 1,
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/meds.svg',
                                  width: 40,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Medicine Reminders',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(height: 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await Navigator.of(context).pushNamed(
                          '/activity-log',
                          arguments: {
                            'db': _db!,
                          },
                        );

                        _refreshActivity();
                      },
                      child: Column(
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Material(
                              elevation: 1,
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/exercise.svg',
                                  width: 40,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Activity Log',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(height: 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await Navigator.of(context).pushNamed(
                          '/bmi-tracking',
                          arguments: {
                            'user': _user!,
                            'db': _db!,
                          },
                        );

                        _refreshBMI();
                      },
                      child: Column(
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Material(
                              elevation: 1,
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/scale.svg',
                                  width: 40,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'BMI',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(height: 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await Navigator.of(context).pushNamed(
                          '/nutrition-log',
                          arguments: {
                            'db': _db!,
                          },
                        );

                        _refreshNutrition();
                      },
                      child: Column(
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Material(
                              elevation: 1,
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/fork_spoon.svg',
                                  width: 40,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Nutrition Log',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(height: 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          '/doctors-appointment/input',
                          arguments: {
                            'db': _db!,
                          },
                        );
                      },
                      child: Column(
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Material(
                              elevation: 1,
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/event.svg',
                                  width: 40,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Appointments',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(height: 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: Material(
                            elevation: 1,
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/sos.svg',
                                width: 40,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Emergency Hotlines',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.roboto(height: 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          '/more',
                          arguments: {
                            'db': _db!,
                            'user': _user!,
                          },
                        );
                      },
                      child: Column(
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Material(
                              elevation: 1,
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/dot_menu.svg',
                                  width: 40,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'More',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(height: 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Expanded(child: SizedBox()),
              CarouselSlider(
                items: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GlucoseCarousel(
                      records: _glucoseRecords,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: BMICarousel(
                      records: _bmiRecords,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: MedicationReminderCarousel(
                      records: _medicationRecordDetails,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: NutritionCarousel(
                      records: _nutritionRecords,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: WaterIntakeCarousel(
                      records: _waterRecords,
                      refreshWaterIntake: _refreshWaterIntake,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ActivityCarousel(
                      records: _activityRecords,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: ReadingMaterialCarousel(),
                  ),
                ],
                options: CarouselOptions(
                  aspectRatio: 2.3,
                  viewportFraction: 1,
                  // autoPlay: true,
                  enlargeFactor: 0,
                  enlargeCenterPage: true,
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(
          side: BorderSide(
            color: fgColor,
            width: 2,
          ),
        ),
        onPressed: () {},
        backgroundColor: Colors.white,
        foregroundColor: fgColor,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        padding: EdgeInsets.zero,
        height: 52,
        color: fgColor,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.home_outlined, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.forum_outlined, color: Colors.white),
              onPressed: () {},
            ),
            const SizedBox(width: 48), // Space for the FAB
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
