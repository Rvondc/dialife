import 'package:dialife/bmi_tracking/entities.dart';

double? calcAverageBMIRecord(
    DateTime start, DateTime end, List<BMIRecord> records) {
  final validData = records
      .where((element) =>
          element.createdAt.isBefore(end) && element.createdAt.isAfter(start))
      .toList();

  if (validData.isEmpty) {
    return null;
  }

  final bmiList = validData
      .map((record) =>
          record.weightInKilograms /
          (record.heightInMeters * record.heightInMeters))
      .toList();

  final average =
      bmiList.reduce((value, element) => value + element) / bmiList.length;

  return average;
}

double changeInLatest(List<BMIRecord> records) {
  if (records.isEmpty) {
    throw StateError("No Element");
  }

  if (records.length < 2) {
    return 0;
  }

  final latestBMI = records.last.weightInKilograms /
      (records.last.heightInMeters * records.last.heightInMeters);

  final previousLatest = records[records.length - 2];

  final previousLatestBMI = previousLatest.weightInKilograms /
      (previousLatest.heightInMeters * previousLatest.heightInMeters);

  return latestBMI - previousLatestBMI;
}
