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

  Map toApiInsertable() {
    return {
      "glucose_created_at": glucoseRecord?.bloodTestDate.toIso8601String(),
      "glucose_level": glucoseRecord?.glucoseLevel,
      "bmi_created_at": bmiRecord?.createdAt.toIso8601String(),
      "bmi_level": bmiRecord?.bmi,
      "activity_created_at": activityRecord?.createdAt.toIso8601String(),
      "activity_type": activityRecord?.type,
      "activity_duration": activityRecord?.duration,
      "activity_frequency": activityRecord?.frequency,
      "nutrition_created_at": nutritionRecord?.createdAt.toIso8601String(),
      "meal_time": nutritionRecord?.dayDescription,
      "foods": nutritionRecord?.foods,
      "water_created_at": waterRecord?.time,
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
