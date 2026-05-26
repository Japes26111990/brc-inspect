class RoadworthySection {
  final String title;
  final List<String> items;

  const RoadworthySection({
    required this.title,
    required this.items,
  });
}

const List<RoadworthySection>
    roadworthySections = [
  RoadworthySection(
    title:
        '01 IDENTIFICATION & DOCUMENTATION',
    items: [
      'Chassis',
    ],
  ),

  RoadworthySection(
    title: '02 ELECTRICAL SYSTEM',
    items: [
      'Electric Power Steering',
    ],
  ),

  RoadworthySection(
    title: '03 FITTINGS & EQUIPMENT',
    items: [
      'Bonnet Cable',
      'Bonnet Hinges',
      'Bonnet Shocks/ stay',
    ],
  ),

  RoadworthySection(
    title: '04 BRAKING SYSTEM',
    items: [
      'Brake Lines And Hoses',
      'Brake Calipers',
      'Hand Brake',
    ],
  ),

  RoadworthySection(
    title: '05 WHEELS & TYRES',
    items: [
      'Wheel Bearings',
      'Axles',
    ],
  ),

  RoadworthySection(
    title: '06 SUSPENSION & UNDERCARRIAGE',
    items: [
      'Ball Joint',
      'Control Arm',
      'Trailing Arms',
      'Shock Mounting',
      'Shocks',
      'Bushings',
      'Links',
      'Stabilizer',
      'Suspension Tie Rods',
      'Suspension Rack Ends',
      'Subframe',
      'Underbody',
    ],
  ),

  RoadworthySection(
    title: '07 STEERING',
    items: [
      'Steering Rack',
      'Link Rod Dust Cover',
    ],
  ),

  RoadworthySection(
    title: '08 ENGINE & DRIVELINE',
    items: [
      'Transmission/ gearbox',
      'Engine/gearbox Mountings',
      'Drive Shaft',
      'Propshaft And Center Bearing',
      'Differential',
      'Diff Mountings',
      'Cv Joints',
      'Fuel System',
      'Radiators/fans/ coolers',
      'Radiator Cradle',
      'Coolant Hoses And Connections',
      'Smoke Emission',
    ],
  ),

  RoadworthySection(
    title: '09 EXHAUST SYSTEM',
    items: [
      'Exhaust System',
    ],
  ),
];