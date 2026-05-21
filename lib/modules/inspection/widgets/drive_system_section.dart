import 'package:flutter/material.dart';
import '../providers/inspection_provider.dart';
import '../models/inspection_models.dart';
import 'inspection_item_card.dart';

class DriveSystemSection extends StatelessWidget {
  final ActiveInspectionProvider provider;

  const DriveSystemSection({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final driveItems = provider.sections['Drive System'] ?? [];

    return Column(
      children:
          driveItems.map((item) {
            return InspectionItemCard(
              item: item,
              onStatusChanged: (newStatus) {
                provider.updateComponentStatus(
                  'Drive System',
                  item.title,
                  newStatus,
                );
              },
              onNotesChanged: (newNotes) {
                provider.updateComponentNotes(
                  'Drive System',
                  item.title,
                  newNotes,
                );
              },
            );
          }).toList(),
    );
  }
}
