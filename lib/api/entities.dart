import 'package:dialife/activity_log/entities.dart';
import 'package:dialife/blood_glucose_tracking/entities.dart';
import 'package:dialife/bmi_tracking/entities.dart';
import 'package:dialife/main.dart';
import 'package:dialife/medication_tracking/entities.dart';
import 'package:dialife/nutrition_log/entities.dart';
import 'package:dialife/user.dart';
import 'package:sqflite/sqflite.dart';

class APIPatientRecordUploadable {
  final DateTime? glucoseCreatedAt;
  final double? glucoseLevel;
  final DateTime? bmiCreatedAt;
  final double? bmiLevel;
  final DateTime? activityCreatedAt;
  final String? activityType;
  final int? activityDuration;
  final int? activityFrequency;
  final DateTime? nutritionCreatedAt;
  final double? nutritionFat;
  final double? nutritionProtein;
  final double? nutritionCarbohydrates;
  final int? nutritionWater;
  final DateTime? medicineTakenAt;
  final String? medicineName;
  final String? medicineRoute;
  final String? medicineForm;
  final double? medicineDosage;
  final int? patientId;

  Map toApiInsertable() {
    return {
      "glucose_created_at": glucoseCreatedAt?.toIso8601String(),
      "glucose_level": glucoseLevel,
      "bmi_created_at": bmiCreatedAt?.toIso8601String(),
      "bmi_level": bmiLevel,
      "activity_created_at": activityCreatedAt?.toIso8601String(),
      "activity_type": activityType,
      "activity_duration": activityDuration,
      "activity_frequency": activityFrequency,
      "nutrition_created_at": nutritionCreatedAt?.toIso8601String(),
      "nutrition_fat": nutritionFat,
      "nutrition_protein": nutritionProtein,
      "nutrition_carbohydrates": nutritionCarbohydrates,
      "nutrition_water": nutritionWater,
      "medicine_taken_at": medicineTakenAt?.toIso8601String(),
      "medicine_name": medicineName,
      "medicine_route": medicineRoute,
      "medicine_form": medicineForm,
      "medicine_dosage": medicineDosage,
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

    if (user.webId == null) {
      throw Exception("Patient does not exist in Monitoring API");
    }

    return APIPatientRecordUploadable(
      bmiCreatedAt: bmi?.createdAt,
      bmiLevel: bmi?.bmi,
      glucoseCreatedAt: glucose?.bloodTestDate,
      glucoseLevel: glucose?.glucoseLevel,
      nutritionCreatedAt: nutrition?.createdAt,
      nutritionCarbohydrates: nutrition?.carbohydratesInGrams,
      nutritionFat: nutrition?.fatsInGrams,
      nutritionProtein: nutrition?.proteinInGrams,
      nutritionWater: nutrition?.glassesOfWater,
      activityCreatedAt: activity?.createdAt,
      activityDuration: activity?.duration,
      activityFrequency: activity?.frequency,
      activityType: activity?.type.asString,
      medicineTakenAt: medication?.medicationDatetime,
      medicineDosage: medication?.medicineDosage,
      medicineForm: medication?.medicineForm,
      medicineName: medication?.medicineName,
      medicineRoute: medication?.medicineRoute,
      patientId: user.webId!,
    );
  }

  const APIPatientRecordUploadable({
    required this.glucoseCreatedAt,
    required this.glucoseLevel,
    required this.bmiCreatedAt,
    required this.bmiLevel,
    required this.activityCreatedAt,
    required this.activityType,
    required this.activityDuration,
    required this.activityFrequency,
    required this.nutritionCreatedAt,
    required this.nutritionFat,
    required this.nutritionProtein,
    required this.nutritionCarbohydrates,
    required this.nutritionWater,
    required this.medicineTakenAt,
    required this.medicineDosage,
    required this.medicineName,
    required this.medicineRoute,
    required this.medicineForm,
    required this.patientId,
  });
}
