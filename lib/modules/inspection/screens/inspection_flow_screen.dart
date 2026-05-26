import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/app_colors.dart';
import '../../../core/PDF/pdf_service.dart';
import '../providers/inspection_provider.dart';
import '../widgets/vehicle_details_section.dart';
import '../widgets/drive_system_section.dart';
import '../widgets/wheels_tyres_section.dart';
import '../widgets/summary_section.dart';

class InspectionFlowScreen extends StatefulWidget {
  const InspectionFlowScreen({super.key});

  @override
  State<InspectionFlowScreen> createState() => _InspectionFlowScreenState();
}

class _InspectionFlowScreenState extends State<InspectionFlowScreen> {
  int currentStep = 0;

  // 📝 CLEAN SORTED WORKSPACE CHECKLIST - STIPPED OF PREFIXED NUMBERS
  final List<String> sections = [
    'Vehicle Details',
    'Identification & Docs',
    'Electrical System',
    'Fittings & Equipment',
    'Braking System', // Fully separated step
    'Wheels',         // Fully separated step
    'Suspension & Undercarriage',
    'Steering',
    'Engine',
    'Exhaust System',
    'Transmission & Drive',
    'Instruments',
    'Dimensions',
    'Structural Damage',
    'Summary',
  ];

  void nextStep(ActiveInspectionProvider inspectionState) async {
    if (currentStep < sections.length - 1) {
      setState(() {
        currentStep++;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compiling Document Manifest Template...'), 
          duration: Duration(seconds: 1),
        ),
      );
      // Calls your landscape official single-page A4 document replication engine
      await PDFService.generateAndPrintReport(inspectionState);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final inspectionState = Provider.of<ActiveInspectionProvider>(context);
    final screenSize = MediaQuery.of(context).size;
    final bool useCompactPadding = screenSize.width < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.panel,
        elevation: 0,
        title: const Text('BRC Inspection Pipeline', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          /// SECTION PROGRESS INDICATOR SLIDER BAR
          Container(
            padding: EdgeInsets.all(useCompactPadding ? 12 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Step ${currentStep + 1} of ${sections.length}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    Text(sections[currentStep].toUpperCase(), style: const TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    minHeight: 6,
                    value: (currentStep + 1) / sections.length,
                    backgroundColor: AppColors.panel,
                    valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                  ),
                ),
              ],
            ),
          ),

          /// CORE RESPONSIVE COMPONENT CANVA HOUSING
          Expanded(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: useCompactPadding ? 8 : 16, vertical: 4),
                padding: EdgeInsets.all(useCompactPadding ? 12 : 24),
                decoration: BoxDecoration(
                  color: AppColors.panel, 
                  borderRadius: BorderRadius.circular(16), 
                  border: Border.all(color: AppColors.gold.withOpacity(0.2), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sections[currentStep], 
                      style: TextStyle(
                        color: AppColors.textPrimary, 
                        fontSize: useCompactPadding ? 20 : 24, 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (currentStep == 0) VehicleDetailsSection(provider: inspectionState),
                            if (currentStep == 1) DriveSystemSection(provider: inspectionState, targetSectionName: 'Identification & Docs'),
                            if (currentStep == 2) DriveSystemSection(provider: inspectionState, targetSectionName: 'Electrical System'),
                            if (currentStep == 3) DriveSystemSection(provider: inspectionState, targetSectionName: 'Fittings & Equipment'),
                            
                            // 🔀 SPLIT LAYOUT INJECTION: Brakes and Wheels route seamlessly to separate render modes
                            if (currentStep == 4) WheelsTyresSection(provider: inspectionState, renderMode: 'Brakes'), 
                            if (currentStep == 5) WheelsTyresSection(provider: inspectionState, renderMode: 'Wheels'), 
                            
                            if (currentStep == 6) DriveSystemSection(provider: inspectionState, targetSectionName: 'Suspension & Undercarriage'),
                            if (currentStep == 7) DriveSystemSection(provider: inspectionState, targetSectionName: 'Steering'),
                            if (currentStep == 8) DriveSystemSection(provider: inspectionState, targetSectionName: 'Engine'),
                            if (currentStep == 9) DriveSystemSection(provider: inspectionState, targetSectionName: 'Exhaust System'),
                            if (currentStep == 10) DriveSystemSection(provider: inspectionState, targetSectionName: 'Transmission & Drive'),
                            if (currentStep == 11) DriveSystemSection(provider: inspectionState, targetSectionName: 'Instruments'),
                            if (currentStep == 12) DriveSystemSection(provider: inspectionState, targetSectionName: 'Dimensions'),
                            if (currentStep == 13) DriveSystemSection(provider: inspectionState, targetSectionName: 'Structural Damage'),
                            if (currentStep == 14) SummarySection(provider: inspectionState),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// BOTTOM CONTROL NAVIGATION BAR PANEL
          Container(
            padding: EdgeInsets.all(useCompactPadding ? 12 : 20),
            child: Row(
              children: [
                if (currentStep > 0)
                  SizedBox(
                    width: useCompactPadding ? 100 : 150,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: previousStep,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.gold, width: 0.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('BACK', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.gold)),
                    ),
                  ),
                const Spacer(),
                SizedBox(
                  width: useCompactPadding ? 120 : 180,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => nextStep(inspectionState),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      currentStep == sections.length - 1 ? 'COMPLETE' : 'NEXT', 
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}