import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import 'inspection_flow_screen.dart';

class InspectionTypeScreen extends StatelessWidget {
  const InspectionTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.panel,

        title: const Text('Select Inspection Type'),
      ),

      body: Center(
        child: SizedBox(
          width: 520,

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              InspectionTypeButton(
                title: 'Vehicle Condition Report',
                subtitle: 'Detailed vehicle condition assessment',
                icon: Icons.assignment_outlined,

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InspectionFlowScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 22),

              InspectionTypeButton(
                title: 'Roadworthy Inspection',
                subtitle: 'Roadworthy compliance inspection',
                icon: Icons.verified_outlined,

                onTap: () {},
              ),

              const SizedBox(height: 22),

              InspectionTypeButton(
                title: 'Fleet Inspection',
                subtitle: 'Commercial and fleet inspections',
                icon: Icons.local_shipping_outlined,

                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InspectionTypeButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const InspectionTypeButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),

      onTap: onTap,

      child: Container(
        width: double.infinity,

        padding: const EdgeInsets.all(28),

        decoration: BoxDecoration(
          color: AppColors.panel,

          borderRadius: BorderRadius.circular(20),

          border: Border.all(color: AppColors.gold, width: 1),

          boxShadow: [
            BoxShadow(color: AppColors.gold.withOpacity(0.08), blurRadius: 16),
          ],
        ),

        child: Row(
          children: [
            Icon(icon, color: AppColors.gold, size: 42),

            const SizedBox(width: 24),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    title,

                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    subtitle,

                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
