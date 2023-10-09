class Facility {
  final int id;
  final String name;
  final double long;
  final double lat;
  final String description;

  const Facility({
    required this.id,
    required this.name,
    required this.long,
    required this.lat,
    required this.description,
  });

  static Facility fromMap(Map<String, dynamic> map) {
    return Facility(
      id: map["id"],
      name: map["name"],
      long: map["long"],
      lat: map["lat"],
      description: map["description"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "long": long,
      "lat": lat,
      "description": description
    };
  }
}

class GlucoseRecord {
  final int id;
  final int facilityId;
  final double glucoseLevel;
  final DateTime bloodTestDate;

  const GlucoseRecord({
    required this.id,
    required this.facilityId,
    required this.glucoseLevel,
    required this.bloodTestDate,
  });

  static GlucoseRecord fromMap(Map<String, dynamic> map) {
    return GlucoseRecord(
      id: map["id"],
      facilityId: map["facility_id"],
      glucoseLevel: double.parse(map["glucose_level"].toString()),
      bloodTestDate: DateTime.parse(map["blood_test_date"]),
    );
  }
}
