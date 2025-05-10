// time_input_section.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/error_utils.dart'; // ✅ 예외 처리 유틸 추가

class TimeInputSection extends StatefulWidget {
  final String title;
  final TextEditingController dateController;
  final TextEditingController timeController;

  const TimeInputSection({
    super.key,
    required this.title,
    required this.dateController,
    required this.timeController,
  });

  @override
  State<TimeInputSection> createState() => _TimeInputSectionState();
}

class _TimeInputSectionState extends State<TimeInputSection> {
  Future<void> _pickDate(BuildContext context, TextEditingController controller) async {
    try {
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        controller.text = "${picked.year.toString().padLeft(4, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}";
      }
    } catch (e, stack) {
      showUserFriendlyError(e);
      logError('TimeInputSection._pickDate', e, stack);
    }
  }

  Future<void> _pickTime(BuildContext context, TextEditingController controller) async {
    try {
      TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (picked != null) {
        final formatted = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
        controller.text = formatted;
      }
    } catch (e, stack) {
      showUserFriendlyError(e);
      logError('TimeInputSection._pickTime', e, stack);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.dateController,
                readOnly: true,
                onTap: () => _pickDate(context, widget.dateController),
                decoration: const InputDecoration(
                  labelText: '날짜 선택',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: widget.timeController,
                readOnly: true,
                onTap: () => _pickTime(context, widget.timeController),
                decoration: const InputDecoration(
                  labelText: '시간 선택',
                  suffixIcon: Icon(Icons.access_time),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                try {
                  final now = DateTime.now();
                  final date = "${now.year.toString().padLeft(4, '0')}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}";
                  final time = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
                  widget.dateController.text = date;
                  widget.timeController.text = time;
                } catch (e, stack) {
                  showUserFriendlyError(e);
                  logError('TimeInputSection.setNow', e, stack);
                }
              },
              child: const Text('현재'),
            ),
          ],
        ),
      ],
    );
  }
}
