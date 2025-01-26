import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dialife/activity_log/entities.dart';
import 'package:dialife/activity_log/input_form.dart';
import 'package:dialife/activity_log/utils.dart';
import 'package:dialife/blood_glucose_tracking/entities.dart';
import 'package:dialife/blood_glucose_tracking/glucose_tracking.dart';
import 'package:dialife/blood_glucose_tracking/utils.dart';
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
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:sqflite/sqflite.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:path/path.dart' as libpath;

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
                            'generatePdfFile': generatePdfFile,
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

  Future<void> generatePdfFile() async {
    if (_user == null) return;

    await FilePicker.platform.clearTemporaryFiles();
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
    final medicationTrackingRecords = (_medicationRecordDetails ?? [])
        .reversed
        .where((rec) =>
            weekScope.start.isBefore(rec.medicationDatetime) &&
            weekScope.end.isAfter(rec.medicationDatetime));

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
                    "PulsePilot",
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
                      text: _user!.name,
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
                          "${(_user!.exactAge.inDays / 365).floor()}, ${_user!.isMale ? "Male" : "Female"}",
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
                      text: DateFormat("MMM. dd, yyyy").format(_user!.birthday),
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
                      text: _user!.contactNumber,
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
                          "Brgy. ${_user!.barangay.toLowerCase().capitalize()}, ${_user!.municipality.toLowerCase().capitalize()}, ${_user!.province.toLowerCase().capitalize()}",
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
                  "PuslePilot",
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
                                "Meal Time",
                                textAlign: pw.TextAlign.center,
                              ),
                              pw.Text(
                                "Foods",
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
                                    rec.dayDescription,
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.only(left: 8),
                                  child: pw.Text(
                                    rec.foods.join(", "),
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
            pw.SizedBox(height: 16),
            pw.RichText(
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(
                    text: "Medications Taken (7 days)",
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
                                "Schedule",
                                textAlign: pw.TextAlign.center,
                              ),
                              pw.Text(
                                "Actual Date Taken",
                                textAlign: pw.TextAlign.center,
                              ),
                              pw.Text(
                                "Name",
                                textAlign: pw.TextAlign.center,
                              ),
                              pw.Text(
                                "Route",
                                textAlign: pw.TextAlign.center,
                              ),
                              pw.Text(
                                "Form",
                                textAlign: pw.TextAlign.center,
                              ),
                              pw.Text(
                                "Dosage",
                                textAlign: pw.TextAlign.center,
                              ),
                            ],
                          ),
                          ...[
                            () {
                              if (medicationTrackingRecords.isEmpty) {
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
                          ...medicationTrackingRecords.map((rec) {
                            return pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.only(left: 8),
                                  child: pw.Text(
                                    DateFormat("MMM. dd, hh:mm a")
                                        .format(rec.medicationDatetime),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.only(left: 8),
                                  child: rec.actualTakenTime == null
                                      ? pw.Text("(Not Taken)")
                                      : pw.Text(
                                          DateFormat("MMM. dd, hh:mm a")
                                              .format(rec.actualTakenTime!),
                                        ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.only(left: 8),
                                  child: pw.Text(
                                    rec.medicineName,
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.only(left: 8),
                                  child: pw.Text(
                                    rec.medicineRoute,
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.only(left: 8),
                                  child: pw.Text(
                                    rec.medicineForm,
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.only(left: 8),
                                  child: pw.Text(
                                    rec.medicineDosage.toStringAsFixed(2),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  )
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
    final file = File(libpath.join(directory.path, "patient-data.pdf"));

    if (await file.exists()) {
      await file.delete();
    }

    await file.writeAsBytes(await pdf.save());
    await file.create();
  }
}
