import 'dart:math';

import 'package:dialife/activity_log/entities.dart';
import 'package:dialife/blood_glucose_tracking/entities.dart';
import 'package:dialife/bmi_tracking/entities.dart';
import 'package:dialife/main.dart';
import 'package:dialife/medication_tracking/entities.dart';
import 'package:dialife/nutrition_log/entities.dart';
import 'package:dialife/user.dart';
import 'package:sqflite/sqflite.dart';

class APIAppointment {
  final int id;
  final int userId;
  final int patientId;
  final DateTime appointmentDate;
  final String appointmentTime;
  final int durationMinutes;
  final String status;
  final String reason;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final APIDoctor doctor;

  const APIAppointment({
    required this.id,
    required this.userId,
    required this.patientId,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.durationMinutes,
    required this.status,
    required this.reason,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.doctor,
  });

  static APIAppointment fromMap(Map<String, dynamic> map) {
    return APIAppointment(
      id: map["id"],
      userId: map["user_id"],
      patientId: map["patient_id"],
      appointmentDate: DateTime.parse(map["appointment_date"]),
      appointmentTime: map["appointment_time"],
      durationMinutes: map["duration_minutes"],
      status: map["status"],
      reason: map["reason"],
      notes: map["notes"],
      createdAt: DateTime.parse(map["created_at"]),
      updatedAt: DateTime.parse(map["updated_at"]),
      doctor: APIDoctor.fromMap(map["doctor"]),
    );
  }

  static List<APIAppointment> fromListOfMaps(List<Map<String, dynamic>> list) {
    return list.map((map) => fromMap(map)).toList();
  }
}

class APITimeSlot {
  final String start;
  final String end;

  const APITimeSlot({
    required this.start,
    required this.end,
  });

  static APITimeSlot fromMap(Map<String, dynamic> map) {
    return APITimeSlot(
      start: map['start'],
      end: map['end'],
    );
  }

  static List<APITimeSlot> fromListOfMaps(List<Map<String, dynamic>> list) {
    return list.map((map) => fromMap(map)).toList();
  }
}

class APITimeSlotSchedule {
  final Map<String, List<APITimeSlot>> schedule;

  const APITimeSlotSchedule({required this.schedule});

  List<APITimeSlot> get fifteen => schedule["15"] ?? [];
  List<APITimeSlot> get thirty => schedule["30"] ?? [];
  List<APITimeSlot> get fortyFive => schedule["45"] ?? [];
  List<APITimeSlot> get sixty => schedule["60"] ?? [];

  static APITimeSlotSchedule fromMap(Map<String, dynamic> map) {
    return APITimeSlotSchedule(schedule: {
      "15": APITimeSlot.fromListOfMaps(
          (map["15"] as List).map((e) => e as Map<String, dynamic>).toList()),
      "30": APITimeSlot.fromListOfMaps(
          (map["30"] as List).map((e) => e as Map<String, dynamic>).toList()),
      "45": APITimeSlot.fromListOfMaps(
          (map["45"] as List).map((e) => e as Map<String, dynamic>).toList()),
      "60": APITimeSlot.fromListOfMaps(
          (map["60"] as List).map((e) => e as Map<String, dynamic>).toList()),
    });
  }
}

class APIRecoveryData {
  final int id;
  final String firstName;
  final String lastName;
  final String middleName;
  final String recoveryId;
  final DateTime birthdate;
  final String province;
  final String municipality;
  final String barangay;
  final String zipCode;
  final String sex;
  final String addressDescription;
  final String contactNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<APIBMIRecord> bmiRecords;
  final List<APIWaterRecord> waterRecords;
  final List<APIGlucoseRecord> glucoseRecords;
  final List<APINutritionRecord> nutritionRecords;
  final List<APIActivityRecord> activityRecords;

  const APIRecoveryData({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.recoveryId,
    required this.birthdate,
    required this.province,
    required this.municipality,
    required this.barangay,
    required this.zipCode,
    required this.sex,
    required this.addressDescription,
    required this.contactNumber,
    required this.createdAt,
    required this.updatedAt,
    required this.bmiRecords,
    required this.waterRecords,
    required this.glucoseRecords,
    required this.nutritionRecords,
    required this.activityRecords,
  });

