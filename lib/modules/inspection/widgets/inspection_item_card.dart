import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../models/inspection_models.dart';
import '../providers/inspection_provider.dart';

class InspectionItemCard extends StatefulWidget {
  final ComponentResult comp;
  final ActiveInspectionProvider provider;
  final bool showValueInput;
  final String valueInputHint;

  const InspectionItemCard({
    super.key,
    required this.comp,
    required this.provider,
    this.showValueInput = false,
    this.valueInputHint = 'Enter value...',
  });

  @override
  State<InspectionItemCard> createState() => _InspectionItemCardState();
}

class _InspectionItemCardState extends State<InspectionItemCard> {
  bool _isCommentOpen = false;

  String _getButtonLabel(ItemStatus status, EvaluationScale scale) {
    if (status == ItemStatus.na) return 'N/A';
    if (scale == EvaluationScale.severity) {
      // Mapping for Metric Severity Scale
      if (status == ItemStatus.pass) return 'NIL';
      if (status == ItemStatus.attention) return 'SLIGHT';
      if (status == ItemStatus.fail) return 'APPRECIABLE';
    }
    // Mapping for Standard Binary Scale
    return status.name.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final comp = widget.comp;
    bool hasBeenAssessed =
        comp.isNotApplicable || comp.photoTargets.first.status != ItemStatus.na;

    // Determine which statuses to show based on the scale
    List<ItemStatus> availableStatuses =
        comp.scale == EvaluationScale.severity
            ? [ItemStatus.pass, ItemStatus.attention, ItemStatus.fail]
            : [ItemStatus.pass, ItemStatus.fail, ItemStatus.na];

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color:
            hasBeenAssessed
                ? AppColors.accent.withOpacity(0.1)
                : AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color:
              hasBeenAssessed
                  ? AppColors.gold
                  : (comp.isCompulsory
                      ? AppColors.gold.withOpacity(0.8)
                      : AppColors.border),
          width: hasBeenAssessed ? 1.5 : 0.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    if (comp.isCompulsory && !widget.showValueInput) ...[
                      const Icon(
                        Icons.gavel_rounded,
                        color: Colors.red,
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        comp.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // NEW: Comment Toggle Button
              IconButton(
                icon: Icon(
                  _isCommentOpen || comp.photoTargets.first.notes.isNotEmpty
                      ? Icons.chat_bubble
                      : Icons.chat_bubble_outline,
                ),
                color:
                    _isCommentOpen || comp.photoTargets.first.notes.isNotEmpty
                        ? AppColors.gold
                        : AppColors.border,
                iconSize: 20,
                padding: EdgeInsets.zero, // FIXED ERROR HERE
                constraints: const BoxConstraints(),
                onPressed: () {
                  setState(() => _isCommentOpen = !_isCommentOpen);
                },
              ),
              const SizedBox(width: 6),

              Row(
                children:
                    availableStatuses.map((st) {
                      bool isSel =
                          comp.isNotApplicable
                              ? (st == ItemStatus.na)
                              : (comp.photoTargets.first.status == st &&
                                  !comp.isNotApplicable);

                      Color btnColor = Colors.grey;
                      if (st == ItemStatus.pass) btnColor = Colors.green;
                      if (st == ItemStatus.attention) btnColor = Colors.orange;
                      if (st == ItemStatus.fail) btnColor = Colors.red;

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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSel
                                      ? btnColor.withOpacity(0.2)
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isSel ? btnColor : AppColors.border,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _getButtonLabel(st, comp.scale),
                              style: TextStyle(
                                color:
                                    isSel ? btnColor : AppColors.textSecondary,
                                fontSize: 9,
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

          if (widget.showValueInput) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: TextFormField(
                initialValue: widget.provider.vehicleDetails[comp.title] ?? '',
                keyboardType: TextInputType.text,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                onChanged: (v) {
                  widget.provider.vehicleDetails[comp.title] = v;
                },
                decoration: InputDecoration(
                  hintText: widget.valueInputHint,
                  fillColor: AppColors.background,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 0,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.border,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.gold,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],

          if (_isCommentOpen ||
              (!comp.isNotApplicable &&
                  comp.photoTargets.first.status == ItemStatus.fail)) ...[
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(
                    comp.photoTargets.first.status == ItemStatus.fail
                        ? Icons.warning_amber_rounded
                        : Icons.mode_edit_outline,
                    color:
                        comp.photoTargets.first.status == ItemStatus.fail
                            ? Colors.red
                            : AppColors.gold,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: TextFormField(
                        initialValue: comp.photoTargets.first.notes,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                        ),
                        onChanged: (v) {
                          comp.photoTargets.first.notes = v;
                        },
                        decoration: InputDecoration(
                          hintText:
                              comp.photoTargets.first.status == ItemStatus.fail
                                  ? 'MANDATORY REASON REQUIRED...'
                                  : 'Add optional examiner comments...',
                          hintStyle: TextStyle(
                            color:
                                comp.photoTargets.first.status ==
                                        ItemStatus.fail
                                    ? Colors.redAccent
                                    : AppColors.textSecondary,
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 0,
                          ),
                          fillColor: AppColors.background,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(
                              color:
                                  comp.photoTargets.first.status ==
                                          ItemStatus.fail
                                      ? Colors.redAccent
                                      : AppColors.border,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(
                              color: AppColors.gold,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
