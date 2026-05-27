import 'package:flutter/material.dart';
import '../models/inspection_models.dart';

enum InspectionType { multipointCheck, conditionReport, technicalReport }

class ActiveInspectionProvider extends ChangeNotifier {
  InspectionType activeType = InspectionType.multipointCheck;

  final Map<String, String> vehicleDetails = {
    'Form Ref No': '00352',
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
    'Certificate No': '353/1',
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

  ActiveInspectionProvider() {
    initializeInspectionMatrix();
  }

  void setInspectionType(InspectionType type) {
    activeType = type;
    initializeInspectionMatrix();
    notifyListeners();
  }

  void initializeInspectionMatrix() {
    if (activeType == InspectionType.technicalReport) {
      _initializeFullTechnicalMatrix();
    } else {
      _initializeMultipointCheckMatrix();
    }
  }

  void _initializeFullTechnicalMatrix() {
    sections = {
      '2. ENGINE DIAGNOSTICS': _buildItems([
        'Timing',
        'Dwell',
        'Spark plugs',
        'Power balance cylinders',
        'Air cleaner element',
        'Oil level',
        'Noises',
        'Engine compartment',
        'Air leaks on manifold/carburetor',
        'Spark plug leads',
        'Fumes',
        'Smoking',
        'Idle mixture',
        'Mixture at high speed',
        'Idling',
        'Positive crankcase valve',
        'Cranking speed',
        'Vacuum advance',
        'Centrifugal advance',
      ], scale: EvaluationScale.severity), // <-- Flagged as Severity Metric
      '3. COOLING SYSTEM': _buildItems([
        'Pressure test',
        'Caps',
        'Hoses',
        'Belts',
        'Fan',
        'Expansion bottle',
        'Radiator',
        'Waterpump',
        'Visual / Anti-freeze',
        'Fluid leaks',
      ]),
      '4. ROAD TEST PERFORMANCE': _buildItems([
        'Engine Performance: Noise level',
        'Engine Performance: Vibrations',
        'Engine Performance: Smoking',
        'Engine Performance: Fumes',
        'Engine Performance: Cruise control',
        'Engine Performance: Performance',
        'Engine Performance: Idling',
        'Transmission: Noise level',
        'Transmission: Vibrations',
        'Transmission: Performance',
        'Transmission: Gearshift',
        'Brake Test: L/F',
        'Brake Test: R/F',
        'Brake Test: L/R',
        'Brake Test: R/R',
        'Brake Test: H/B',
        'Clutch: Noise level',
        'Clutch: Performance',
        'Clutch: Shudder',
        'Driveline: Noise level',
        'Driveline: Vibrations',
        'Driveline: Torque',
        'Differential: Noise level',
        'Differential: Performance',
      ]),
      '5. INSTRUMENTATION & ACCESSORIES': _buildItems([
        'Steering wheel',
        'Speedometer',
        'Fuel gauge',
        'Rev counter',
        'Wiper switch',
        'Indicator switch',
        'Headlight switch',
        'Cruise control switch',
        'Cigarette lighter',
        'Radio',
        'Ashtray',
        'Air vents',
        'Centre air vents',
        'Heater controls',
        'Glove compartment',
      ]),
      '6. ELECTRICAL ANALYSIS': _buildItems([
        'Battery: State of charge',
        'Battery: Battery load test',
        'Battery: Visual',
        'Charging System: Charging rate',
        'Charging System: Noise',
        'Charging System: Visual',
        'Charging System: Belt',
        'Starter: Performance',
        'Starter: Noise',
        'Wiring & connections',
        'Fuses & fuse box',
      ]),
      '7. LIGHTING SYSTEMS': _buildItems([
        'Interior Lights',
        'Headlights',
        'Hazard',
        'Indicators',
        'Reverse',
        'Headlight adjustments',
        'Brakes',
        'Instrumentation',
        'Park / Tail',
        'No plate',
        'Fog lights & Spot lights',
      ]),
      '8. INTERIOR & EXTERIOR TRIM': _buildItems([
        'Hoodlining',
        'Sun visors',
        'Seats',
        'Floor mats',
        'Panels',
        'Seat belts',
        'Door locks',
        'Window mechanisms',
        'Interior mirror',
        'Glove compartment',
        'Dash',
        'Lenses',
        'Pillars',
        'Electric mirrors',
        'Reflectors',
        'Channels',
        'Sealing rubbers',
        'Glass',
        'Number plates',
        'Sun roof',
        'Exterior mirror',
      ]),
      '9. STEERING & UNDER-BRAKES': _buildItems([
        'Brakes: Linings / pads',
        'Brakes: Drum / disk',
        'Brakes: Wheel cylinder / calipers',
        'Brakes: Master cylinder',
        'Brakes: Brake hoses',
        'Brakes: Brake fluid / Leaks',
        'Brakes: Brake booster',
        'Brakes: Brake test',
        'Brakes: Handbrake',
        'Steering: Steering box',
        'Steering: Pitman',
        'Steering: Tie-rod ends',
        'Steering: Drag link',
        'Steering: Steering shaft',
        'Steering: Idler arm',
        'Steering: Steering rack',
        'Steering: Steering coupling',
        'Steering: Steering rackboots',
        'Steering: Power steering',
        'Steering: Fluid leaks',
      ]),
      '10. WHEELS & TYRES DIAGNOSTICS': _buildItems([
        'Wheels: Run out',
        'Wheels: Bearings',
        'Wheels: Rim',
        'Wheels: Bolts & nuts (visual)',
        'Alignment: Toe in / Toe out',
        'Alignment: Camber',
        'Alignment: Caster',
        'Tyres: Make',
        'Tyres: Casing',
        'Tyres: Tread Depth',
        'Tyres: Size',
        'Tyres: Type',
      ]),
      '11. UNDERCARRIAGE SYSTEM': _buildItems([
        'Chassis: Frame / Chassis',
        'Chassis: Cross member',
        'Chassis: Sub frame',
        'Chassis: Wheel base',
        'Chassis: Diagonal measurement',
        'Chassis: All rubber mountings',
        'Chassis: Jacking points',
        'Chassis: Fluid leaks under car',
        'Suspension: Springs',
        'Suspension: Shackles',
        'Suspension: Trailing arms',
        'Suspension: Torsion bars',
        'Suspension: Wishbones & Pivots',
        'Suspension: Control arms',
        'Suspension: Swivel joints',
        'Suspension: Radius rods',
        'Suspension: Stabiliser bars',
        'Suspension: Axles',
        'Suspension: Shocks',
        'Suspension: Hydraulic systems',
      ]),
      '12. FUEL & EXHAUST CRADLE': _buildItems([
        'Fuel System: Fuel tank',
        'Fuel System: Lines',
        'Fuel System: Fuel leaks',
        'Drive Shaft: Propeller / drive shaft',
        'Drive Shaft: Universal joints',
        'Drive Shaft: CV Joints',
        'Drive Shaft: Rubber boots',
        'Drive Shaft: Prop centre bearing',
        'Exhaust: Silencer(s)',
        'Exhaust: Pipes / flanges / joints',
        'Exhaust: Fluid leaks',
        'Ride Height: Front',
        'Ride Height: Rear',
      ]),
    };
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
  }

  List<ComponentResult> _buildItems(
    List<String> titles, {
    EvaluationScale scale = EvaluationScale.binary,
  }) {
    return titles
        .map(
          (t) => ComponentResult(
            id: t.replaceAll(' ', '_').toLowerCase(),
            title: t,
            isRoadworthyRelevant: true,
            isCompulsory: true,
            scale: scale,
            photoTargets: [
              SubPhotoTarget(id: '${t}_t', label: 'Check/Note for $t'),
            ],
          ),
        )
        .toList();
  }

  void resetInspection() {
    vehicleDetails.forEach((key, value) {
      if (key == 'Form Ref No') {
        vehicleDetails[key] = '00352';
      } else if (key == 'Examiner Name') {
        vehicleDetails[key] = 'Tommy';
      } else if (key == 'Examiner Number') {
        vehicleDetails[key] = 'EX-8842';
      } else if (key == 'Certificate No') {
        vehicleDetails[key] = '353/1';
      } else {
        vehicleDetails[key] = '';
      }
    });
    initializeInspectionMatrix();
    notifyListeners();
  }
}
