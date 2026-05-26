import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../models/inspection_models.dart';
import '../providers/inspection_provider.dart';

class WheelsTyresSection extends StatefulWidget {
  final ActiveInspectionProvider provider;
  final String renderMode;

  const WheelsTyresSection({
    super.key,
    required this.provider,
    required this.renderMode,
  });

  @override
  State<WheelsTyresSection> createState() => _WheelsTyresSectionState();
}

class _WheelsTyresSectionState extends State<WheelsTyresSection> {
  @override
  Widget build(BuildContext context) {
    if (widget.renderMode == 'Dimensions') {
      final List<ComponentResult> items =
          widget.provider.sections['12 DIMENSIONS'] ?? [];

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
            key: ValueKey('12 DIMENSIONS-${comp.id}'),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  hasBeenAssessed
                      ? AppColors.accent.withOpacity(0.1)
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
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // PASS/FAIL/NA BUTTONS
                    Row(
                      children:
                          [ItemStatus.pass, ItemStatus.fail, ItemStatus.na].map(
                            (st) {
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
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
                                        color:
                                            isSel ? btnColor : AppColors.border,
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
                            },
                          ).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // TEXT FIELD FOR THE VALUE
                SizedBox(
                  height: 40,
                  child: TextFormField(
                    initialValue:
                        widget.provider.vehicleDetails[comp.title] ?? '',
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    onChanged: (v) {
                      widget.provider.vehicleDetails[comp.title] = v;
                      widget.provider.notifyListeners();
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter value (mm)...',
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
                // MANDATORY FAIL NOTES
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
                        widget.provider.notifyListeners();
                      },
                      decoration: InputDecoration(
                        hintText: 'MANDATORY REASON REQUIRED...',
                        hintStyle: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
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
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      );
    }
    return const SizedBox();
  }
}
