import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/app_colors.dart';
import '../../../core/services/pdf_service.dart';
import '../providers/inspection_provider.dart';
import '../widgets/vehicle_details_section.dart';
import '../widgets/drive_system_section.dart';
import '../widgets/engine_compartment_section.dart';
import '../widgets/vehicle_exterior_section.dart';
import '../widgets/vehicle_interior_section.dart';
import '../widgets/test_drive_section.dart';
import '../widgets/wheels_tyres_section.dart';
import '../widgets/photos_section.dart';
import '../widgets/summary_section.dart';

class InspectionFlowScreen extends StatefulWidget {
  const InspectionFlowScreen({super.key});

  @override
  State<InspectionFlowScreen> createState() => _InspectionFlowScreenState();
}

class _InspectionFlowScreenState extends State<InspectionFlowScreen> {
  int currentStep = 0;

  // 🎯 FIXED: Removed the direct instantiation here so we don't wipe out menu choices!

  final List<String> sections = [
    'Vehicle Details',
    'Drive System',
    'Engine Compartment',
    'Vehicle Exterior',
    'Vehicle Interior',
    'Test Drive',
    'Wheels & Tyres',
    'Photos',
    'Summary',
  ];

  // 🎯 FIXED: Added inspectionState parameter to receive the live provider context
  void nextStep(ActiveInspectionProvider inspectionState) async {
    String currentSectionName = sections[currentStep];
    bool isComplete = inspectionState.isSectionComplete(currentSectionName);

    if (!isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'INCOMPLETE: You must assess items in $currentSectionName before proceeding.',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
      return; 
    }

    if (currentStep < sections.length - 1) {
      setState(() {
        currentStep++;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating SpaceX-Grade Manifest...'), duration: Duration(seconds: 1)),
      );
      // 🚀 Passing the TRUE live global context state directly into the PDF engine!
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
    // 🌍 CONNECT THE VALVE: Read the live active global provider instance passing through the tree!
    final inspectionState = Provider.of<ActiveInspectionProvider>(context);

    final screenSize = MediaQuery.of(context).size;
    final bool useCompactPadding = screenSize.width < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.panel,
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/logos/brc_logo.png', height: 30),
            const SizedBox(width: 12),
            const Text('Inspection Workflow', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          /// PROGRESS INDICATOR BAR
          Container(
            padding: EdgeInsets.all(useCompactPadding ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Step ${currentStep + 1} of ${sections.length}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                    Text(
                      sections[currentStep],
                      style: const TextStyle(color: AppColors.gold, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    minHeight: 10,
                    value: (currentStep + 1) / sections.length,
                    backgroundColor: AppColors.panel,
                    valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                  ),
                ),
              ],
            ),
          ),

          /// MAIN RESPONSIVE CONTENT HOUSING
          Expanded(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                width: double.infinity,
                margin: EdgeInsets.symmetric(
                  horizontal: useCompactPadding ? 12 : 24, 
                  vertical: useCompactPadding ? 8 : 16
                ),
                padding: EdgeInsets.all(useCompactPadding ? 16 : 32),
                decoration: BoxDecoration(
                  color: AppColors.panel,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.gold, width: 1),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    bool isPhoneSize = constraints.maxWidth < 650;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sections[currentStep],
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: isPhoneSize ? 26 : 34,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Core Form Component Canvas
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: ListenableBuilder(
                              listenable: inspectionState,
                              builder: (context, _) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (currentStep == 0) VehicleDetailsSection(provider: inspectionState),
                                    if (currentStep == 1) DriveSystemSection(provider: inspectionState),
                                    if (currentStep == 2) EngineCompartmentSection(provider: inspectionState),
                                    if (currentStep == 3) VehicleExteriorSection(provider: inspectionState),
                                    if (currentStep == 4) VehicleInteriorSection(provider: inspectionState),
                                    if (currentStep == 5) TestDriveSection(provider: inspectionState),
                                    if (currentStep == 6) WheelsTyresSection(provider: inspectionState),
                                    if (currentStep == 7) PhotosSection(provider: inspectionState),
                                    if (currentStep == 8) SummarySection(provider: inspectionState),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),

          /// BOTTOM NAVIGATION PANEL
          Container(
            padding: EdgeInsets.all(useCompactPadding ? 16 : 24),
            child: Row(
              children: [
                if (currentStep > 0)
                  SizedBox(
                    width: useCompactPadding ? 120 : 180,
                    height: 58,
                    child: OutlinedButton(
                      onPressed: previousStep,
                      child: const Text('BACK', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                const Spacer(),
                SizedBox(
                  width: useCompactPadding ? 140 : 220,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: () => nextStep(inspectionState), // 🚀 Pass the read provider context down on press
                    child: Text(
                      currentStep == sections.length - 1 ? 'COMPLETE' : 'NEXT',
                      style: TextStyle(
                        fontSize: useCompactPadding ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
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