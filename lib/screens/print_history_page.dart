//print_history_page
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/print_record.dart';
import '../core/print_utils.dart';
import '../core/bluetooth_printer_service.dart';


class PrintHistoryPage extends StatelessWidget {
  final List<PrintRecord> records;

  const PrintHistoryPage({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('인쇄 기록'),
      ),
      body: records.isEmpty
          ? const Center(child: Text('저장된 인쇄 기록이 없습니다.'))
          : ListView.builder(
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          final formattedTime =
          DateFormat('yyyy-MM-dd HH:mm').format(record.timestamp);

          return ListTile(
            title: Text('기록 ${index + 1}'),
            subtitle: Text('인쇄 시각: $formattedTime'),
            trailing: IconButton(
              icon: const Icon(Icons.print),
              onPressed: () async {
                final imageBytes = await textToImageBytes(record.contentText);
                final printer = BluetoothPrinterService();
                await printer.printImage(imageBytes);
              },
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('기록 ${index + 1} 미리보기'),
                  content: SingleChildScrollView(
                    child: Text(record.contentText),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('닫기'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final imageBytes = await textToImageBytes(record.contentText);
                        final printer = BluetoothPrinterService();
                        await printer.printImage(imageBytes);
                        Navigator.pop(context);
                      },
                      child: const Text('다시 인쇄'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
