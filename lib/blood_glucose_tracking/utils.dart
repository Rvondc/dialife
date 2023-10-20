import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dialife/blood_glucose_tracking/entities.dart';
import 'package:flutter/material.dart';

Widget waitForFuture<T>(
    {Widget loading = const Placeholder(),
    required Future<T> future,
    required Widget Function(BuildContext context, T data) builder}) {
  return FutureBuilder(
    future: future,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return loading;
      }

      return builder(context, snapshot.data as T);
    },
  );
}

List<GlucoseRecord> sparsifyGlucoseRecords(
    List<GlucoseRecord> input, int maxPerDay) {
  final consolidated = input.groupFoldBy(
    (element) => element.bloodTestDate.copyWith(
        hour: 0, minute: 0, second: 0, microsecond: 0, millisecond: 0),
    (List<GlucoseRecord>? previous, element) => (previous ?? [])..add(element),
  );

  return consolidated.entries
      .map((map) {
        map.value.shuffle(Random(0x43f234));
        final randomized = map.value.take(maxPerDay).toList();
        randomized.sort((a, b) => a.bloodTestDate.compareTo(b.bloodTestDate));

        return randomized;
      })
      .flattened
      .toList();
}

List<ConsolidatedRecord> consolidateToDay(List<GlucoseRecord> input) {
  final consolidated = input.groupFoldBy(
    (element) => element.bloodTestDate.copyWith(hour: 0, minute: 0),
    (List<GlucoseRecord>? previous, element) => (previous ?? [])..add(element),
  );

  final parsed = consolidated.entries.map((map) {
    final consolidatedValue =
        map.value.map((record) => record.glucoseLevel).reduce((v, e) => v + e) /
            map.value.length;
    return ConsolidatedRecord(date: map.key, value: consolidatedValue);
  });

  return parsed.toList();
}

class DateScope {
  final DateTime start;
  final DateTime end;

  const DateScope({
    required this.start,
    required this.end,
  });

  int get delta {
    return end.difference(start).inDays;
  }

  static DateScope day(DateTime end) {
    return DateScope(
        start: end.subtract(const Duration(days: 1)),
        end: end.add(const Duration(seconds: 1)));
  }

  static DateScope week(DateTime end) {
    return DateScope(
        start: end.subtract(const Duration(days: 7)),
        end: end.add(const Duration(seconds: 1)));
  }

  static DateScope month(DateTime end) {
    return DateScope(
        start: end.subtract(const Duration(days: 30)),
        end: end.add(const Duration(seconds: 1)));
  }

  static DateScope allTime(DateTime end) {
    return DateScope(
        start: DateTime.fromMillisecondsSinceEpoch(0),
        end: end.add(const Duration(seconds: 1)));
  }
}

double mmolLToMgDL(double mmolPerLiter) {
  return mmolPerLiter * 18.0;
}

double mgDLToMmolL(double mgPerDL) {
  return mgPerDL / 18.0;
}
