//print_history_page
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/print_record.dart';
import '../core/print_utils.dart';
import '../core/bluetooth_printer_service.dart';
import '../core/record_store.dart';

class PrintHistoryPage extends StatefulWidget {
  const PrintHistoryPage({super.key});

  @override
  State<PrintHistoryPage> createState() => _PrintHistoryPageState();
}

class _PrintHistoryPageState extends State<PrintHistoryPage> {
  List<PrintRecord> _records = [];          // 전체 기록 리스트
  DateTime? selectedDate;                   // 선택된 날짜 필터 (null이면 전체 보기)

  @override
  void initState() {
    super.initState();
    _loadRecords();                         // 화면 진입 시 기록 로드
  }

  // ✅ DB에서 기록 불러오기
  Future<void> _loadRecords() async {
    await loadPrintRecords();              // DB → 전역 리스트
    setState(() => _records = List.from(printRecords)); // 화면에 표시할 리스트 설정
  }

  // ✅ 개별 삭제
  Future<void> _deleteRecord(int id, int index) async {
    await deleteRecordById(id);            // DB 및 전역 리스트에서 제거
    setState(() => _records.removeAt(index)); // 화면 갱신
  }

  // ✅ 전체 삭제
  Future<void> _clearAll() async {
    await clearAllRecords();               // DB 및 전역 리스트 초기화
    setState(() => _records.clear());      // 화면 리스트도 초기화
  }

  // ✅ 날짜 필터링된 리스트 반환
  List<PrintRecord> get filteredRecords {
    if (selectedDate == null) return _records;
    return _records.where((r) => isSameDay(r.timestamp, selectedDate!)).toList();
  }

  // ✅ 날짜가 같은지 비교
  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 날짜별로 그룹화된 Map 생성
    final grouped = <String, List<PrintRecord>>{};
    for (var rec in filteredRecords) {
      final date = DateFormat('yyyy-MM-dd').format(rec.timestamp);
      grouped.putIfAbsent(date, () => []).add(rec);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('인쇄 기록'),
        actions: [
          // ✅ 전체 삭제 버튼
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: '모두 삭제',
            onPressed: _records.isEmpty
                ? null
                : () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('모든 기록 삭제'),
                  content: const Text('정말 모든 기록을 삭제하시겠습니까?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
                    TextButton(onPressed: () {
                      Navigator.pop(context);
                      _clearAll(); // 삭제 실행
                    }, child: const Text('삭제')),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // ✅ 날짜 선택 및 전체 보기 버튼
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 날짜 선택 버튼
                TextButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    selectedDate == null
                        ? '전체 날짜 보기'
                        : DateFormat('yyyy-MM-dd').format(selectedDate!),
                  ),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                ),
                // 전체 보기 버튼 (날짜 필터 해제)
                if (selectedDate != null)
                  TextButton(
                    onPressed: () => setState(() => selectedDate = null),
                    child: const Text('전체 보기'),
                  ),
              ],
            ),
          ),

          const Divider(height: 0),

          // ✅ 기록 리스트 (날짜별 그룹화 + 카드 UI)
          Expanded(
            child: filteredRecords.isEmpty
                ? const Center(child: Text('해당 날짜에 저장된 인쇄 기록이 없습니다.'))
                : ListView(
              children: grouped.entries.map((entry) {
                final date = entry.key;
                final items = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 날짜 헤더
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Text(
                        date,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    // 각 기록 카드 렌더링
                    ...items.map((record) {
                      final idx = _records.indexOf(record);
                      final time = DateFormat('HH:mm').format(record.timestamp);
                      final preview = record.contentText.split('\n').first;

                      return Dismissible(
                        key: ValueKey(record.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _deleteRecord(record.id, idx),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          child: ListTile(
                            title: Text('기록 ${idx + 1}   $time'),
                            subtitle: Text(
                              preview.length > 40
                                  ? '${preview.substring(0, 40)}…'
                                  : preview,
                            ),
                            // 🔁 재인쇄 버튼
                            trailing: IconButton(
                              icon: const Icon(Icons.print),
                              onPressed: () async {
                                final img = await textToImageBytes(record.contentText);
                                await BluetoothPrinterService().printImage(img);
                              },
                            ),
                            // 👁 미리보기 다이얼로그
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text('기록 ${idx + 1} 미리보기'),
                                  content: SingleChildScrollView(
                                    child: Text(record.contentText),
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('닫기')),
                                    ElevatedButton(
                                        onPressed: () async {
                                          final img = await textToImageBytes(record.contentText);
                                          await BluetoothPrinterService().printImage(img);
                                          Navigator.pop(context);
                                        },
                                        child: const Text('재인쇄')),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
