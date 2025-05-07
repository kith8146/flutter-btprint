import '../models/print_record.dart';
import 'database_helper.dart';

/// 전역 기록 리스트
List<PrintRecord> printRecords = [];

/// DB에서 기록을 불러와 전역 리스트에 저장
Future<void> loadPrintRecords() async {
  final dbRecords = await DatabaseHelper().getAllRecords();
  printRecords.clear();
  printRecords.addAll(dbRecords);
}

/// 새 기록을 리스트와 DB에 모두 추가
Future<void> addPrintRecord(PrintRecord record) async {
  printRecords.add(record);
  await DatabaseHelper().insertRecord(record);
}

/// (선택) 모든 기록 삭제
Future<void> clearAllRecords() async {
  printRecords.clear();
  await DatabaseHelper().deleteAllRecords();
}
