import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../core/error_utils.dart'; // ✅ 예외 처리 유틸 추가

class VehicleNumberSection extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onVehicleNumberChanged;

  const VehicleNumberSection({
    super.key,
    required this.controller,
    required this.onVehicleNumberChanged,
  });

  @override
  State<VehicleNumberSection> createState() => _VehicleNumberSectionState();
}

class _VehicleNumberSectionState extends State<VehicleNumberSection> {
  bool isEditing = false;

  void toggleEdit() {
    setState(() {
      if (isEditing) {
        try {
          final value = widget.controller.text.trim();

          widget.onVehicleNumberChanged(value);

          Fluttertoast.showToast(
            msg: "차량번호가 저장되었습니다.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        } catch (e, stack) {
          showUserFriendlyError(e);
          logError('VehicleNumberSection.toggleEdit', e, stack);
        }
      }
      isEditing = !isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: isEditing
                ? TextField(
              controller: widget.controller,
              decoration: const InputDecoration(
                labelText: '차량번호 입력',
                isDense: true,
              ),
            )
                : Text(
              '차량번호: ${widget.controller.text}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit),
            tooltip: isEditing ? '확인' : '수정',
            onPressed: toggleEdit,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose(); // ✅ 외부 controller이므로 dispose 안 함
  }
}
