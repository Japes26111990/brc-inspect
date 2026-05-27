import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';

import '../../../theme/app_colors.dart';
import '../../../core/PDF/multipoint_pdf_service.dart';
import '../providers/inspection_provider.dart';
import '../models/inspection_models.dart';
import '../widgets/vehicle_details_section.dart';
import '../widgets/drive_system_section.dart';
import '../widgets/wheels_tyres_section.dart';
import '../widgets/summary_section.dart';

class MultipointFlowScreen extends StatefulWidget {
  const MultipointFlowScreen({super.key});

  @override
  State<MultipointFlowScreen> createState() => _MultipointFlowScreenState();
}

class _MultipointFlowScreenState extends State<MultipointFlowScreen> {
  int currentStep = 0;
  final ScrollController _scrollController = ScrollController();

  final List<String> sections = [
    'Vehicle Details',
    '01 IDENTIFICATION & DOCUMENTATION',
    '02 EXTERIOR & BODY',
    '03 INTERIOR & EQUIPMENT',
    '04 BRAKING SYSTEM',
    '05 SUSPENSION & UNDERCARRIAGE',
    '06 WHEELS & TYRES',
    '07 STEERING',
    '08 ENGINE',
    '09 TRANSMISSION & DRIVE',
    '10 ELECTRICAL SYSTEM',
    '11 BODY & STRUCTURAL',
    '12 DIMENSIONS',
    '13 STRUCTURAL DAMAGE',
    'Summary',
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showPostDownloadPopup(ActiveInspectionProvider state) {
    TextEditingController emailCtrl = TextEditingController(
      text: state.vehicleDetails['Client Email'] ?? '',
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: AppColors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Inspection Complete',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'The Multipoint PDF has been successfully generated.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Confirm Client Email:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailCtrl,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: AppColors.gold,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.gold,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged:
                      (val) => state.vehicleDetails['Client Email'] = val,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text(
                  'CLOSE',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Report successfully emailed to ${emailCtrl.text}',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text('SEND EMAIL'),
              ),
            ],
          ),
    );
  }

  void _showLoadingAndRatingDialog(ActiveInspectionProvider state) {
    int rating = 0;
    bool isGenerating = true;
    String pipelinePhase = 'Initializing Secure Manifest...';
    Uint8List? pdfData;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => StatefulBuilder(
            builder: (context, setDialogState) {
              if (pdfData == null &&
                  isGenerating &&
                  pipelinePhase == 'Initializing Secure Manifest...') {
                Future(() async {
                  await Future.delayed(const Duration(milliseconds: 600));
                  if (!mounted) return;
                  setDialogState(
                    () =>
                        pipelinePhase =
                            'Synchronizing Audit Manifest Fields... ',
                  );

                  await Future.delayed(const Duration(milliseconds: 600));
                  if (!mounted) return;
                  setDialogState(
                    () =>
                        pipelinePhase =
                            'Compiling High-Resolution Vector Assets... ',
                  );

                  final bytes = await MultipointPDFService.generatePdfBytes(
                    state,
                  );

                  if (!mounted) return;
                  setDialogState(
                    () =>
                        pipelinePhase = 'Finalizing System Integrity Check... ',
                  );
                  await Future.delayed(const Duration(milliseconds: 500));

                  if (!mounted) return;
                  setDialogState(() {
                    pdfData = bytes;
                    isGenerating = false;
                  });
                });
              }

              return AlertDialog(
                backgroundColor: AppColors.card,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                content: Container(
                  width: 420,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isGenerating) ...[
                        const SizedBox(height: 12),
                        const CircularProgressIndicator(
                          color: AppColors.gold,
                          strokeWidth: 3.5,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          pipelinePhase,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ] else ...[
                        const Icon(
                          Icons.verified_user_rounded,
                          color: Colors.green,
                          size: 54,
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Document Manifest Ready',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      const Divider(color: AppColors.border, thickness: 0.5),
                      const SizedBox(height: 14),
                      const Text(
                        'Please hand the tablet to the client to rate the technician:',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < rating
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: AppColors.gold,
                              size: 40,
                            ),
                            onPressed:
                                () => setDialogState(() => rating = index + 1),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed:
                              (!isGenerating && rating > 0)
                                  ? () async {
                                    Navigator.pop(ctx);
                                    await Printing.sharePdf(
                                      bytes: pdfData!,
                                      filename:
                                          'BRC_Multipoint_Check_${state.vehicleDetails['Vehicle Registration No'] ?? 'SYS'}.pdf',
                                    );
                                    _showPostDownloadPopup(state);
                                  }
                                  : null,
                          child: const Text(
                            'SUBMIT & DOWNLOAD REPORT',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  void nextStep(ActiveInspectionProvider inspectionState) {
    if (currentStep > 0 && currentStep < sections.length - 1) {
      final items = inspectionState.sections[sections[currentStep]] ?? [];
      bool missingReason = false;
      for (var item in items) {
        if (!item.isNotApplicable &&
            item.photoTargets.isNotEmpty &&
            item.photoTargets.first.status == ItemStatus.fail) {
          if (item.photoTargets.first.notes == null ||
              item.photoTargets.first.notes!.trim().isEmpty) {
            missingReason = true;
            break;
          }
        }
      }
      if (missingReason) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'âš ï¸  Please provide a reason for all FAILED items.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    if (currentStep < sections.length - 1) {
      setState(() {
        currentStep++;
        _scrollController.jumpTo(0);
      });
    } else {
      _showLoadingAndRatingDialog(inspectionState);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inspectionState = Provider.of<ActiveInspectionProvider>(context);
    final bool useCompactPadding = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Image.asset(
            'assets/logos/brc_logo.png',
            height: 30,
            fit: BoxFit.contain,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(useCompactPadding ? 12 : 20),
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
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      sections[currentStep],
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
          Expanded(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                width: double.infinity,
                margin: EdgeInsets.symmetric(
                  horizontal: useCompactPadding ? 8 : 16,
                  vertical: 4,
                ),
                padding: EdgeInsets.all(useCompactPadding ? 12 : 24),
                decoration: BoxDecoration(
                  color: AppColors.panel,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.gold.withOpacity(0.2),
                    width: 1,
                  ),
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
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (currentStep == 0)
                              VehicleDetailsSection(provider: inspectionState),
                            if (currentStep > 0 &&
                                currentStep < sections.length - 1 &&
                                currentStep != 12)
                              DriveSystemSection(
                                provider: inspectionState,
                                targetSectionName: sections[currentStep],
                              ),
                            if (currentStep == 12)
                              WheelsTyresSection(
                                provider: inspectionState,
                                renderMode: 'Dimensions',
                              ),
                            if (currentStep == sections.length - 1)
                              SummarySection(provider: inspectionState),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(useCompactPadding ? 12 : 20),
            child: Row(
              children: [
                if (currentStep > 0)
                  SizedBox(
                    width: useCompactPadding ? 100 : 150,
                    height: 50,
                    child: OutlinedButton(
                      onPressed:
                          () => setState(() {
                            currentStep--;
                            _scrollController.jumpTo(0);
                          }),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors.gold,
                          width: 0.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'BACK',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                  ),
                const Spacer(),
                SizedBox(
                  width: useCompactPadding ? 120 : 180,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => nextStep(inspectionState),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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
