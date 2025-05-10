// lib/core/record_store.dart
import '../models/print_record.dart';
import 'database_helper.dart';
import 'error_utils.dart'; // ✅ 예외 처리 유틸 추가

/// 전역 기록 리스트
List<PrintRecord> printRecords = [];

/// DB에서 기록을 불러와 전역 리스트에 저장
Future<void> loadPrintRecords() async {
  try {
    final dbRecords = await DatabaseHelper().getAllRecords();
    printRecords
      ..clear()
      ..addAll(dbRecords);
  } catch (e, stack) {
    logError('RecordStore.loadPrintRecords', e, stack);
    showUserFriendlyError(e);
  }
}

/// 새 기록을 리스트와 DB에 모두 추가
Future<void> addPrintRecord(DateTime timestamp, String contentText) async {
  try {
    // 1) DB에 삽입하고 생성된 id 획득
    final id = await DatabaseHelper().insertRecord(
      PrintRecord(id: 0, timestamp: timestamp, contentText: contentText),
    );

    if (id == -1) throw Exception('DB 삽입 실패');

    // 2) 실제 사용할 객체 생성 후 리스트 맨 앞에 삽입
    final rec = PrintRecord(id: id, timestamp: timestamp, contentText: contentText);
    printRecords.insert(0, rec);

    print("📄 현재 저장된 기록 수: ${printRecords.length}");
  } catch (e, stack) {
    logError('RecordStore.addPrintRecord', e, stack);
    showUserFriendlyError(e);
  }
}

/// id로 개별 삭제
Future<void> deleteRecordById(int id) async {
  try {
    printRecords.removeWhere((r) => r.id == id);
    await DatabaseHelper().deleteById(id);
  } catch (e, stack) {
    logError('RecordStore.deleteRecordById', e, stack);
    showUserFriendlyError(e);
  }
}

/// 모든 기록 삭제
Future<void> clearAllRecords() async {
  try {
    printRecords.clear();
    await DatabaseHelper().deleteAllRecords();
  } catch (e, stack) {
    logError('RecordStore.clearAllRecords', e, stack);
    showUserFriendlyError(e);
  }
}
