import 'package:flutter/material.dart';

import 'inspection_item_card.dart';

class DriveSystemSection extends StatelessWidget {
  const DriveSystemSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        InspectionItemCard(title: 'Suspension Rack Ends'),

        InspectionItemCard(title: 'Shock Absorbers'),

        InspectionItemCard(title: 'Steering Rack'),

        InspectionItemCard(title: 'CV Joints'),

        InspectionItemCard(title: 'Brake Pipes'),

        InspectionItemCard(title: 'Brake Discs'),

        InspectionItemCard(title: 'Brake Pads'),

        InspectionItemCard(title: 'Wheel Bearings'),
      ],
    );
  }
}
