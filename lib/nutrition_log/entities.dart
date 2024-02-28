import 'dart:convert';
import 'dart:math';

class NutritionRecord {
  final int id;
  final double proteinInGrams;
  final double fatsInGrams;
  final String notes;
  final double carbohydratesInGrams;
  final int glassesOfWater;
  final DateTime createdAt;

  String toCSVRow() {
    return "$id, $proteinInGrams, $fatsInGrams, $carbohydratesInGrams, $glassesOfWater, ${base64.encode(utf8.encode(notes))}, $createdAt";
  }

  static NutritionRecord fromMap(Map<String, dynamic> map) {
    return NutritionRecord(
      id: map["id"],
      proteinInGrams: map["protein"].toDouble(),
      notes: map["notes"],
      carbohydratesInGrams: map["carbohydrates"].toDouble(),
      createdAt: DateTime.parse(map["created_at"]),
      fatsInGrams: map["fat"].toDouble(),
      glassesOfWater: map["water"],
    );
  }

  static NutritionRecord init({required DateTime createdAt}) {
    return NutritionRecord(
      id: -1,
      proteinInGrams: 0,
      notes: "",
      carbohydratesInGrams: 0,
      createdAt: createdAt,
      fatsInGrams: 0,
      glassesOfWater: 0,
    );
  }

  static List<NutritionRecord> mock({
    required int count,
    required int daySpan,
  }) {
    final rand = Random();

    return Iterable.generate(count).map(
      (_) {
        return NutritionRecord(
          id: rand.nextInt(count),
          proteinInGrams: rand.nextDouble() * 20 + 5,
          carbohydratesInGrams: rand.nextDouble() * 20 + 5,
          createdAt: DateTime.now().subtract(
            Duration(
              days: rand.nextInt(daySpan),
              minutes: rand.nextInt(60),
              hours: rand.nextInt(24),
            ),
          ),
          notes: "",
          fatsInGrams: rand.nextDouble() * 20 + 5,
          glassesOfWater: rand.nextInt(8) + 3,
        );
      },
    ).toList();
  }

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
    required this.proteinInGrams,
    required this.carbohydratesInGrams,
    required this.notes,
    required this.createdAt,
    required this.fatsInGrams,
    required this.glassesOfWater,
  });
}
