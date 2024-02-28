import 'dart:convert';

class ActivityRecord {
  final int id;
  final ExerciseType type;
  final int duration;
  final int frequency;
  final String notes;
  final DateTime createdAt;

  String toCSVRow() {
    return "$id, ${type.asString}, $duration, $frequency, ${base64.encode(utf8.encode(notes))}, $createdAt";
  }

  static ActivityRecord fromMap(Map<String, dynamic> map) {
    return ActivityRecord(
      id: map["id"],
      type: parseExerciseType(map["type"]),
      duration: map["duration"],
      frequency: map["frequency"],
      notes: map["notes"],
      createdAt: DateTime.parse(map["created_at"]),
    );
  }

  static List<ActivityRecord> fromListOfMaps(List<Map<String, dynamic>> list) {
    final result = list.map((record) => fromMap(record));

    return result.toList();
  }

  @override
  String toString() {
    return "id: $id, type: $type";
  }

  const ActivityRecord({
    required this.id,
    required this.type,
    required this.frequency,
    required this.duration,
    required this.notes,
    required this.createdAt,
  });
}

ExerciseType parseExerciseType(String type) {
  switch (type) {
    case "walking":
      return ExerciseType.aerobic;
    case "zumba":
      return ExerciseType.strength;
    case "lifting":
      return ExerciseType.flexibility;
    case "jogging":
      return ExerciseType.balance;
  }

  throw Exception("Invalid typed passed to _parseType");
}

enum ExerciseType {
  aerobic,
  strength,
  balance,
  flexibility,
}

extension StringConvExtension on ExerciseType {
  String get asString {
    return switch (this) {
      ExerciseType.aerobic => "walking",
      ExerciseType.strength => "zumba",
      ExerciseType.balance => "jogging",
      ExerciseType.flexibility => "lifting",
    };
  }
}
