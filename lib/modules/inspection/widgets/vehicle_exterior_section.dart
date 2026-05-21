import 'package:flutter/material.dart';
import '../providers/inspection_provider.dart';
import 'inspection_item_card.dart';

class VehicleExteriorSection extends StatelessWidget {
  final ActiveInspectionProvider provider;

  const VehicleExteriorSection({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final items = provider.sections['Vehicle Exterior'] ?? [];

    return Column(
      children:
          items.map((item) {
            return InspectionItemCard(
              item: item,
              onStatusChanged: (newStatus) {
                provider.updateComponentStatus(
                  'Vehicle Exterior',
                  item.title,
                  newStatus,
                );
              },
              onNotesChanged: (newNotes) {
                provider.updateComponentNotes(
                  'Vehicle Exterior',
                  item.title,
                  newNotes,
                );
              },
            );
          }).toList(),
    );
  }
}
