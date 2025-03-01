class DoctorsAppointmentRecord {
  final int id;
  final String doctorName;
  final DateTime appointmentDatetime;
  final String appointmentPurpose;

  const DoctorsAppointmentRecord({
    required this.id,
    required this.doctorName,
    required this.appointmentDatetime,
    required this.appointmentPurpose,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "doctor_name": doctorName,
      "apointment_datetime": appointmentDatetime.toIso8601String(),
      "appointment_purpose": appointmentPurpose,
    };
  }

  static DoctorsAppointmentRecord fromMap(Map<String, dynamic> map) {
    return DoctorsAppointmentRecord(
      id: map["id"],
      doctorName: map["doctor_name"],
      appointmentDatetime: DateTime.parse(map["apointment_datetime"]),
      appointmentPurpose: map["appointment_purpose"],
    );
  }

  static List<DoctorsAppointmentRecord> fromListOfMaps(
      List<Map<String, dynamic>> list) {
    final result = list.map((record) => fromMap(record));
    return result.toList();
  }
}
