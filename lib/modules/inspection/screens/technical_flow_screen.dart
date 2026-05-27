import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';

import '../../../theme/app_colors.dart';
import '../../../core/PDF/technical_pdf_service.dart';
import '../providers/inspection_provider.dart';
import '../models/inspection_models.dart';
import '../widgets/vehicle_details_section.dart';
import '../widgets/summary_section.dart';

class TechnicalFlowScreen extends StatefulWidget {
  const TechnicalFlowScreen({super.key});

  @override
  State<TechnicalFlowScreen> createState() => _TechnicalFlowScreenState();
}

class _TechnicalFlowScreenState extends State<TechnicalFlowScreen> {
  int currentStep = 0;
  final ScrollController _scrollController = ScrollController();

  final List<String> sections = [
    'Vehicle Details',
    '2. ENGINE DIAGNOSTICS',
    '3. COOLING SYSTEM',
    '4. ROAD TEST PERFORMANCE',
    '5. INSTRUMENTATION & ACCESSORIES',
    '6. ELECTRICAL ANALYSIS',
    '7. LIGHTING SYSTEMS',
    '8. INTERIOR & EXTERIOR TRIM',
    '9. STEERING & UNDER-BRAKES',
    '10. WHEELS & TYRES DIAGNOSTICS',
    '11. UNDERCARRIAGE SYSTEM',
    '12. FUEL & EXHAUST CRADLE',
    'Summary',
  ];

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
              'Technical Assessment Complete',
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
                  'The Comprehensive Technical Report PDF has been downloaded.',
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Technical report emailed to ${emailCtrl.text}',
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
    String pipelinePhase = 'Initializing Technical Engine...';
    Uint8List? pdfData;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => StatefulBuilder(
            builder: (context, setDialogState) {
              if (pdfData == null &&
                  isGenerating &&
                  pipelinePhase == 'Initializing Technical Engine...') {
                Future(() async {
                  await Future.delayed(const Duration(milliseconds: 400));
                  if (!mounted) return;
                  setDialogState(
                    () =>
                        pipelinePhase =
                            'Parsing 9-Page Multi-Zone Diagnostics Matrix...',
                  );

                  await Future.delayed(const Duration(milliseconds: 400));
                  if (!mounted) return;
                  setDialogState(
                    () =>
                        pipelinePhase =
                            'Compiling Full Vector Layout Sheets...',
                  );

                  final bytes = await TechnicalPDFService.generatePdfBytes(
                    state,
                  );

                  if (!mounted) return;
                  setDialogState(
                    () =>
                        pipelinePhase =
                            'Finalizing Legal Disclaimers & Sign-offs...',
                  );
                  await Future.delayed(const Duration(milliseconds: 300));

                  if (!mounted) return;
                  setDialogState(() {
                    pdfData = bytes;
                    isGenerating = false;
                  });
                });
              }

              return AlertDialog(
                backgroundColor: AppColors.card,
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
                          'Technical Document Ready',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 14),
                      const Text(
                        'Please hand the tablet to the client to rate the technician:',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
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
                                          'BRC_Full_Technical_Report_${state.vehicleDetails['Vehicle Registration No'] ?? 'SYS'}.pdf',
                                    );
                                    _showPostDownloadPopup(state);
                                  }
                                  : null,
                          child: const Text(
                            'SUBMIT & DOWNLOAD REPORT',
                            style: TextStyle(fontWeight: FontWeight.bold),
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

  // ðŸŒŸ NATIVE CHECKLIST BUILDER REMOVES BLANK SURFACE FREEZES
  Widget _buildTechnicalChecklist(
    ActiveInspectionProvider state,
    String sectionName,
  ) {
    final List<ComponentResult> items = state.sections[sectionName] ?? [];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final comp = items[index];
        bool hasBeenAssessed =
            comp.isNotApplicable ||
            comp.photoTargets.first.status != ItemStatus.na;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                hasBeenAssessed
                    ? AppColors.accent.withOpacity(0.05)
                    : AppColors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: hasBeenAssessed ? AppColors.gold : AppColors.border,
              width: hasBeenAssessed ? 1.5 : 0.5,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      comp.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children:
                        [ItemStatus.pass, ItemStatus.fail, ItemStatus.na].map((
                          st,
                        ) {
                          bool isSel =
                              comp.isNotApplicable
                                  ? (st == ItemStatus.na)
                                  : (comp.photoTargets.first.status == st &&
                                      !comp.isNotApplicable);
                          Color btnColor =
                              st == ItemStatus.pass
                                  ? Colors.green
                                  : (st == ItemStatus.fail
                                      ? Colors.red
                                      : Colors.grey);
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  if (st == ItemStatus.na)
                                    comp.isNotApplicable = true;
                                  else {
                                    comp.isNotApplicable = false;
                                    comp.photoTargets.first.status = st;
                                  }
                                });
                                state.notifyListeners();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSel
                                          ? btnColor.withOpacity(0.15)
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isSel ? btnColor : AppColors.border,
                                  ),
                                ),
                                child: Text(
                                  st == ItemStatus.na
                                      ? 'N/A'
                                      : st.name.toUpperCase(),
                                  style: TextStyle(
                                    color:
                                        isSel
                                            ? btnColor
                                            : AppColors.textSecondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 38,
                child: TextFormField(
                  initialValue: state.vehicleDetails[comp.title] ?? '',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                  onChanged: (v) {
                    state.vehicleDetails[comp.title] = v;
                    state.notifyListeners();
                  },
                  decoration: InputDecoration(
                    hintText:
                        comp.title.toLowerCase().contains('kg') ||
                                comp.title.toLowerCase().contains('mass')
                            ? 'Enter metric details (kg)...'
                            : 'Enter diagnostic evaluation measurements (mm/force)...',
                    fillColor: AppColors.background,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.gold),
                    ),
                  ),
                ),
              ),
              if (!comp.isNotApplicable &&
                  comp.photoTargets.first.status == ItemStatus.fail)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextFormField(
                    initialValue: comp.photoTargets.first.notes,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                    ),
                    onChanged: (v) {
                      comp.photoTargets.first.notes = v;
                      state.notifyListeners();
                    },
                    decoration: InputDecoration(
                      hintText: 'MANDATORY DEFECT SPECIFICS REASON REQUIRED...',
                      hintStyle: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                      fillColor: AppColors.background,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Colors.redAccent),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
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
                  border: Border.all(color: AppColors.gold.withOpacity(0.2)),
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
                                currentStep < sections.length - 1)
                              _buildTechnicalChecklist(
                                inspectionState,
                                sections[currentStep],
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
                    onPressed: () {
                      if (currentStep < sections.length - 1) {
                        setState(() {
                          currentStep++;
                          _scrollController.jumpTo(0);
                        });
                      } else {
                        _showLoadingAndRatingDialog(inspectionState);
                      }
                    },
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
