// print_controller.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../main.dart'; // navigatorKey
import 'print_utils.dart';
import 'record_generator.dart';
import 'bluetooth_printer_service.dart';
import 'record_store.dart';
import '../models/print_record.dart';
import '../core/error_utils.dart';

void exampleGenerateAndPrintText({
  required String vehicleNumber,
  required String intervalText,
  required String loadDate,
  required String loadTime,
  required String unloadDate,
  required String unloadTime,
  required bool userChecked,
  required bool oneDayChecked,
  required double minA,
  required double maxA,
  required double minB,
  required double maxB,
  required String channelAState,
  required String channelBState,
}) {
  try {
    final start = DateFormat("yyyy/MM/dd HH:mm").parse("$loadDate $loadTime");
    final end = DateFormat("yyyy/MM/dd HH:mm").parse("$unloadDate $unloadTime");
    final interval = int.parse(intervalText.replaceAll("분", ""));

    final records = generatePrintRecords(
      start: oneDayChecked ? end.subtract(const Duration(hours: 24)) : start,
      end: end,
      intervalMinutes: interval,
      minA: minA,
      maxA: maxA,
      minB: minB,
      maxB: maxB,
    );

    final text = generateSamplePrintText(
      vehicleNumber: vehicleNumber,
      interval: intervalText,
      loadTime: "$loadDate $loadTime",
      unloadTime: "$unloadDate $unloadTime",
      userStop: userChecked,
      oneDayOnly: oneDayChecked,
      channelAState: channelAState,
      channelBState: channelBState,
      records: records,
    );

    debugPrint("=========== PRINT OUTPUT ===========");
    debugPrint(text);
    debugPrint("====================================");

    showDialog(
      context: navigatorKey.currentContext!,
      builder: (_) => AlertDialog(
        title: const Text('프린트 미리보기'),
        content: SingleChildScrollView(child: Text(text)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(navigatorKey.currentContext!),
            child: const Text('닫기'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final printer = BluetoothPrinterService();
                final imageBytes = await textToImageBytes(text);
                await printer.printImage(imageBytes); // ✅ 인쇄 시도

                // ✅ 인쇄 성공 후에만 기록 저장
                await addPrintRecord(DateTime.now(), text);

                Navigator.pop(navigatorKey.currentContext!); // 닫기
              } catch (e, stack) {
                showUserFriendlyError(e);
                logError('PrintController.printAndSave', e, stack); // ✅ 로그 추가
              }
            },
            child: const Text('인쇄'),
          ),
        ],
      ),
    );
  } catch (e, stack) {
    showUserFriendlyError(e);
    logError('PrintController.exampleGenerateAndPrintText', e, stack); // ✅ 로그 추가
  }
}
