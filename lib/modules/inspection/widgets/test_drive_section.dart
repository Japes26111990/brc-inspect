import 'package:flutter/material.dart';

import 'inspection_item_card.dart';

class TestDriveSection extends StatelessWidget {
  const TestDriveSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        InspectionItemCard(title: 'Engine Performance'),
        InspectionItemCard(title: 'Gearbox Operation'),
        InspectionItemCard(title: 'Braking Performance'),
        InspectionItemCard(title: 'Steering Response'),
        InspectionItemCard(title: 'Suspension Noise'),
        InspectionItemCard(title: 'Wheel Alignment'),
      ],
    );
  }
}
