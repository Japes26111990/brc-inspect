import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../models/inspection_models.dart';
import '../providers/inspection_provider.dart';

class DriveSystemSection extends StatelessWidget {
  final ActiveInspectionProvider provider;
  final String targetSectionName;

  const DriveSystemSection({
    super.key,
    required this.provider,
    required this.targetSectionName,
  });

  @override
  Widget build(BuildContext context) {
    final List<ComponentResult> allItems =
        provider.sections[targetSectionName] ?? [];
    return _DriveSystemListContainer(
      items: allItems,
      provider: provider,
      targetSectionName: targetSectionName,
    );
  }
}

class _DriveSystemListContainer extends StatefulWidget {
  final List<ComponentResult> items;
  final ActiveInspectionProvider provider;
  final String targetSectionName;

  const _DriveSystemListContainer({
    required this.items,
    required this.provider,
    required this.targetSectionName,
  });

  @override
  State<_DriveSystemListContainer> createState() =>
      _DriveSystemListContainerState();
}

class _DriveSystemListContainerState extends State<_DriveSystemListContainer> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final comp = widget.items[index];
        bool hasBeenAssessed =
            comp.isNotApplicable ||
            comp.photoTargets.first.status != ItemStatus.na;

        return Container(
          key: ValueKey('${widget.targetSectionName}-${comp.id}'),
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
                        if (comp.isCompulsory) ...[
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
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children:
                        [ItemStatus.pass, ItemStatus.fail, ItemStatus.na].map((
                          st,
                        ) {
                          // 🌟 FIXED: N/A is now ALWAYS visible for every item, regardless of compulsory status!

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
                                  if (st == ItemStatus.na) {
                                    comp.isNotApplicable = true;
                                  } else {
                                    comp.isNotApplicable = false;
                                    for (var t in comp.photoTargets)
                                      t.status = st;
                                  }
                                });
                                widget.provider.notifyListeners();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
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
                                  st == ItemStatus.na
                                      ? 'N/A'
                                      : st.name.toUpperCase(),
                                  style: TextStyle(
                                    color:
                                        isSel
                                            ? btnColor
                                            : AppColors.textSecondary,
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

              // 🌟 FORCED NOTES ON FAIL (Camera Removed completely)
              if (!comp.isNotApplicable &&
                  comp.photoTargets.first.status == ItemStatus.fail) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red,
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
                              widget.provider.notifyListeners();
                            },
                            decoration: InputDecoration(
                              hintText: 'MANDATORY REASON REQUIRED...',
                              hintStyle: const TextStyle(
                                color: Colors.redAccent,
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
                                borderSide: const BorderSide(
                                  color: Colors.redAccent,
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
      },
    );
  }
}
