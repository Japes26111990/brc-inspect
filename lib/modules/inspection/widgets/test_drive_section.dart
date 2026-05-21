import 'package:flutter/material.dart';
import '../providers/inspection_provider.dart';
import 'inspection_item_card.dart';

class TestDriveSection extends StatelessWidget {
  final ActiveInspectionProvider provider;

  const TestDriveSection({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final items = provider.sections['Test Drive'] ?? [];

    return Column(
      children:
          items.map((item) {
            return InspectionItemCard(
              item: item,
              onStatusChanged: (newStatus) {
                provider.updateComponentStatus(
                  'Test Drive',
                  item.title,
                  newStatus,
                );
              },
              onNotesChanged: (newNotes) {
                provider.updateComponentNotes(
                  'Test Drive',
                  item.title,
                  newNotes,
                );
              },
            );
          }).toList(),
    );
  }
}
