import 'package:flutter/material.dart';
import '../models/inspection_models.dart';

enum InspectionType { multipointCheck, conditionReport, technicalReport }

class ActiveInspectionProvider extends ChangeNotifier {
  InspectionType activeType = InspectionType.multipointCheck;

  final Map<String, String> vehicleDetails = {
    'Form Ref No': '0803',
    'Client Name': '',
    'Client Cell': '',
    'Client Email': '',
    'Owner Surname & Initials': '',
    'Vehicle Engine Number': '',
    'Vehicle VIN Chassis Number': '',
    'Vehicle Model': '',
    'Vehicle Make': '',
    'Vehicle Registration No': '',
    'Test Date': '',
    'Time': '',
    'Odometer Reading': '',
    'Examiner Name': 'Tommy',
    'Examiner Number': 'EX-8842',
    'Remarks': '',
  };

  final Map<String, bool> scannedFieldsRegistry = {
    'Vehicle Registration No': false,
    'Vehicle VIN Chassis Number': false,
    'Vehicle Engine Number': false,
    'Vehicle Make': false,
    'Vehicle Model': false,
    'Odometer Reading': false,
  };

  Map<String, List<ComponentResult>> sections = {};
  List<TyreResult> tyres = [];

  ActiveInspectionProvider() {
    _initializeMultipointCheckMatrix();
  }

  // 🌟 NEW: Purges data cleanly when starting a brand new cycle
  void resetInspection() {
    vehicleDetails.forEach((key, value) {
      if (key == 'Form Ref No') {
        vehicleDetails[key] = '0803';
      } else if (key == 'Examiner Name') {
        vehicleDetails[key] = 'Tommy';
      } else if (key == 'Examiner Number') {
        vehicleDetails[key] = 'EX-8842';
      } else {
        vehicleDetails[key] = '';
      }
    });

    scannedFieldsRegistry.updateAll((key, value) => false);
    _initializeMultipointCheckMatrix();
    notifyListeners();
  }

  void setInspectionType(InspectionType type) {
    activeType = type;
    notifyListeners();
  }

  void recalculateDynamicComponentBudgets() {
    notifyListeners();
  }

