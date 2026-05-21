import 'package:flutter/material.dart';

import 'inspection_item_card.dart';

class EngineCompartmentSection extends StatelessWidget {
  const EngineCompartmentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        InspectionItemCard(title: 'Oil Leaks'),
        InspectionItemCard(title: 'Coolant System'),
        InspectionItemCard(title: 'Battery Condition'),
        InspectionItemCard(title: 'Drive Belts'),
        InspectionItemCard(title: 'Engine Mountings'),
        InspectionItemCard(title: 'Fluid Levels'),
        InspectionItemCard(title: 'Wiring Condition'),
      ],
    );
  }
}
