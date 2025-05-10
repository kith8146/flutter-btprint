// lib/core/record_store.dart
import '../models/print_record.dart';
import 'database_helper.dart';

/// 전역 기록 리스트
List<PrintRecord> printRecords = [];

/// DB에서 기록을 불러와 전역 리스트에 저장
Future<void> loadPrintRecords() async {
  final dbRecords = await DatabaseHelper().getAllRecords();
  printRecords
    ..clear()
    ..addAll(dbRecords);
}

/// 새 기록을 리스트와 DB에 모두 추가
Future<void> addPrintRecord(DateTime timestamp, String contentText) async {
  // 1) DB에 삽입하고 생성된 id 획득
  final id = await DatabaseHelper().insertRecord(
    PrintRecord(id: 0, timestamp: timestamp, contentText: contentText),
  );
  // 2) 실제 사용할 객체 생성 후 리스트 맨 앞에 삽입
  final rec = PrintRecord(id: id, timestamp: timestamp, contentText: contentText);
  printRecords.insert(0, rec);
// 디버깅용 출력

  print("📄 현재 저장된 기록 수: ${printRecords.length}");

}

/// id로 개별 삭제
Future<void> deleteRecordById(int id) async {
  // 1) 전역 리스트에서 제거
  printRecords.removeWhere((r) => r.id == id);
  // 2) DB에서도 삭제
  await DatabaseHelper().deleteById(id);
}

/// 모든 기록 삭제
Future<void> clearAllRecords() async {
  printRecords.clear();
  await DatabaseHelper().deleteAllRecords();
}
