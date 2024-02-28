import 'package:dialife/nutrition_log/entities.dart';

Map<DateTime, List<NutritionRecord>> dayConsolidateNutritionRecord(
    List<NutritionRecord> records) {
  final dateMap = _groupByDate(records);

  return dateMap;
}

List<DateTime> validDaysNutritionRecord(List<NutritionRecord> records) {
  final dateMap = _groupByDate(records);
  final validDays = dateMap.keys.toList();

  validDays.sort((a, b) => a.compareTo(b));

  return validDays;
}

Map<DateTime, List<NutritionRecord>> _groupByDate(
    List<NutritionRecord> datetimes) {
  return datetimes.fold({},
      (Map<DateTime, List<NutritionRecord>> acc, NutritionRecord record) {
    DateTime date = DateTime(
        record.createdAt.year, record.createdAt.month, record.createdAt.day);
    if (acc[date] == null) {
      acc[date] = [];
    }
    acc[date]!.add(record);
    return acc;
  });
}