  void _initializeMultipointCheckMatrix() {
    sections = {
      '01 IDENTIFICATION & DOCUMENTATION': _buildItems([
        'TEST DRIVE (ROAD TEST)',
        'MATCHING CHASSIS/ENGINE NUMBERS',
        'VEHICLE LICENCE DISC',
        'VEHICLE REGISTRATION DOCUMENTS',
        'IDENTITY DOCUMENT (SELLER)',
        'VEHICLE INVOICE',
        'SERVICE BOOK/STAMP',
        'OWNER\'S MANUAL',
        'SPARE KEYS / REMOTE',
        'WARRANTY DOCUMENTS (IF APPLICABLE)',
        'OTHER DOCUMENTS (E.g. IMPORT DOCS)',
      ]),
      '02 EXTERIOR & BODY': _buildItems([
        'EXTERIOR LIGHTS (ALL)',
        'WINDSCREEN & WINDOWS',
        'WIPERS & WASHERS',
        'MIRRORS (WING & REAR VIEW)',
        'BODY PANELS & PAINTWORK',
        'BUMPER & GRILLE',
        'DOORS & BOOT OPERATION',
        'LOCKS & HANDLES',
        'SEALS & RUBBERS',
        'EXHAUST SYSTEM',
        'ROOF & ROOF RACK',
        'TOWING EQUIPMENT',
      ]),
      '03 INTERIOR & EQUIPMENT': _buildItems([
        'SEAT BELTS (FRONT & REAR)',
        'SEATS & ADJUSTMENTS',
        'AIR CONDITIONING / HEATER',
        'DASHBOARD & CONTROLS',
        'WARNING LIGHTS',
        'HORN',
        'INSTRUMENT CLUSTER',
        'SPEEDOMETER & ODOMETER',
        'INTERIOR LIGHTS',
        'RADIO / MEDIA SYSTEM',
        'SUNVISORS & MIRRORS',
        'GLOVE BOX & STORAGE',
      ]),
      '04 BRAKING SYSTEM': _buildItems([
        'BRAKE FLUID LEVEL',
        'FRONT BRAKES (PADS / DISCS)',
        'REAR BRAKES (PADS / DISCS)',
        'HANDBRAKE OPERATION',
        'BRAKE PIPES & HOSES',
        'ABS WARNING LIGHT',
        'TEST DRIVE (BRAKING PERFORMANCE)',
        'PARK BRAKE',
      ]),
      '05 SUSPENSION & UNDERCARRIAGE': _buildItems([
        'SHOCK ABSORBERS (FRONT)',
        'SHOCK ABSORBERS (REAR)',
        'SPRINGS',
        'BUSHES',
        'BALL JOINTS',
        'TIE ROD ENDS',
        'CONTROL ARMS',
        'CV JOINTS / BOOTS',
        'EXHAUST SYSTEM',
        'UNDERBODY (LEAKS / DAMAGE)',
      ]),
      '06 WHEELS & TYRES': _buildItems([
        'TYRE CONDITION (TREAD)',
        'TYRE PRESSURE',
        'TYRE SIZE (MATCHING)',
        'SPARE WHEEL & TYRE',
        'WHEEL ALIGNMENT',
        'WHEEL BALANCE',
        'WHEEL NUTS / BOLTS',
        'RIMS (DAMAGE)',
      ]),
      '07 STEERING': _buildItems([
        'STEERING WHEEL (FREE PLAY)',
        'POWER STEERING FLUID LEVEL',
        'STEERING LINKAGE',
        'TIE ROD ENDS',
        'RACK & PINION / STEERING BOX',
        'TEST DRIVE (STEERING PERFORMANCE)',
      ]),
      '08 ENGINE': _buildItems([
        'ENGINE OIL LEVEL',
        'ENGINE OIL CONDITION',
        'COOLANT LEVEL',
        'COOLANT CONDITION',
        'BATTERY CONDITION',
        'DRIVE BELTS',
        'HOSES & CLAMPS',
        'AIR FILTER',
        'FUEL LEAKS',
        'ENGINE PERFORMANCE (TEST DRIVE)',
      ]),
      '09 TRANSMISSION & DRIVE': _buildItems([
        'CLUTCH OPERATION (MANUAL)',
        'GEAR SHIFT OPERATION',
        'TRANSMISSION OIL LEVEL',
        'AUTOMATIC (KICK DOWN)',
        'DRIVE SHAFTS / CV JOINTS',
        'DIFFERENTIAL (NOISE / LEAKS)',
        'TEST DRIVE (DRIVE PERFORMANCE)',
      ]),
      '10 ELECTRICAL SYSTEM': _buildItems([
        'BATTERY CHARGE',
        'ALTERNATOR OUTPUT',
        'STARTER MOTOR',
        'LIGHTS (ALL)',
        'INDICATORS / HAZARD LIGHTS',
        'BRAKE LIGHTS',
        'REVERSE LIGHTS',
        'FOG LIGHTS',
        'INTERIOR LIGHTS',
        'ELECTRICAL ACCESSORIES',
      ]),
      '11 BODY & STRUCTURAL': _buildItems([
        'CHASSIS / UNIBODY CONDITION',
        'RUST / CORROSION',
        'ACCIDENT DAMAGE REPAIRS',
        'PANEL GAPS & ALIGNMENT',
        'WINDSCREEN (CRACKS / CHIPS)',
        'FLOOR PANS',
        'BOOT FLOOR',
        'FIREWALL CONDITION',
        'DOOR HINGES & STRIKERS',
        'STRUCTURAL INTEGRITY',
      ]),
      '12 DIMENSIONS': _buildItems([
        'OVERALL LENGTH',
        'OVERALL WIDTH',
        'OVERALL HEIGHT',
        'WHEELBASE',
        'GROUND CLEARANCE',
        'KERB WEIGHT (kg)',
        'GROSS VEHICLE MASS (kg)',
      ]),
      '13 STRUCTURAL DAMAGE': _buildItems([
        'FRONT END',
        'REAR END',
        'LEFT SIDE',
        'RIGHT SIDE',
        'ROOF',
        'FLOOR / UNDERBODY',
        'PREVIOUS REPAIRS',
      ]),
    };

    tyres = [];
  }

  List<ComponentResult> _buildItems(List<String> titles) {
    return titles
        .map(
          (t) => ComponentResult(
            id: t.replaceAll(' ', '_').toLowerCase(),
            title: t,
            isRoadworthyRelevant: true,
            isCompulsory: true,
            photoTargets: [
              SubPhotoTarget(id: '${t}_t', label: 'Check/Note for $t'),
            ],
          ),
        )
        .toList();
  }

  bool get passesRoadworthy {
    for (var sectionList in sections.values) {
      for (var component in sectionList) {
        if (!component.isNotApplicable &&
            component.photoTargets.first.status == ItemStatus.fail) {
          return false;
        }
      }
    }
    return true;
  }

  bool isSectionComplete(String sectionName) => true;
}
