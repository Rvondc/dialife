import 'dart:math';

// class Facility {
//   final int id;
//   final String name;
//   final double long;
//   final double lat;
//   final String description;

//   const Facility({
//     required this.id,
//     required this.name,
//     required this.long,
//     required this.lat,
//     required this.description,
//   });

//   static Facility fromMap(Map<String, dynamic> map) {
//     return Facility(
//       id: map["id"],
//       name: map["name"],
//       long: map["long"],
//       lat: map["lat"],
//       description: map["description"],
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       "id": id,
//       "name": name,
//       "long": long,
//       "lat": lat,
//       "description": description
//     };
//   }
// }

class GlucoseRecord {
  final int id;
  // final int facilityId;
  final double glucoseLevel;
  final String notes;
  final bool isA1C;
  final DateTime bloodTestDate;

  const GlucoseRecord({
    required this.id,
    // required this.facilityId,
    required this.isA1C,
    required this.glucoseLevel,
    required this.notes,
    required this.bloodTestDate,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "glucose_level": glucoseLevel,
      "notes": notes,
      "blood_test_date": bloodTestDate,
    };
  }

  GlucoseRecord copyWith({
    int? id,
    int? facilityId,
    double? glucoseLevel,
    String? notes,
    bool? isA1C,
    DateTime? bloodTestDate,
  }) {
    return GlucoseRecord(
      id: id ?? this.id,
      // facilityId: facilityId ?? this.facilityId,
      glucoseLevel: glucoseLevel ?? this.glucoseLevel,
      notes: notes ?? this.notes,
      isA1C: isA1C ?? this.isA1C,
      bloodTestDate: bloodTestDate ?? this.bloodTestDate,
    );
  }

  static GlucoseRecord fromMap(Map<String, dynamic> map) {
    return GlucoseRecord(
      id: map["id"],
      // facilityId: map["facility_id"],
      notes: map["notes"],
      isA1C: map["is_a1c"],
      glucoseLevel: double.parse(map["glucose_level"].toString()),
      bloodTestDate: DateTime.parse(map["blood_test_date"]),
    );
  }

  static List<GlucoseRecord> fromListOfMaps(List<Map<String, dynamic>> list) {
    final result = list.map((record) => fromMap(record));

    return result.toList();
  }

  static List<GlucoseRecord> mock({
    required int count,
    required int daySpan,
    bool a1cInDay = false,
  }) {
    final rand = Random();

    final list = Iterable.generate(count)
        .map(
          (_) => GlucoseRecord(
            id: rand.nextInt(80),
            // facilityId: 1,
            glucoseLevel: rand.nextDouble() * 10.4 + 3.4,
            notes: rand.nextBool()
                ? "Eiusmod et"
                : "Amet commodo excepteur cupidatat aute magna ullamco. Sint ullamco occaecat pariatur est consequat commodo nisi consectetur laboris tempor veniam consequat. Id incididunt irure in eiusmod aliquip.",
            bloodTestDate: DateTime.now().subtract(
              Duration(
                days: rand.nextInt(daySpan),
                minutes: rand.nextInt(60),
                hours: rand.nextInt(24),
              ),
            ),
            isA1C: rand.nextInt(365) == 1,
          ),
        )
        .toList();

    if (a1cInDay) {
      list.add(
        GlucoseRecord(
          id: rand.nextInt(80),
          isA1C: true,
          glucoseLevel: 5.1,
          notes: "This is an A1C Test",
          bloodTestDate: DateTime.now().subtract(
            Duration(
              minutes: rand.nextInt(60),
              hours: rand.nextInt(24),
            ),
          ),
        ),
      );
    }

    return list;
  }
}

class ConsolidatedRecord {
  final double value;
  final DateTime date;

  const ConsolidatedRecord({
    required this.date,
    required this.value,
  });
}

// class A1CRecord {
//   final int id;
//   // final int facilityId;
//   final double glucoseLevel;
//   final String notes;
//   final DateTime bloodTestDate;

//   const A1CRecord({
//     required this.id,
//     // required this.facilityId,
//     required this.glucoseLevel,
//     required this.notes,
//     required this.bloodTestDate,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       "id": id,
//       "glucose_level": glucoseLevel,
//       "notes": notes,
//       "blood_test_date": bloodTestDate,
//     };
//   }

//   A1CRecord copyWith({
//     int? id,
//     int? facilityId,
//     double? glucoseLevel,
//     String? notes,
//     DateTime? bloodTestDate,
//   }) {
//     return A1CRecord(
//       id: id ?? this.id,
//       // facilityId: facilityId ?? this.facilityId,
//       glucoseLevel: glucoseLevel ?? this.glucoseLevel,
//       notes: notes ?? this.notes,
//       bloodTestDate: bloodTestDate ?? this.bloodTestDate,
//     );
//   }

//   static A1CRecord fromMap(Map<String, dynamic> map) {
//     return A1CRecord(
//       id: map["id"],
//       // facilityId: map["facility_id"],
//       notes: map["notes"],
//       glucoseLevel: double.parse(map["glucose_level"].toString()),
//       bloodTestDate: DateTime.parse(map["blood_test_date"]),
//     );
//   }

//   static List<A1CRecord> fromListOfMaps(List<Map<String, dynamic>> list) {
//     final result = list.map((record) => fromMap(record));

//     return result.toList();
//   }

//   static List<A1CRecord> mock(int count, int daySpan) {
//     final rand = Random();

//     return Iterable.generate(count)
//         .map(
//           (_) => A1CRecord(
//             id: rand.nextInt(80),
//             // facilityId: 1,
//             glucoseLevel: rand.nextDouble() * 10.4 + 3.4,
//             notes: rand.nextBool()
//                 ? "Eiusmod et"
//                 : "Amet commodo excepteur cupidatat aute magna ullamco. Sint ullamco occaecat pariatur est consequat commodo nisi consectetur laboris tempor veniam consequat. Id incididunt irure in eiusmod aliquip.",
//             bloodTestDate: DateTime.now().subtract(
//               Duration(
//                 days: rand.nextInt(daySpan),
//                 minutes: rand.nextInt(60),
//                 hours: rand.nextInt(24),
//               ),
//             ),
//           ),
//         )
//         .toList();
//   }
// }
