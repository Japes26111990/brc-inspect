import 'package:flutter/material.dart';
import '../models/inspection_models.dart';

class ActiveInspectionProvider extends ChangeNotifier {
  // Vehicle Details State Map
  final Map<String, String> vehicleDetails = {
    'Registration Number': '',
    'VIN Number': '',
    'Make': '',
    'Model': '',
    'Year Model': '',
    'Mileage': '',
    'Fuel Type': '',
    'Transmission': '',
    'Colour': '',
    'Inspector Name': '',
    'Client Name': '',
  };

  // Complete operational checklist infrastructure across all sections
  final Map<String, List<ComponentResult>> sections = {
    'Drive System': [
      ComponentResult(
        title: 'Suspension Rack Ends',
        isRoadworthyRelevant: true,
      ),
      ComponentResult(title: 'Shock Absorbers'),
      ComponentResult(title: 'Steering Rack'),
      ComponentResult(title: 'CV Joints'),
      ComponentResult(title: 'Brake Pipes', isRoadworthyRelevant: true),
      ComponentResult(title: 'Brake Discs', isRoadworthyRelevant: true),
      ComponentResult(title: 'Brake Pads', isRoadworthyRelevant: true),
      ComponentResult(title: 'Wheel Bearings'),
    ],
    'Engine Compartment': [
      ComponentResult(title: 'Oil Leaks'),
      ComponentResult(title: 'Coolant System'),
      ComponentResult(title: 'Battery Condition'),
      ComponentResult(title: 'Drive Belts'),
      ComponentResult(title: 'Engine Mountings'),
      ComponentResult(title: 'Fluid Levels'),
      ComponentResult(title: 'Wiring Condition'),
    ],
    'Vehicle Exterior': [
      ComponentResult(title: 'Front Bumper'),
      ComponentResult(title: 'Bonnet'),
      ComponentResult(title: 'Left Fender'),
      ComponentResult(title: 'Right Fender'),
      ComponentResult(title: 'Doors'),
      ComponentResult(title: 'Roof'),
      ComponentResult(title: 'Boot Lid'),
      ComponentResult(title: 'Mirrors'),
      ComponentResult(title: 'Windscreen', isRoadworthyRelevant: true),
      ComponentResult(title: 'Headlights', isRoadworthyRelevant: true),
      ComponentResult(title: 'Taillights', isRoadworthyRelevant: true),
      ComponentResult(title: 'Paint Condition'),
      ComponentResult(title: 'Rust / Corrosion'),
      ComponentResult(title: 'Accident Damage'),
    ],
    'Vehicle Interior': [
      ComponentResult(title: 'Seats'),
      ComponentResult(title: 'Dashboard'),
      ComponentResult(title: 'Roof Lining'),
      ComponentResult(title: 'Air Conditioning'),
      ComponentResult(title: 'Infotainment System'),
      ComponentResult(title: 'Windows'),
      ComponentResult(title: 'Seat Belts', isRoadworthyRelevant: true),
    ],
    'Test Drive': [
      ComponentResult(title: 'Engine Performance'),
      ComponentResult(title: 'Gearbox Operation'),
      ComponentResult(title: 'Braking Performance', isRoadworthyRelevant: true),
      ComponentResult(title: 'Steering Response'),
      ComponentResult(title: 'Suspension Noise'),
      ComponentResult(title: 'Wheel Alignment'),
    ],
    'Wheels & Tyres': [
      ComponentResult(title: 'Front Left Tyre', isRoadworthyRelevant: true),
      ComponentResult(title: 'Front Right Tyre', isRoadworthyRelevant: true),
      ComponentResult(title: 'Rear Left Tyre', isRoadworthyRelevant: true),
      ComponentResult(title: 'Rear Right Tyre', isRoadworthyRelevant: true),
      ComponentResult(title: 'Spare Wheel'),
      ComponentResult(title: 'Wheel Condition'),
    ],
  };

  void updateVehicleDetail(String key, String value) {
    vehicleDetails[key] = value;
    notifyListeners();
  }

  void updateComponentStatus(
    String sectionName,
    String title,
    ItemStatus newStatus,
  ) {
    final list = sections[sectionName];
    if (list != null) {
      final item = list.firstWhere((element) => element.title == title);
      item.status = newStatus;
      notifyListeners();
    }
  }

  void updateComponentNotes(String sectionName, String title, String newNotes) {
    final list = sections[sectionName];
    if (list != null) {
      final item = list.firstWhere((element) => element.title == title);
      item.notes = newNotes;
    }
  }
}
