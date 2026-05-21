import 'package:flutter/material.dart';
import '../providers/inspection_provider.dart';
import 'inspection_item_card.dart';

class WheelsTyresSection extends StatelessWidget {
  final ActiveInspectionProvider provider;

  const WheelsTyresSection({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final items =
        provider.sections['Mechanics & Wheels'] ??
        provider.sections['Wheels & Tyres'] ??
        [];

    return Column(
      children:
          items.map((item) {
            return InspectionItemCard(
              item: item,
              onStatusChanged: (newStatus) {
                provider.updateComponentStatus(
                  'Wheels & Tyres',
                  item.title,
                  newStatus,
                );
              },
              onNotesChanged: (newNotes) {
                provider.updateComponentNotes(
                  'Wheels & Tyres',
                  item.title,
                  newNotes,
                );
              },
            );
          }).toList(),
    );
  }
}
