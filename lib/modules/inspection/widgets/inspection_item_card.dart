import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../models/inspection_models.dart';

class InspectionItemCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              item.isRoadworthyRelevant
                  ? AppColors.warning.withOpacity(0.4)
                  : AppColors.gold.withOpacity(0.25),
          width: item.isRoadworthyRelevant ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (item.isRoadworthyRelevant)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'ROADWORTHY CRITICAL',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _statusButton(
                'PASS',
                ItemStatus.pass,
                item.status == ItemStatus.pass,
              ),
              const SizedBox(width: 14),
              _statusButton(
                'ATTENTION',
                ItemStatus.attention,
                item.status == ItemStatus.attention,
              ),
              const SizedBox(width: 14),
              _statusButton(
                'FAIL',
                ItemStatus.fail,
                item.status == ItemStatus.fail,
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextFormField(
            initialValue: item.notes,
            maxLines: 2,
            style: const TextStyle(color: AppColors.textPrimary),
            onChanged: onNotesChanged,
            decoration: InputDecoration(
              hintText: 'Inspector notes...',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.background,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusButton(String label, ItemStatus statusType, bool isSelected) {
    Color activeColor = AppColors.gold;
    if (statusType == ItemStatus.pass) activeColor = AppColors.success;
    if (statusType == ItemStatus.attention) activeColor = AppColors.warning;
    if (statusType == ItemStatus.fail) activeColor = AppColors.danger;

    return Expanded(
      child: InkWell(
        onTap: () => onStatusChanged(statusType),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? activeColor : AppColors.border,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
