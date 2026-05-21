import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../providers/inspection_provider.dart';
import '../models/inspection_models.dart';

class TestDriveSection extends StatefulWidget {
  final ActiveInspectionProvider provider;

  const TestDriveSection({super.key, required this.provider});

  @override
  State<TestDriveSection> createState() => _TestDriveSectionState();
}

class _TestDriveSectionState extends State<TestDriveSection> {
  @override
  Widget build(BuildContext context) {
    final items = widget.provider.sections['Test Drive'] ?? [];

    return Column(
      children: items.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: item.rating == 0 ? AppColors.border : AppColors.gold,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('Rate Condition (1 = Poor, 5 = Excellent)', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              
              // 5-POINT RATING ROW
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  int starValue = index + 1;
                  bool isSelected = item.rating == starValue;
                  
                  return InkWell(
                    onTap: () {
                      setState(() {
                        item.rating = starValue;
                        if (starValue <= 2) {
                          item.status = ItemStatus.fail;
                        } else if (starValue <= 4) {
                          item.status = ItemStatus.attention;
                        } else {
                          item.status = ItemStatus.pass;
                        }
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.gold : AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? AppColors.gold : AppColors.border),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        starValue.toString(),
                        style: TextStyle(
                          color: isSelected ? Colors.black : AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
              ),

              // COMMENT BOX (Required if rating is 4 or below)
              if (item.rating > 0 && item.rating <= 4) ...[
                const SizedBox(height: 20),
                TextFormField(
                  initialValue: item.notes,
                  onChanged: (val) => item.notes = val,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Required: Explain why this rated $item.rating/5...',
                    hintStyle: const TextStyle(color: AppColors.danger),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                )
              ]
            ],
          ),
        );
      }).toList(),
    );
  }
}