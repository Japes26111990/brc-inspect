import 'package:flutter/material.dart';
import '../providers/inspection_provider.dart';
import 'inspection_item_card.dart';

class VehicleInteriorSection extends StatelessWidget {
  final ActiveInspectionProvider provider;

  const VehicleInteriorSection({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final items = provider.sections['Vehicle Interior'] ?? [];

    return Column(
      children:
          items.map((item) {
            return InspectionItemCard(
              item: item,
              onStatusChanged: (newStatus) {
                provider.updateComponentStatus(
                  'Vehicle Interior',
                  item.title,
                  newStatus,
                );
              },
              onNotesChanged: (newNotes) {
                provider.updateComponentNotes(
                  'Vehicle Interior',
                  item.title,
                  newNotes,
                );
              },
            );
          }).toList(),
    );
  }
}
