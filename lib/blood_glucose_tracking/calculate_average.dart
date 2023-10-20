import 'package:dialife/blood_glucose_tracking/entities.dart';

double? calcAverageGlucoseRecord(
    DateTime start, DateTime end, List<GlucoseRecord> records) {
  final validData = records
      .where((element) =>
          element.bloodTestDate.isBefore(end) &&
          element.bloodTestDate.isAfter(start))
      .toList();

  if (validData.isEmpty) {
    return null;
  }

  final average = validData
          .map((record) => record.glucoseLevel)
          .reduce((value, element) => value + element) /
      validData.length;

  return average;
}

double changeInLatest(List<GlucoseRecord> records) {
  if (records.isEmpty) {
    throw StateError("No Element");
  }

  if (records.length < 2) {
    return 0;
  }

  final latest = records.last.glucoseLevel;
  final previousLatest = records[records.length - 2].glucoseLevel;

  return latest - previousLatest;
}
