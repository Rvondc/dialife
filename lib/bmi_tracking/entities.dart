import 'dart:math';

class BMIRecord {
  final int id;
  final double heightInMeters;
  final double weightInKilograms;
  final String notes;
  final DateTime createdAt;

  const BMIRecord({
    required this.id,
    required this.heightInMeters,
    required this.weightInKilograms,
    required this.notes,
    required this.createdAt,
  });

  double get bmi {
    return weightInKilograms / (heightInMeters * heightInMeters);
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "height": heightInMeters,
      "weight": weightInKilograms,
      "notes": notes,
      "created_at": createdAt,
    };
  }

  static List<BMIRecord> mock(int count, int daySpan) {
    final rand = Random();

    return Iterable.generate(count)
        .map(
          (_) => BMIRecord(
            id: rand.nextInt(100),
            heightInMeters: (rand.nextDouble() * 0.4) + 1.4,
            weightInKilograms: rand.nextInt(50) + 45,
            notes: rand.nextBool()
                ? "Eiusmod et"
                : "Amet commodo excepteur cupidatat aute magna ullamco. Sint ullamco occaecat pariatur est consequat commodo nisi consectetur laboris tempor veniam consequat. Id incididunt irure in eiusmod aliquip.",
            createdAt: DateTime.now().subtract(
              Duration(
                days: rand.nextInt(daySpan),
                minutes: rand.nextInt(60),
                hours: rand.nextInt(24),
              ),
            ),
          ),
        )
        .toList();
  }

  static List<BMIRecord> fromListOfMaps(List<Map<String, dynamic>> list) {
    final result = list.map((record) => fromMap(record));

    return result.toList();
  }

  static BMIRecord fromMap(Map<String, dynamic> map) {
    return BMIRecord(
      id: map["id"],
      heightInMeters: map["height"],
      weightInKilograms: map["weight"],
      notes: map["notes"],
      createdAt: DateTime.parse(map["created_at"]),
    );
  }
}
