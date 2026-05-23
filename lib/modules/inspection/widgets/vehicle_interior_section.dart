import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../theme/app_colors.dart';
import '../models/inspection_models.dart';
import '../providers/inspection_provider.dart';

class VehicleInteriorSection extends StatelessWidget {
  final ActiveInspectionProvider provider;
  const VehicleInteriorSection({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final List<ComponentResult> allItems = provider.sections['Vehicle Interior'] ?? [];
    
    final List<ComponentResult> filteredItems = allItems.where((component) {
      if (provider.activeType == InspectionType.roadworthy) {
        return component.isRoadworthyRelevant; // Show Hooter, Cluster, and Safety Belts only
      }
      if (provider.activeType == InspectionType.fleet) {
        return component.isRoadworthyRelevant || component.id == 'instrument_cluster';
      }
      return true;
    }).toList();

    return _InteriorListContainer(items: filteredItems, provider: provider);
  }
}

class _InteriorListContainer extends StatefulWidget {
  final List<ComponentResult> items;
  final ActiveInspectionProvider provider;
  const _InteriorListContainer({required this.items, required this.provider});

  @override
  State<_InteriorListContainer> createState() => _InteriorListContainerState();
}

class _InteriorListContainerState extends State<_InteriorListContainer> {
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

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.panel,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: comp.finalStatus == ItemStatus.fail 
                  ? Colors.red.withOpacity(0.4) 
                  : (comp.finalStatus == ItemStatus.attention ? Colors.amber.withOpacity(0.4) : Colors.transparent),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(comp.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                        if (comp.isRoadworthyRelevant) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.gavel, color: Colors.red, size: 13),
                        ]
                      ],
                    ),
                  ),
                  Row(
                    children: [ItemStatus.pass, ItemStatus.attention, ItemStatus.fail, ItemStatus.na].map((st) {
                      bool isSel = comp.isNotApplicable ? (st == ItemStatus.na) : (comp.photoTargets.first.status == st && !comp.isNotApplicable);
                      Color btnColor = st == ItemStatus.pass ? Colors.green : (st == ItemStatus.attention ? Colors.amber : (st == ItemStatus.fail ? Colors.red : Colors.grey));
                      
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
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: isSel ? btnColor.withOpacity(0.25) : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: isSel ? btnColor : AppColors.textSecondary.withOpacity(0.2), width: 1),
                            ),
                            child: Text(st == ItemStatus.na ? 'N/A' : st.name.toUpperCase(), style: TextStyle(color: isSel ? btnColor : AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              if (!comp.isNotApplicable) ...[
                ...comp.photoTargets.map((target) {
                  // Fleet skips instrument clusters to speed up checks unless a fault is noted
                  bool needsPhoto = comp.id == 'instrument_cluster' && widget.provider.activeType != InspectionType.fleet;
                  bool showCommentBox = (target.status == ItemStatus.attention || target.status == ItemStatus.fail);
                  
                  if (!needsPhoto && !showCommentBox) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (needsPhoto) ...[
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(target.photoPath == null ? Icons.camera_alt : Icons.check_circle, color: target.photoPath == null ? AppColors.gold : Colors.green, size: 18),
                                onPressed: () => _capturePhoto(target),
                              ),
                              Expanded(
                                child: Text(target.label, style: const TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic)),
                              ),
                              const SizedBox(width: 8),
                              if (target.photoPath != null && !kIsWeb)
                                ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.file(File(target.photoPath!), width: 40, height: 30, fit: BoxFit.cover)),
                            ],
                          ),
                        ],
                        if (showCommentBox)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 6),
                            child: SizedBox(
                              height: 32,
                              child: TextFormField(
                                initialValue: target.notes,
                                style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                                onChanged: (v) {
                                  target.notes = v;
                                  widget.provider.notifyListeners();
                                },
                                decoration: InputDecoration(
                                  hintText: 'Notes required: Explain defect status...',
                                  hintStyle: const TextStyle(color: Colors.red, fontSize: 11, fontStyle: FontStyle.italic),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                  fillColor: AppColors.background,
                                  filled: true,
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.gold, width: 0.5)),
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