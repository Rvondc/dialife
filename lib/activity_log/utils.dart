import 'package:dialife/activity_log/entities.dart';

Map<DateTime, List<ActivityRecord>> dayConsolidateActivityRecord(
    List<ActivityRecord> records) {
  final dateMap = _groupByDate(records);

  return dateMap;
}

List<DateTime> validDaysActivityRecord(List<ActivityRecord> records) {
  final dateMap = _groupByDate(records);
  final validDays = dateMap.keys.toList();

  validDays.sort((a, b) => a.compareTo(b));

  return validDays;
}

Map<DateTime, List<ActivityRecord>> _groupByDate(
    List<ActivityRecord> datetimes) {
  return datetimes.fold({},
      (Map<DateTime, List<ActivityRecord>> acc, ActivityRecord record) {
    DateTime date = DateTime(
        record.createdAt.year, record.createdAt.month, record.createdAt.day);
    if (acc[date] == null) {
      acc[date] = [];
    }
    acc[date]!.add(record);
    return acc;
  });
}