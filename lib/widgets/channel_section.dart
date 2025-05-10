import 'package:flutter/material.dart';

class ChannelSection extends StatelessWidget {
  final String title;
  final String selectedState;
  final void Function(String state) onStateSelected;
  final Map<String, TextEditingController> controllers;

  const ChannelSection({
    super.key,
    required this.title,
    required this.selectedState,
    required this.onStateSelected,
    required this.controllers,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8,
          children: ['냉동', '냉장', '상온', '없음'].map((label) {
            final isSelected = label == selectedState;
            return FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => onStateSelected(label),
            );
          }).toList(),
        ),
        TextField(
          controller: controllers['1'],
          decoration: const InputDecoration(labelText: '온도1'),
          keyboardType: TextInputType.number,
        ),
        TextField(
          controller: controllers['2'],
          decoration: const InputDecoration(labelText: '온도2'),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}