  static APIRecoveryData fromMap(Map<String, dynamic> map) {
    return APIRecoveryData(
      id: map["id"],
      firstName: map["first_name"],
      lastName: map["last_name"],
      middleName: map["middle_name"],
      recoveryId: map["recovery_id"],
      birthdate: DateTime.parse(map["birthdate"]),
      province: map["province"],
      municipality: map["municipality"],
      barangay: map["barangay"],
      zipCode: map["zip_code"],
      sex: map["sex"],
      addressDescription: map["address_description"],
      contactNumber: map["contact_number"],
      createdAt: DateTime.parse(map["created_at"]),
      updatedAt: DateTime.parse(map["updated_at"]),
      bmiRecords: (map["bmi_records"] as List)
          .map((record) => APIBMIRecord.fromMap(record))
          .toList(),
      waterRecords: (map["water_records"] as List)
          .map((record) => APIWaterRecord.fromMap(record))
          .toList(),
      glucoseRecords: (map["glucose_records"] as List)
          .map((record) => APIGlucoseRecord.fromMap(record))
          .toList(),
      nutritionRecords: (map["nutrition_records"] as List)
          .map((record) => APINutritionRecord.fromMap(record))
          .toList(),
      activityRecords: (map["activity_records"] as List)
          .map((record) => APIActivityRecord.fromMap(record))
          .toList(),
    );
  }
}

class APIBMIRecord {
  final int id;
  final String height;
  final String notes;
  final String weight;
  final DateTime recordedAt;
  final int patientId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const APIBMIRecord({
    required this.id,
    required this.height,
    required this.notes,
    required this.weight,
    required this.recordedAt,
    required this.patientId,
    required this.createdAt,
    required this.updatedAt,
  });

  static APIBMIRecord fromMap(Map<String, dynamic> map) {
    return APIBMIRecord(
      id: map["id"],
      height: map["height"],
      notes: map["notes"],
      weight: map["weight"],
      recordedAt: DateTime.parse(map["recorded_at"]),
      patientId: map["patient_id"],
      createdAt: DateTime.parse(map["created_at"]),
      updatedAt: DateTime.parse(map["updated_at"]),
    );
  }
}

