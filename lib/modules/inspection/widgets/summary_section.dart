import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../providers/inspection_provider.dart';
import '../models/inspection_models.dart';

class SummarySection extends StatelessWidget {
  final ActiveInspectionProvider provider;

  const SummarySection({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final bool passesOverall = provider.passesRoadworthy;

    // Gather all faults dynamically
    List<Widget> failedItems = [];
    List<Widget> attentionItems = [];

    // Check Tyres
    for (var tyre in provider.tyres) {
      if (tyre.status == ItemStatus.fail) {
        failedItems.add(_buildFaultRow('Tyre: ${tyre.position}', '${tyre.treadDepthMm}mm (Illegal)', true));
      } else if (tyre.status == ItemStatus.attention) {
        attentionItems.add(_buildFaultRow('Tyre: ${tyre.position}', '${tyre.treadDepthMm}mm (Low)', false));
      }
    }

    // Check Components
    provider.sections.forEach((sectionName, items) {
      for (var item in items) {
        if (item.status == ItemStatus.fail) {
          failedItems.add(_buildFaultRow(item.title, item.notes, item.isRoadworthyRelevant));
        } else if (item.status == ItemStatus.attention) {
          attentionItems.add(_buildFaultRow(item.title, item.notes, item.isRoadworthyRelevant));
        }
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // BIG FINAL VERDICT BADGE
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: passesOverall ? AppColors.success.withValues(alpha: 0.1) : AppColors.danger.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: passesOverall ? AppColors.success : AppColors.danger, width: 2),
          ),
          child: Column(
            children: [
              Icon(
                passesOverall ? Icons.verified : Icons.cancel_outlined,
                size: 80,
                color: passesOverall ? AppColors.success : AppColors.danger,
              ),
              const SizedBox(height: 16),
              Text(
                passesOverall ? 'VEHICLE PASSED' : 'VEHICLE FAILED',
                style: TextStyle(
                  color: passesOverall ? AppColors.success : AppColors.danger,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                passesOverall 
                    ? 'This vehicle complies with all critical roadworthy standards.'
                    : 'This vehicle has critical faults and is NOT roadworthy.',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // CRITICAL FAILURES LIST
        if (failedItems.isNotEmpty) ...[
          const Text('CRITICAL FAILURES', style: TextStyle(color: AppColors.danger, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...failedItems,
          const SizedBox(height: 30),
        ],

        // ATTENTION REQUIRED LIST
        if (attentionItems.isNotEmpty) ...[
          const Text('ATTENTION REQUIRED', style: TextStyle(color: AppColors.warning, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...attentionItems,
        ],

        if (failedItems.isEmpty && attentionItems.isEmpty)
          const Padding(
            padding: EdgeInsets.all(40.0),
            child: Center(
              child: Text(
                'No faults recorded. Vehicle is in excellent condition.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 18),
              ),
            ),
          )
      ],
    );
  }

  Widget _buildFaultRow(String title, String notes, bool isCritical) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_rounded, color: isCritical ? AppColors.danger : AppColors.warning, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(notes, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}