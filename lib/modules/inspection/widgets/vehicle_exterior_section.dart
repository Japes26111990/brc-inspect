import 'package:flutter/material.dart';

import 'inspection_item_card.dart';

class VehicleExteriorSection extends StatelessWidget {
  const VehicleExteriorSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        InspectionItemCard(title: 'Front Bumper'),

        InspectionItemCard(title: 'Bonnet'),

        InspectionItemCard(title: 'Left Fender'),

        InspectionItemCard(title: 'Right Fender'),

        InspectionItemCard(title: 'Doors'),

        InspectionItemCard(title: 'Roof'),

        InspectionItemCard(title: 'Boot Lid'),

        InspectionItemCard(title: 'Mirrors'),

        InspectionItemCard(title: 'Windscreen'),

        InspectionItemCard(title: 'Headlights'),

        InspectionItemCard(title: 'Taillights'),

        InspectionItemCard(title: 'Paint Condition'),

        InspectionItemCard(title: 'Rust / Corrosion'),

        InspectionItemCard(title: 'Accident Damage'),
      ],
    );
  }
}
