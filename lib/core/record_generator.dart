// record_generator.dart
import 'dart:math';
import 'package:intl/intl.dart';

import 'error_utils.dart'; // ✅ 예외 처리를 위해 추가

List<Map<String, String>> generatePrintRecords({
  required DateTime start,
  required DateTime end,
  required int intervalMinutes,
  required double minA,
  required double maxA,
  required double minB,
  required double maxB,
}) {
  try {
    final List<Map<String, String>> result = [];

    // ✅ 시간 순서를 거꾸로 정렬하므로 end부터 시작
    List<DateTime> timePoints = [];

    DateTime current = end;

    while (!current.isBefore(start)) {
      timePoints.add(current);
      current = current.subtract(Duration(minutes: intervalMinutes));
    }

    // ✅ 마지막으로 start 시간이 포함되어 있지 않으면 추가
    if (timePoints.isEmpty || timePoints.last.isAfter(start)) {
      timePoints.add(start);
    }

    String? lastDate;
    bool isFirst = true;

    for (DateTime t in timePoints) {
      final formattedTime = DateFormat("HH:mm").format(t);
      final formattedDate = DateFormat("yyyy年MM月dd日").format(t);

      if (lastDate != formattedDate) {
        result.add({"date": formattedDate});
        lastDate = formattedDate;
      }

      final aRand = Random().nextDouble() * (maxA - minA) + minA;
      final bRand = Random().nextDouble() * (maxB - minB) + minB;

      final lower = aRand < bRand ? aRand : bRand;
      final higher = aRand < bRand ? bRand : aRand;

      final aTemp = lower.toStringAsFixed(1);
      final bTemp = higher.toStringAsFixed(1);

      result.add({
        "time": formattedTime,
        "a": aTemp,
        "b": bTemp,
        "start": isFirst ? "S" : "",
      });

      isFirst = false;
    }

    return result;
  } catch (e, stack) {
    logError('RecordGenerator.generatePrintRecords', e, stack);
    showUserFriendlyError(e);
    return []; // 앱 강제 종료 방지
  }
}
