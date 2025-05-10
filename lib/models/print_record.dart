// print_record.dart
class PrintRecord {
  final int id;
  final DateTime timestamp;
  final String contentText;

  PrintRecord({
    required this.id,
    required this.timestamp,
    required this.contentText,
  });

  /// DB 저장용 Map 변환
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'contentText': contentText,
    };
  }

  /// DB에서 가져온 Map을 객체로 변환
  factory PrintRecord.fromMap(Map<String, dynamic> map) {
    try {
      return PrintRecord(
        id: map['id'] as int,
        timestamp: DateTime.parse(map['timestamp'] as String),
        contentText: map['contentText'] as String,
      );
    } catch (e) {
      // 안전하게 실패를 감지하고 기본값 반환
      return PrintRecord(
        id: -1,
        timestamp: DateTime(2000), // 비정상 처리
        contentText: '[파싱 오류]',
      );
    }
  }
}
