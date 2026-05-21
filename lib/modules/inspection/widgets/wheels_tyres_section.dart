import 'package:flutter/material.dart';

import 'inspection_item_card.dart';

class WheelsTyresSection extends StatelessWidget {
  const WheelsTyresSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        InspectionItemCard(title: 'Front Left Tyre'),
        InspectionItemCard(title: 'Front Right Tyre'),
        InspectionItemCard(title: 'Rear Left Tyre'),
        InspectionItemCard(title: 'Rear Right Tyre'),
        InspectionItemCard(title: 'Spare Wheel'),
        InspectionItemCard(title: 'Wheel Condition'),
      ],
    );
  }
}
