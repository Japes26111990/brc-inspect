import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
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

  final ActiveInspectionProvider inspectionState = ActiveInspectionProvider();

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

  void nextStep() {
    if (currentStep < sections.length - 1) {
      setState(() {
        currentStep++;
      });
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.panel,
        title: Row(
          children: [
            Image.asset('assets/logos/brc_logo.png', height: 30),
            const SizedBox(width: 12),
            const Text('Inspection Workflow'),
          ],
        ),
      ),
      body: Column(
        children: [
          /// PROGRESS SECTION
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Step ${currentStep + 1} of ${sections.length}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      sections[currentStep],
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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

          /// MAIN CONTENT
          Expanded(
            child: Center(
              child: Container(
                width: 1000,
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: AppColors.panel,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.gold, width: 1),
                ),
                child: SingleChildScrollView(
                  child: ListenableBuilder(
                    listenable: inspectionState,
                    builder: (context, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sections[currentStep],
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Injecting running memory controller down into each section
                          if (currentStep == 0) const VehicleDetailsSection(),
                          if (currentStep == 1)
                            DriveSystemSection(provider: inspectionState),
                          if (currentStep == 2)
                            EngineCompartmentSection(provider: inspectionState),
                          if (currentStep == 3)
                            VehicleExteriorSection(provider: inspectionState),
                          if (currentStep == 4)
                            VehicleInteriorSection(provider: inspectionState),
                          if (currentStep == 5)
                            TestDriveSection(provider: inspectionState),
                          if (currentStep == 6)
                            WheelsTyresSection(provider: inspectionState),
                          if (currentStep == 7) const PhotosSection(),
                          if (currentStep == 8) const SummarySection(),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          /// BOTTOM NAVIGATION
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                if (currentStep > 0)
                  SizedBox(
                    width: 180,
                    height: 58,
                    child: OutlinedButton(
                      onPressed: previousStep,
                      child: const Text('BACK'),
                    ),
                  ),
                const Spacer(),
                SizedBox(
                  width: 220,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: nextStep,
                    child: Text(
                      currentStep == sections.length - 1 ? 'COMPLETE' : 'NEXT',
                      style: const TextStyle(
                        fontSize: 18,
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
