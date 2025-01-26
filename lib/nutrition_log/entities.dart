import 'dart:convert';

class NutritionRecord {
  final int id;
  // final double proteinInGrams;
  // final double fatsInGrams;
  final String notes;
  final String dayDescription;
  final List<String> foods;
  // final double carbohydratesInGrams;
  // final int glassesOfWater;
  final DateTime createdAt;

  Map<String, dynamic> toApiInsertable() {
    return {
      "day_description": dayDescription,
      "foods_csv": foods.join(","),
      "notes": notes,
      "recorded_at": createdAt.toIso8601String(),
    };
  }

  String toCSVRow() {
    return "$id, $dayDescription, ${base64.encode(utf8.encode(foods.join(",")))}, ${base64.encode(utf8.encode(notes))}, $createdAt";
  }

  static NutritionRecord fromMap(Map<String, dynamic> map) {
    return NutritionRecord(
      id: map["id"],
      notes: map["notes"],
      dayDescription: map["day_description"],
      foods: (map["foods_csv"] as String).split(","),
      createdAt: DateTime.parse(map["created_at"]),
    );
  }

  static NutritionRecord init({required DateTime createdAt}) {
    return NutritionRecord(
      id: -1,
      dayDescription: "",
      foods: [],
      notes: "",
      createdAt: createdAt,
    );
  }

  // static List<NutritionRecord> mock({
  //   required int count,
  //   required int daySpan,
  // }) {
  //   final rand = Random();

  //   return Iterable.generate(count).map(
  //     (_) {
  //       return NutritionRecord(
  //         id: rand.nextInt(count),
  //         proteinInGrams: rand.nextDouble() * 20 + 5,
  //         carbohydratesInGrams: rand.nextDouble() * 20 + 5,
  //         createdAt: DateTime.now().subtract(
  //           Duration(
  //             days: rand.nextInt(daySpan),
  //             minutes: rand.nextInt(60),
  //             hours: rand.nextInt(24),
  //           ),
  //         ),
  //         notes: "",
  //         fatsInGrams: rand.nextDouble() * 20 + 5,
  //         glassesOfWater: rand.nextInt(8) + 3,
  //       );
  //     },
  //   ).toList();
  // }

  static List<NutritionRecord> fromListOfMaps(List<Map<String, dynamic>> list) {
    final result = list.map((record) => fromMap(record));

    return result.toList();
  }

  @override
  String toString() {
    return "id: $id, createdAt: $createdAt";
  }

  const NutritionRecord({
    required this.id,
    required this.dayDescription,
    required this.foods,
    required this.notes,
    required this.createdAt,
  });
}

class WaterRecord {
  final int id;
  final int glasses;
  final DateTime time;

  Map<String, dynamic> toApiInsertable() {
    return {
      "id": id,
      "glasses": glasses,
      "recorded_at": time.toIso8601String(),
    };
  }

  static WaterRecord fromMap(Map<String, dynamic> map) {
    return WaterRecord(
      glasses: map["glasses"],
      id: map["id"],
      time: DateTime.parse(map["time"]),
    );
  }

  static List<WaterRecord> fromListOfMaps(List<Map<String, dynamic>> list) {
    return list.map((e) => fromMap(e)).toList();
  }

  const WaterRecord({
    required this.glasses,
    required this.id,
    required this.time,
  });
}
