import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../theme/app_colors.dart';
import '../models/inspection_models.dart';
import '../providers/inspection_provider.dart';

class DriveSystemSection extends StatelessWidget {
  final ActiveInspectionProvider provider;
  final String targetSectionName;

  const DriveSystemSection({super.key, required this.provider, required this.targetSectionName});

  @override
  Widget build(BuildContext context) {
    final List<ComponentResult> allItems = provider.sections[targetSectionName] ?? [];
    return _DriveSystemListContainer(items: allItems, provider: provider, targetSectionName: targetSectionName);
  }
}

class _DriveSystemListContainer extends StatefulWidget {
  final List<ComponentResult> items;
  final ActiveInspectionProvider provider;
  final String targetSectionName;

  const _DriveSystemListContainer({required this.items, required this.provider, required this.targetSectionName});

  @override
  State<_DriveSystemListContainer> createState() => _DriveSystemListContainerState();
}

class _DriveSystemListContainerState extends State<_DriveSystemListContainer> {
  final ImagePicker _imagePicker = ImagePicker();

  void _capturePhoto(SubPhotoTarget target) async {
    final XFile? file = await _imagePicker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (file == null) return;
    setState(() => target.photoPath = file.path);
    widget.provider.notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final comp = widget.items[index];
        bool hasBeenAssessed = comp.isNotApplicable || comp.photoTargets.first.status != ItemStatus.na;

        // 🎨 VISUAL ENFORCEMENT: Glowing emerald background shows the item is handled and not missed
        final Color cardBackground = hasBeenAssessed 
            ? const Color(0xFF1B4332) 
            : AppColors.card;

        return Container(
          key: ValueKey('${widget.targetSectionName}-${comp.id}'), 
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: hasBeenAssessed
                  ? const Color(0xFF52B788) 
                  : (comp.isCompulsory ? AppColors.gold.withOpacity(0.8) : Colors.transparent),
              width: comp.isCompulsory ? 1.5 : 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (comp.isCompulsory) ...[
                          const Icon(Icons.gavel_rounded, color: Colors.red, size: 14),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            comp.title,
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 🎯 DUAL OPTION WORKFLOW: Stripped down strictly to PASS or FAIL
                  Row(
                    children: [ItemStatus.pass, ItemStatus.fail, ItemStatus.na].map((st) {
                      // Hide N/A completely on mandatory rows to keep layout bulletproof
                      if (comp.isCompulsory && st == ItemStatus.na) return const SizedBox.shrink();
                      
                      bool isSel = comp.isNotApplicable ? (st == ItemStatus.na) : (comp.photoTargets.first.status == st && !comp.isNotApplicable);
                      Color btnColor = st == ItemStatus.pass ? Colors.green : (st == ItemStatus.fail ? Colors.red : Colors.grey);

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              if (st == ItemStatus.na) {
                                comp.isNotApplicable = true;
                              } else {
                                comp.isNotApplicable = false;
                                for (var t in comp.photoTargets) {
                                  t.status = st;
                                }
                              }
                            });
                            widget.provider.notifyListeners();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSel ? btnColor.withOpacity(0.2) : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: isSel ? btnColor : AppColors.border, width: 1),
                            ),
                            child: Text(
                              st == ItemStatus.na ? 'N/A' : st.name.toUpperCase(),
                              style: TextStyle(color: isSel ? btnColor : AppColors.textSecondary, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              if (!comp.isNotApplicable && comp.photoTargets.first.status == ItemStatus.fail) ...[
                ...comp.photoTargets.map((target) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(target.photoPath == null ? Icons.camera_alt_outlined : Icons.check_circle, color: target.photoPath == null ? AppColors.gold : Colors.green, size: 16),
                          onPressed: () => _capturePhoto(target),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(target.label, style: const TextStyle(color: AppColors.gold, fontSize: 10, fontStyle: FontStyle.italic)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 30,
                            child: TextFormField(
                              initialValue: target.notes,
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                              onChanged: (v) {
                                target.notes = v;
                                widget.provider.notifyListeners();
                              },
                              // 📝 CRITICAL FIX: Failure nodes force validation notes before moving on
                              decoration: InputDecoration(
                                hintText: 'Notes required: Explain defect...',
                                hintStyle: const TextStyle(color: Colors.redAccent, fontSize: 10, fontStyle: FontStyle.italic),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                fillColor: AppColors.background,
                                filled: true,
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Colors.redAccent, width: 0.5)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.gold, width: 1)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ],
          ),
        );
      },
    );
  }
}