class APIWaterRecord {
  final int id;
  final int patientId;
  final int glasses;
  final DateTime recordedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const APIWaterRecord({
    required this.id,
    required this.patientId,
    required this.glasses,
    required this.recordedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  static APIWaterRecord fromMap(Map<String, dynamic> map) {
    return APIWaterRecord(
      id: map["id"],
      patientId: map["patient_id"],
      glasses: map["glasses"],
      recordedAt: DateTime.parse(map["recorded_at"]),
      createdAt: DateTime.parse(map["created_at"]),
      updatedAt: DateTime.parse(map["updated_at"]),
    );
  }
}

class APIGlucoseRecord {
  final int id;
  final String glucoseLevel;
  final String notes;
  final int isA1c;
  final DateTime recordedAt;
  final int patientId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const APIGlucoseRecord({
    required this.id,
    required this.glucoseLevel,
    required this.notes,
    required this.isA1c,
    required this.recordedAt,
    required this.patientId,
    required this.createdAt,
    required this.updatedAt,
  });

  static APIGlucoseRecord fromMap(Map<String, dynamic> map) {
    return APIGlucoseRecord(
      id: map["id"],
      glucoseLevel: map["glucose_level"],
      notes: map["notes"],
      isA1c: map["is_a1c"],
      recordedAt: DateTime.parse(map["recorded_at"]),
      patientId: map["patient_id"],
      createdAt: DateTime.parse(map["created_at"]),
      updatedAt: DateTime.parse(map["updated_at"]),
    );
  }
}

class APINutritionRecord {
  final int id;
  final String notes;
  final String dayDescription;
  final String foodsCsv;
  final DateTime recordedAt;
  final int patientId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const APINutritionRecord({
    required this.id,
    required this.notes,
    required this.dayDescription,
    required this.foodsCsv,
    required this.recordedAt,
    required this.patientId,
    required this.createdAt,
    required this.updatedAt,
  });

  static APINutritionRecord fromMap(Map<String, dynamic> map) {
    return APINutritionRecord(
      id: map["id"],
      notes: map["notes"],
      dayDescription: map["day_description"],
      foodsCsv: map["foods_csv"],
      recordedAt: DateTime.parse(map["recorded_at"]),
      patientId: map["patient_id"],
      createdAt: DateTime.parse(map["created_at"]),
      updatedAt: DateTime.parse(map["updated_at"]),
    );
  }
}

class APIActivityRecord {
  final int id;
  final String type;
  final int duration;
  final int frequency;
  final String notes;
  final DateTime recordedAt;
  final int patientId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const APIActivityRecord({
    required this.id,
    required this.type,
    required this.duration,
    required this.frequency,
    required this.notes,
    required this.recordedAt,
    required this.patientId,
    required this.createdAt,
    required this.updatedAt,
  });

  static APIActivityRecord fromMap(Map<String, dynamic> map) {
    return APIActivityRecord(
      id: map["id"],
      type: map["type"],
      duration: map["duration"],
      frequency: map["frequency"],
      notes: map["notes"],
      recordedAt: DateTime.parse(map["recorded_at"]),
      patientId: map["patient_id"],
      createdAt: DateTime.parse(map["created_at"]),
      updatedAt: DateTime.parse(map["updated_at"]),
    );
  }
}

class APIChatMessage {
  final int id;
  final String senderType;
  final String messageType;
  final String? message;
  final String? path;
  final int patientId;
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final APIDoctor doctor;
  final APIPatient patient;

  bool get isFromPatient => senderType == "patient";

  const APIChatMessage({
    required this.id,
    required this.senderType,
    required this.messageType,
    required this.message,
    this.path,
    required this.patientId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.doctor,
    required this.patient,
  });

  static APIChatMessage fromMap(Map<String, dynamic> map) {
    return APIChatMessage(
      id: map["id"],
      senderType: map["sender_type"],
      messageType: map["message_type"],
      message: map["message"],
      path: map["path"],
      patientId: map["patient_id"],
      userId: map["user_id"],
      createdAt: DateTime.parse(map["created_at"]),
      updatedAt: DateTime.parse(map["updated_at"]),
      doctor: APIDoctor.fromMap(map["doctor"]),
      patient: APIPatient.fromMap(map["patient"]),
    );
  }

  static List<APIChatMessage> fromListOfMaps(List<Map<String, dynamic>> list) {
    return list.map((map) => fromMap(map)).toList();
  }
}

class APIConditionHistory {
  final int id;
  final int patientId;
  final String conditionName;
  final String conditionType;
  final DateTime diagnosisDate;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final APIPatient patient;

  const APIConditionHistory({
    required this.id,
    required this.patientId,
    required this.conditionName,
    required this.conditionType,
    required this.diagnosisDate,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.patient,
  });

  static APIConditionHistory fromMap(Map<String, dynamic> map) {
    return APIConditionHistory(
      id: map["id"],
      patientId: map["patient_id"],
      conditionName: map["condition_name"],
      conditionType: map["condition_type"],
      diagnosisDate: DateTime.parse(map["diagnosis_date"]),
      status: map["status"],
      notes: map["notes"],
      createdAt: DateTime.parse(map["created_at"]),
      updatedAt: DateTime.parse(map["updated_at"]),
      patient: APIPatient.fromMap(map["patient"]),
    );
  }

  static List<APIConditionHistory> fromListOfMaps(
      List<Map<String, dynamic>> list) {
    return list.map((map) => fromMap(map)).toList();
  }
}

class APIImmunizationHistory {
  final int id;
  final int patientId;
  final String vaccineName;
  final DateTime administrationDate;
  final int? doseNumber;
  final String? manufacturer;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final APIPatient patient;

  const APIImmunizationHistory({
    required this.id,
    required this.patientId,
    required this.vaccineName,
    required this.administrationDate,
    this.doseNumber,
    this.manufacturer,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.patient,
  });

  static APIImmunizationHistory fromMap(Map<String, dynamic> map) {
    return APIImmunizationHistory(
      id: map["id"],
      patientId: map["patient_id"],
      vaccineName: map["vaccine_name"],
      administrationDate: DateTime.parse(map["administration_date"]),
      doseNumber: map["dose_number"],
      manufacturer: map["manufacturer"],
      notes: map["notes"],
      createdAt: DateTime.parse(map["created_at"]),
      updatedAt: DateTime.parse(map["updated_at"]),
      patient: APIPatient.fromMap(map["patient"]),
    );
  }

  static List<APIImmunizationHistory> fromListOfMaps(
      List<Map<String, dynamic>> list) {
    return list.map((map) => fromMap(map)).toList();
  }
}

class APILabSubmission {
  final int id;
  final int labRequestId;
  final String type;
  final String filePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  const APILabSubmission({
    required this.id,
    required this.labRequestId,
    required this.type,
    required this.filePath,
    required this.createdAt,
    required this.updatedAt,
  });

  static APILabSubmission fromMap(Map<String, dynamic> map) {
    return APILabSubmission(
      id: map["id"],
      labRequestId: map["lab_request_id"],
      type: map["type"],
      filePath: map["file_path"],
      createdAt: DateTime.parse(map["created_at"]),
      updatedAt: DateTime.parse(map["updated_at"]),
    );
  }

  static List<APILabSubmission> fromListOfMaps(
      List<Map<String, dynamic>> list) {
    return list.map((map) => fromMap(map)).toList();
  }
}

class APILabRequest {
  final int id;
  final int patientId;
  final int userId;
  final String type;
  final String priorityLevel;
  final bool fastingRequired;
  final String clinicalIndication;
  final DateTime createdAt;
  final DateTime updatedAt;
  final APIPatient patient;
  final APIDoctor doctor;
  final APILabSubmission? submission;

  const APILabRequest({
    required this.id,
    required this.patientId,
    required this.userId,
    required this.type,
    required this.priorityLevel,
    required this.fastingRequired,
    required this.clinicalIndication,
    required this.createdAt,
    required this.updatedAt,
    required this.patient,
    required this.doctor,
    required this.submission,
  });

  static APILabRequest fromMap(Map<String, dynamic> map) {
    return APILabRequest(
      id: map["id"],
      patientId: map["patient_id"],
      userId: map["user_id"],
      type: map["type"],
      priorityLevel: map["priority_level"],
      fastingRequired: map["fasting_required"] == 1,
      clinicalIndication: map["clinical_indication"],
      createdAt: DateTime.parse(map["created_at"]),
      updatedAt: DateTime.parse(map["updated_at"]),
      patient: APIPatient.fromMap(map["patient"]),
      doctor: APIDoctor.fromMap(map["doctor"]),
      submission: map["lab_submission"] == null
          ? null
          : APILabSubmission.fromMap(map["lab_submission"]),
    );
  }

  static List<APILabRequest> fromListOfMaps(List<Map<String, dynamic>> list) {
    return list.map((map) => fromMap(map)).toList();
  }
}

class APIPatient {
  final int id;
  final String firstName;
  final String lastName;
  final String middleName;
  final String recoveryId;
  final DateTime birthdate;
  final String province;
  final String municipality;
  final String barangay;
  final String zipCode;
  final String sex;
  final String addressDescription;
  final String contactNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  const APIPatient({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.recoveryId,
    required this.birthdate,
    required this.province,
    required this.municipality,
    required this.barangay,
    required this.zipCode,
    required this.sex,
    required this.addressDescription,
    required this.contactNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  static APIPatient fromMap(Map<String, dynamic> map) {
    return APIPatient(
      id: map["id"],
      firstName: map["first_name"],
      lastName: map["last_name"],
      middleName: map["middle_name"],
      recoveryId: map["recovery_id"],
      birthdate: DateTime.parse(map["birthdate"]),
      province: map["province"],
      municipality: map["municipality"],
      barangay: map["barangay"],
      zipCode: map["zip_code"],
      sex: map["sex"],
      addressDescription: map["address_description"],
      contactNumber: map["contact_number"],
      createdAt: DateTime.parse(map["created_at"]),
      updatedAt: DateTime.parse(map["updated_at"]),
    );
  }
}

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
      "medicine_taken_time":
          medicationDetailsRecord?.actualTakenTime?.toIso8601String(),
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

class APIDoctor {
  final int id;
  final String name;
  final String email;
  final String? profileImage;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  static APIDoctor fromMap(Map<String, dynamic> map) {
    return APIDoctor(
      id: map["id"],
      name: map["name"],
      email: map["email"],
      profileImage: map["profile_image"],
      role: map["role"],
      createdAt: DateTime.parse(map["created_at"]),
      updatedAt: DateTime.parse(map["updated_at"]),
    );
  }

  static List<APIDoctor> fromListOfMaps(List<Map<String, dynamic>> list) {
    return list.map((map) => fromMap(map)).toList();
  }

  const APIDoctor({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });
}
