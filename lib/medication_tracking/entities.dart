class MedicationReminderRecord {
  final int id;
  final DateTime startsAt;
  final DateTime endsAt;

  const MedicationReminderRecord({
    required this.id,
    required this.startsAt,
    required this.endsAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "starts_at": startsAt.toIso8601String(),
      "ends_at": endsAt.toIso8601String(),
    };
  }

  static MedicationReminderRecord fromMap(Map<String, dynamic> map) {
    return MedicationReminderRecord(
      id: map["id"],
      startsAt: DateTime.parse(map["starts_at"]),
      endsAt: DateTime.parse(map["ends_at"]),
    );
  }

  static List<MedicationReminderRecord> fromListOfMaps(
      List<Map<String, dynamic>> list) {
    final result = list.map((record) => fromMap(record));
    return result.toList();
  }
}

class MedicationRecordDetails {
  final int id;
  final int medicationReminderRecordId;
  final String medicineName;
  final String medicineRoute;
  final String medicineForm;
  final double medicineDosage;
  final DateTime medicationDatetime;
  final DateTime? actualTakenTime;
  final int notifId;

  const MedicationRecordDetails({
    required this.id,
    required this.medicationReminderRecordId,
    required this.medicineName,
    required this.medicineRoute,
    required this.medicineForm,
    required this.medicineDosage,
    required this.medicationDatetime,
    required this.actualTakenTime,
    required this.notifId,
  });

  Map<String, dynamic> toApiInsertable() {
    return {
      "medicine_name": medicineName,
      "medicine_route": medicineRoute,
      "medicine_form": medicineForm,
      "medicine_dosage": medicineDosage,
      "medication_reminder_date": medicationDatetime.toIso8601String(),
      "recorded_time_taken": actualTakenTime?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return "$id, $medicationReminderRecordId, $medicineName, $medicineRoute, $medicineForm, $medicineDosage, $medicationDatetime";
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "medication_reminder_record_id": medicationReminderRecordId,
      "medicine_name": medicineName,
      "medicine_route": medicineRoute,
      "medicine_form": medicineForm,
      "medicine_dosage": medicineDosage,
      "medication_datetime": medicationDatetime.toIso8601String(),
      "notification_id": notifId,
    };
  }

  static List<MedicationRecordDetails> fromListOfMaps(
      List<Map<String, dynamic>> list) {
    final result = list.map((record) => fromMap(record));
    return result.toList();
  }

  static MedicationRecordDetails fromMap(Map<String, dynamic> map) {
    return MedicationRecordDetails(
        id: map["id"],
        medicationReminderRecordId: map["medication_reminder_record_id"],
        medicineName: map["medicine_name"],
        medicineRoute: map["medicine_route"],
        medicineForm: map["medicine_form"],
        medicineDosage: map["medicine_dosage"].toDouble(),
        medicationDatetime: DateTime.parse(map["medication_datetime"]),
        // NOTE: Find better way to write this
        actualTakenTime: map["actual_taken_time"] == null
            ? null
            : DateTime.parse(map["actual_taken_time"]),
        notifId: map["notification_id"]);
  }
}
