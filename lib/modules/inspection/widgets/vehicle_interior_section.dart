import 'package:flutter/material.dart';

import 'inspection_item_card.dart';

class VehicleInteriorSection extends StatelessWidget {
  const VehicleInteriorSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        InspectionItemCard(title: 'Seats'),
        InspectionItemCard(title: 'Dashboard'),
        InspectionItemCard(title: 'Roof Lining'),
        InspectionItemCard(title: 'Air Conditioning'),
        InspectionItemCard(title: 'Infotainment System'),
        InspectionItemCard(title: 'Windows'),
        InspectionItemCard(title: 'Seat Belts'),
      ],
    );
  }
}
