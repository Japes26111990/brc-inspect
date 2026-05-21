import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // <--- NEW IMPORT
import '../../../theme/app_colors.dart';
import '../models/inspection_models.dart';

class InspectionItemCard extends StatefulWidget {
  final ComponentResult item;
  final Function(ItemStatus) onStatusChanged;
  final Function(String) onNotesChanged;

  const InspectionItemCard({
    super.key,
    required this.item,
    required this.onStatusChanged,
    required this.onNotesChanged,
  });

  @override
  State<InspectionItemCard> createState() => _InspectionItemCardState();
}

class _InspectionItemCardState extends State<InspectionItemCard> {
  final TextEditingController _reasonController = TextEditingController();
  final ImagePicker _picker = ImagePicker(); // <--- CAMERA INSTANCE
  
  // Local state to track if this item has been processed in the workflow
  bool _isAssessed = false;

  @override
  void initState() {
    super.initState();
    // If we load a draft and it's no longer pending, mark it as assessed
    if (widget.item.status != ItemStatus.pending || widget.item.photoPaths.isNotEmpty) {
      _isAssessed = true;
    }
  }

  // --- THE NEW FORCED COMPLIANCE WORKFLOW ---
  Future<void> _startCaptureWorkflow() async {
    // STEP 1: OPEN REAL LIVE CAMERA
    // Forces the user to take a photo. ImageSource.camera blocks gallery uploads.
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70, // Compress to save bandwidth/storage later
    );
    
    // STEP 2: ABORT IF THEY CANCEL
    // If they back out of the camera without taking a photo, stop the workflow entirely.
    if (photo == null) return; 

    // STEP 3: SAVE PHOTO TO MEMORY
    setState(() {
      widget.item.photoPaths = [...widget.item.photoPaths, photo.path];
    });

    // STEP 4: SHOW SMART ASSESSMENT DIALOG
    if (!mounted) return;
    _showAssessmentDialog();
  }

  void _showAssessmentDialog() {
    _reasonController.text = widget.item.notes;
    ItemStatus? selectedTempStatus;

    showDialog(
      context: context,
      barrierDismissible: false, // Force them to finish the workflow
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: AppColors.panel,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.gold, width: 1),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_outline, color: AppColors.success, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Photo Captured',
                      style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.8), fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'ASSESS CONDITION',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 24),

                    // STATUS BUTTONS
                    Row(
                      children: [
                        _dialogStatusBtn('PASS', AppColors.success, setDialogState, selectedTempStatus, () {
                          // Pass instantly saves and closes!
                          widget.onStatusChanged(ItemStatus.pass);
                          widget.onNotesChanged('');
                          setState(() => _isAssessed = true);
                          Navigator.pop(context);
                        }),
                        const SizedBox(width: 10),
                        _dialogStatusBtn('ATTN', AppColors.warning, setDialogState, selectedTempStatus, () {
                          setDialogState(() => selectedTempStatus = ItemStatus.attention);
                        }),
                        const SizedBox(width: 10),
                        _dialogStatusBtn('FAIL', AppColors.danger, setDialogState, selectedTempStatus, () {
                          setDialogState(() => selectedTempStatus = ItemStatus.fail);
                        }),
                      ],
                    ),

                    // REASON EXPANSION (Only shows if ATTN or FAIL is clicked)
                    if (selectedTempStatus == ItemStatus.attention || selectedTempStatus == ItemStatus.fail) ...[
                      const SizedBox(height: 24),
                      TextField(
                        controller: _reasonController,
                        maxLines: 3,
                        autofocus: true,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Enter specific reason/details...',
                          hintStyle: const TextStyle(color: AppColors.textSecondary),
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedTempStatus == ItemStatus.fail ? AppColors.danger : AppColors.warning,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            if (_reasonController.text.trim().isEmpty) return; // Prevent empty reasons
                            widget.onStatusChanged(selectedTempStatus!);
                            widget.onNotesChanged(_reasonController.text.trim());
                            setState(() => _isAssessed = true);
                            Navigator.pop(context);
                          },
                          child: const Text('SAVE & LOCK', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Helper for the Dialog buttons
  Widget _dialogStatusBtn(String label, Color color, StateSetter setDialogState, ItemStatus? currentSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.item.isRoadworthyRelevant ? AppColors.warning.withValues(alpha: 0.3) : AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Title Area
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.title,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    if (widget.item.isRoadworthyRelevant) ...[
                      const SizedBox(height: 4),
                      const Text('CRITICAL ROADWORTHY ITEM', style: TextStyle(color: AppColors.warning, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ]
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // DYNAMIC ACTION AREA
              if (!_isAssessed)
                // Default State: Big Capture Button
                InkWell(
                  onTap: _startCaptureWorkflow,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.gold, width: 1.5),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.camera_alt, color: AppColors.gold, size: 20),
                        SizedBox(width: 8),
                        Text('CAPTURE', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                )
              else
                // Completed State: Status Badge + Multi-Photo Indicator
                Row(
                  children: [
                    // Photo Indicator (Tap to add more angles)
                    InkWell(
                      onTap: _startCaptureWorkflow,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.panel,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.photo_library, color: AppColors.textSecondary, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              '${widget.item.photoPaths.length}',
                              style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.add, color: AppColors.gold, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Final Status Badge
                    _buildFinalStatusBadge(),
                  ],
                ),
            ],
          ),

          // INLINE COMMENT DISPLAY (Guaranteed to show if notes exist)
          if (_isAssessed && widget.item.notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.item.status == ItemStatus.fail ? AppColors.danger.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(
                    color: widget.item.status == ItemStatus.fail ? AppColors.danger : AppColors.warning,
                    width: 4,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, size: 18, color: widget.item.status == ItemStatus.fail ? AppColors.danger : AppColors.warning),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.item.notes,
                      style: TextStyle(
                        color: widget.item.status == ItemStatus.fail ? AppColors.danger : AppColors.warning,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildFinalStatusBadge() {
    Color color = AppColors.success;
    String text = 'PASS';

    if (widget.item.status == ItemStatus.attention) {
      color = AppColors.warning;
      text = 'ATTENTION';
    } else if (widget.item.status == ItemStatus.fail) {
      color = AppColors.danger;
      text = 'FAIL';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, letterSpacing: 1)),
    );
  }
}