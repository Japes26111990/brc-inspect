import 'package:flutter/material.dart';
import '../providers/inspection_provider.dart';
import 'inspection_item_card.dart';

class EngineCompartmentSection extends StatelessWidget {
  final ActiveInspectionProvider provider;

  const EngineCompartmentSection({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final items = provider.sections['Engine Compartment'] ?? [];

    return Column(
      children:
          items.map((item) {
            return InspectionItemCard(
              item: item,
              onStatusChanged: (newStatus) {
                provider.updateComponentStatus(
                  'Engine Compartment',
                  item.title,
                  newStatus,
                );
              },
              onNotesChanged: (newNotes) {
                provider.updateComponentNotes(
                  'Engine Compartment',
                  item.title,
                  newNotes,
                );
              },
            );
          }).toList(),
    );
  }
}
