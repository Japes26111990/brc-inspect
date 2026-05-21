import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class SummarySection extends StatelessWidget {
  const SummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 80),

          Icon(
            Icons.assignment_turned_in_outlined,
            size: 100,
            color: AppColors.gold,
          ),

          const SizedBox(height: 30),

          const Text(
            'Inspection Summary',

            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Final inspection summary and report generation.',

            style: TextStyle(color: AppColors.textSecondary, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
