import 'package:flutter/material.dart';
import '../models/inspection_models.dart';

class ActiveInspectionProvider extends ChangeNotifier {
  // ==========================================
  // 🚀 DEVELOPER TESTING SWITCH 🚀
  // Change this to 'false' to lock down the app and enforce all photos/comments.
  // Change this to 'true' to quickly skip through pages during testing.
  // ==========================================
  bool bypassGatekeeperForTesting = true; 

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

  // Intelligent Tyre State List
  final List<TyreResult> tyres = [
    TyreResult(position: 'Front Left'),
    TyreResult(position: 'Front Right'),
    TyreResult(position: 'Rear Left'),
    TyreResult(position: 'Rear Right'),
  ];

  // 360 Mandatory Photos State
  final List<Map<String, dynamic>> vehicle360Photos = [
    {'label': 'Front View', 'path': null, 'hasDamage': null, 'notes': ''},
    {'label': 'Rear View', 'path': null, 'hasDamage': null, 'notes': ''},
    {'label': 'Left Side', 'path': null, 'hasDamage': null, 'notes': ''},
    {'label': 'Right Side', 'path': null, 'hasDamage': null, 'notes': ''},
    {'label': 'Odometer (Mileage)', 'path': null, 'hasDamage': null, 'notes': ''},
    {'label': 'VIN Plate', 'path': null, 'hasDamage': null, 'notes': ''},
  ];

  // Complete operational checklist infrastructure across standard sections
  final Map<String, List<ComponentResult>> sections = {
    'Drive System': [
      ComponentResult(title: 'Suspension Rack Ends', isRoadworthyRelevant: true),
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
      ComponentResult(title: 'Rust / Corrosion', isRoadworthyRelevant: true),
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
      ComponentResult(title: 'Steering Response', isRoadworthyRelevant: true),
      ComponentResult(title: 'Suspension Noise'),
      ComponentResult(title: 'Wheel Alignment'),
    ],
  };

  // Global Check for Roadworthy Pass/Fail Engine
  bool get passesRoadworthy {
    for (var tyre in tyres) {
      if (tyre.treadDepthMm < 1) return false; 
    }
    for (var section in sections.values) {
      for (var item in section) {
        if (item.isRoadworthyRelevant && item.status == ItemStatus.fail) {
          return false;
        }
      }
    }
    return true;
  }

  void updateVehicleDetail(String key, String value) {
    vehicleDetails[key] = value;
    notifyListeners();
  }

  void updateComponentStatus(String sectionName, String title, ItemStatus newStatus) {
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

  void updateTyreTread(String position, String depthString) {
    final tyre = tyres.firstWhere((t) => t.position == position);
    final depth = int.tryParse(depthString);
    
    if (depth != null) {
      tyre.treadDepthMm = depth;
      tyre.evaluateRoadworthyLimit();
      notifyListeners();
    }
  }

  // The Gatekeeper: Checks if a section is 100% complete
  bool isSectionComplete(String sectionName) {
    // 🚀 If testing mode is ON, instantly let them pass to the next screen
    if (bypassGatekeeperForTesting) return true;

    if (sectionName == 'Vehicle Details') {
      final reg = vehicleDetails['Registration Number'] ?? '';
      final vin = vehicleDetails['VIN Number'] ?? '';
      return reg.trim().isNotEmpty && vin.trim().isNotEmpty;
    }
    
    if (sectionName == 'Wheels & Tyres') {
      return tyres.every((t) => t.status != ItemStatus.pending);
    }

    if (sectionName == 'Test Drive') {
      final list = sections['Test Drive'] ?? [];
      return list.every((item) {
        if (item.rating == 0) return false; // Must be rated
        if (item.rating <= 4 && item.notes.trim().isEmpty) return false; // Must have notes if <= 4
        return true;
      });
    }

    if (sectionName == 'Photos') {
      // Every photo must be taken, and if there is damage, notes must be filled
      return vehicle360Photos.every((photo) {
        if (photo['path'] == null || photo['hasDamage'] == null) return false;
        if (photo['hasDamage'] == true && photo['notes'].toString().trim().isEmpty) return false;
        return true;
      });
    }

    final list = sections[sectionName];
    if (list != null) {
      // BULLETPROOF CHECK: 
      // 1. Status cannot be pending.
      // 2. The photo array MUST contain at least one photo.
      return list.every((item) => 
          item.status != ItemStatus.pending && 
          item.photoPaths.isNotEmpty
      );
    }

    return true; 
  }
}