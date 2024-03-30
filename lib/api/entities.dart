import 'dart:math';

import 'package:dialife/activity_log/entities.dart';
import 'package:dialife/blood_glucose_tracking/entities.dart';
import 'package:dialife/bmi_tracking/entities.dart';
import 'package:dialife/main.dart';
import 'package:dialife/medication_tracking/entities.dart';
import 'package:dialife/nutrition_log/entities.dart';
import 'package:dialife/user.dart';
import 'package:sqflite/sqflite.dart';

class APIPatientRecordUploadable {
  final GlucoseRecord? glucoseRecord;
  final BMIRecord? bmiRecord;
  final NutritionRecord? nutritionRecord;
  final MedicationRecordDetails? medicationDetailsRecord;
  final ActivityRecord? activityRecord;
  final WaterRecord? waterRecord;
  final int? patientId;

  @override
  String toString() {
    return toApiInsertable().toString();
  }

  Map toApiInsertable() {
    return {
      "glucose_created_at": glucoseRecord?.bloodTestDate.toIso8601String(),
      "glucose_level": glucoseRecord?.glucoseLevel,
      "bmi_created_at": bmiRecord?.createdAt.toIso8601String(),
      "bmi_level": bmiRecord?.bmi,
      "activity_created_at": activityRecord?.createdAt.toIso8601String(),
      "activity_type": activityRecord?.type.asString,
      "activity_duration": activityRecord?.duration,
      "activity_frequency": activityRecord?.frequency,
      "nutrition_created_at": nutritionRecord?.createdAt.toIso8601String(),
      "meal_time": nutritionRecord?.dayDescription,
      "foods": nutritionRecord?.foods.join(","),
      "water_created_at": waterRecord?.time.toIso8601String(),
      "water_glasses": waterRecord?.glasses,
      "medicine_taken_at":
          medicationDetailsRecord?.medicationDatetime.toIso8601String(),
      "medicine_name": medicationDetailsRecord?.medicineName,
      "medicine_route": medicationDetailsRecord?.medicineRoute,
      "medicine_form": medicationDetailsRecord?.medicineForm,
      "medicine_dosage": medicationDetailsRecord?.medicineDosage,
      "patient_id": patientId,
    };
  }

  static Future<List<APIPatientRecordUploadable>> normalizedRecords() async {
    final path = await getDatabasesPath();
    final db = await initAppDatabase(path);

    final [
      glucoseRecords,
      activityRecords,
      nutritionRecords,
      bmiRecords,
      waterRecords,
      medicationRecords
    ] = await Future.wait([
      db.rawQuery('SELECT * FROM GlucoseRecord ORDER BY blood_test_date DESC'),
      db.rawQuery('SELECT * FROM ActivityRecord ORDER BY created_at DESC'),
      db.rawQuery('SELECT * FROM NutritionRecord ORDER BY created_at DESC'),
      db.rawQuery('SELECT * FROM BMIRecord ORDER BY created_at DESC'),
      db.rawQuery('SELECT * FROM WaterRecord ORDER BY time DESC'),
      db.rawQuery(
          'SELECT * FROM MedicationRecordDetails WHERE medication_datetime < ? ORDER BY medication_datetime DESC ',
          [
            DateTime.now().toIso8601String(),
          ]),
    ]);

    final glucose = GlucoseRecord.fromListOfMaps(glucoseRecords);
    final activity = ActivityRecord.fromListOfMaps(activityRecords);
    final nutrition = NutritionRecord.fromListOfMaps(nutritionRecords);
    final bmi = BMIRecord.fromListOfMaps(bmiRecords);
    final water = WaterRecord.fromListOfMaps(waterRecords);
    final medication =
        MedicationRecordDetails.fromListOfMaps(medicationRecords);

    final user = User.fromMap((await db.query("User")).first);
    if (user.webId == null) {
      throw Exception("Patient does not exist in Monitoring API");
    }

    final maxCount = [glucose, activity, nutrition, bmi, water, medication]
        .map((records) => records.length)
        .reduce(max);

    return List.generate(maxCount, (index) {
      return APIPatientRecordUploadable(
        glucoseRecord: glucose.elementAtOrNull(index),
        activityRecord: activity.elementAtOrNull(index),
        nutritionRecord: nutrition.elementAtOrNull(index),
        bmiRecord: bmi.elementAtOrNull(index),
        waterRecord: water.elementAtOrNull(index),
        medicationDetailsRecord: medication.elementAtOrNull(index),
        patientId: user.webId,
      );
    });
  }

  static Future<APIPatientRecordUploadable> latestCompiled() async {
    final path = await getDatabasesPath();
    final db = await initAppDatabase(path);

    final lastestGlucose = await db.query(
      "GlucoseRecord",
      orderBy: "blood_test_date DESC",
      limit: 1,
    );

    final glucose = lastestGlucose.isEmpty
        ? null
        : GlucoseRecord.fromMap(lastestGlucose.first);

    final latestActivity = await db.query(
      "ActivityRecord",
      orderBy: "created_at DESC",
      limit: 1,
    );

    final activity = latestActivity.isEmpty
        ? null
        : ActivityRecord.fromMap(latestActivity.first);

    final latestNutrition = await db.query(
      "NutritionRecord",
      orderBy: "created_at DESC",
      limit: 1,
    );

    final nutrition = latestNutrition.isEmpty
        ? null
        : NutritionRecord.fromMap(latestNutrition.first);

    final latestBMI = await db.query(
      "BMIRecord",
      orderBy: "created_at DESC",
      limit: 1,
    );

    final bmi = latestBMI.isEmpty ? null : BMIRecord.fromMap(latestBMI.first);

    final latestMedication = await db.query(
      "MedicationRecordDetails",
      orderBy: "medication_datetime DESC",
      limit: 1,
    );

    final medication = latestMedication.isEmpty
        ? null
        : MedicationRecordDetails.fromMap(latestMedication.first);

    final user = User.fromMap((await db.query("User")).first);

    final latestWater = await db.query(
      "WaterRecord",
      orderBy: "time DESC",
      limit: 1,
    );

    final water =
        latestWater.isEmpty ? null : WaterRecord.fromMap(latestWater.first);

    if (user.webId == null) {
      throw Exception("Patient does not exist in Monitoring API");
    }

    return APIPatientRecordUploadable(
      activityRecord: activity,
      glucoseRecord: glucose,
      bmiRecord: bmi,
      medicationDetailsRecord: medication,
      nutritionRecord: nutrition,
      waterRecord: water,
      patientId: user.webId!,
    );
  }

  const APIPatientRecordUploadable({
    required this.activityRecord,
    required this.bmiRecord,
    required this.glucoseRecord,
    required this.medicationDetailsRecord,
    required this.nutritionRecord,
    required this.waterRecord,
    required this.patientId,
  });
}
