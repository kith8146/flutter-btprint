// print_utils.dart
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';




// ✅ 채널 온도 범위 기반 랜덤 생성 함수
String generateRandomFromInput(String t1, String t2) {
  final d1 = double.tryParse(t1);
  final d2 = double.tryParse(t2);
  if (d1 == null || d2 == null) return '';

  final min = d1 < d2 ? d1 : d2;
  final max = d1 > d2 ? d1 : d2;
  final rand = Random().nextDouble();
  final value = min + rand * (max - min);  // -1.0 ~ +1.0
  return value.toStringAsFixed(1);
}


// ✅ 출력 텍스트 생성 함수
String generateSamplePrintText({
  String vehicleNumber = "0000",
  String interval = "30분",
  String loadTime = "",
  String unloadTime = "",
  bool userStop = false,
  bool oneDayOnly = false,
  required String channelAState,
  required String channelBState,
  List<Map<String, String>> records = const [],
}) {
  final buffer = StringBuffer();
  buffer.writeln("차량번호: $vehicleNumber");
  buffer.writeln("기록간격: $interval");
  buffer.writeln("상 호:");

  String? currentDateHeader;

  for (var i = 0; i < records.length; i++) {
    final r = records[i];

    if (r.containsKey("date")) {
      final newDate = r["date"];
      if (newDate != currentDateHeader) {
        buffer.writeln();
        buffer.writeln(newDate);
        buffer.writeln(); //날짜 출력 후 한 줄 더 띄우기
        currentDateHeader = newDate;
      }
      continue;
    }

    final timeStr = r['time'] ?? '';
    final time = "${timeStr}${r['start'] == "S" ? "S" : ""}".padRight(7);

    final aRaw = r['a'] ?? '';
    final bRaw = r['b'] ?? '';

    final aValue = double.tryParse(aRaw);
    final bValue = double.tryParse(bRaw);

    final a = aValue != null
        ? "${aValue >= 0 ? "+" : ""}${aValue.toStringAsFixed(1)}"
        : aRaw;
    final b = bValue != null
        ? "${bValue >= 0 ? "+" : ""}${bValue.toStringAsFixed(1)}"
        : bRaw;

    buffer.writeln(" $time A: $a°C B: $b°C");

    if (r['start'] == "S") {
      buffer.writeln();
    }
  }

  if (userStop) buffer.writeln("USER STOP");
  if (oneDayOnly) buffer.writeln("1DAY PRINT END");
  return buffer.toString();
}

Future<Uint8List> textToImageBytes(String text, {double fontSize = 22.0}) async {
  const double maxWidth = 360.0; // PT-210 출력 폭 기준
  const double bottomPadding = 40.0;

  final textStyle = TextStyle(
    color: Colors.black,
    fontSize: fontSize,
    fontFamily: 'Roboto',
    letterSpacing: 2.0,
  );

  final textSpan = TextSpan(
    text: text,
    style: textStyle,
  );

  final textPainter = TextPainter(
    text: textSpan,
    textDirection: ui.TextDirection.ltr,
    textAlign: TextAlign.left,
    textWidthBasis: TextWidthBasis.longestLine, // 🔹 각 줄의 최대 길이 기준
  );

  textPainter.layout(maxWidth: maxWidth);

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  // 배경 흰색
  final paint = Paint()..color = Colors.white;
  final width = maxWidth;
  final height = textPainter.height + bottomPadding;

  canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);

  // 텍스트 출력
  textPainter.paint(canvas, const Offset(0, 0));

  final picture = recorder.endRecording();
  final image = await picture.toImage(width.ceil(), height.ceil());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

  return byteData!.buffer.asUint8List();
}

