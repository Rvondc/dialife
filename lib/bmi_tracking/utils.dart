import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dialife/bmi_tracking/entities.dart';

List<BMIRecord> sparsifyBMIRecords(List<BMIRecord> input, int maxPerDay) {
  final consolidated = input.groupFoldBy(
    (element) => element.createdAt.copyWith(
        hour: 0, minute: 0, second: 0, microsecond: 0, millisecond: 0),
    (List<BMIRecord>? previous, element) => (previous ?? [])..add(element),
  );

  return consolidated.entries
      .map((map) {
        map.value.shuffle(Random(0x43f234));
        final randomized = map.value.take(maxPerDay).toList();
        randomized.sort((a, b) => a.createdAt.compareTo(b.createdAt));

        return randomized;
      })
      .flattened
      .toList();
}
