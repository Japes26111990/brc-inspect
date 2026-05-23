import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../models/inspection_models.dart';
import '../providers/inspection_provider.dart';

class SummarySection extends StatelessWidget {
  final ActiveInspectionProvider provider;
  const SummarySection({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    List<Widget> activeFaultRows = [];

    provider.sections.forEach((sectionName, componentList) {
      for (var comp in componentList) {
        if (comp.isNotApplicable) continue;
        for (var target in comp.photoTargets) {
          if (target.status == ItemStatus.fail || target.status == ItemStatus.attention) {
            activeFaultRows.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(target.status == ItemStatus.fail ? Icons.cancel : Icons.error, color: target.status == ItemStatus.fail ? Colors.red : Colors.amber, size: 16),
                    const SizedBox(width: 8),
                    Text('${comp.title} (${target.label}): ', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                    Expanded(child: Text(target.notes.isEmpty ? 'Defect flagged.' : target.notes, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
                  ],
                ),
              ),
            );
          }
        }
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('TELEMETRY FAULT HIGHLIGHTS', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (activeFaultRows.isEmpty)
          const Text('All inspected sub-system targets are operating within nominal parameters.', style: TextStyle(color: Colors.green, fontSize: 13, fontStyle: FontStyle.italic))
        else
          Column(children: activeFaultRows),
      ],
    );
  }
}