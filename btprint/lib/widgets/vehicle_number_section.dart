import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
        widget.onVehicleNumberChanged(widget.controller.text);

        // ✅ 토스트 메시지 띄우기
        Fluttertoast.showToast(
          msg: "차량번호가 저장되었습니다.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
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
    super.dispose(); // ✅ 외부에서 받은 controller는 dispose하지 않음
  }
}
