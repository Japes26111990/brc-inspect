import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../inspection/screens/inspection_type_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.panel,
        elevation: 0,
        titleSpacing: 20,

        title: Row(
          children: [
            Image.asset('assets/logos/brc_logo.png', height: 32),

            const SizedBox(width: 14),

            const Text(
              'BRC Inspect',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),

      body: Center(
        child: SizedBox(
          width: 500,

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              /// MAIN ACTION
              DashboardButton(
                title: 'START NEW INSPECTION',
                icon: Icons.play_arrow_rounded,
                isPrimary: true,

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InspectionTypeScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 26),

              /// SECONDARY ACTIONS
              DashboardButton(
                title: 'Saved Reports',
                icon: Icons.folder_open_outlined,
                onTap: () {},
              ),

              const SizedBox(height: 18),

              DashboardButton(
                title: 'Roadworthy Queue',
                icon: Icons.verified_outlined,
                onTap: () {},
              ),

              const SizedBox(height: 18),

              DashboardButton(
                title: 'Fleet Inspections',
                icon: Icons.local_shipping_outlined,
                onTap: () {},
              ),

              const SizedBox(height: 18),

              DashboardButton(
                title: 'Draft Reports',
                icon: Icons.description_outlined,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const DashboardButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),

      onTap: onTap,

      child: Container(
        width: double.infinity,

        padding: EdgeInsets.symmetric(
          horizontal: 28,
          vertical: isPrimary ? 26 : 22,
        ),

        decoration: BoxDecoration(
          color: AppColors.panel,

          borderRadius: BorderRadius.circular(20),

          border: Border.all(color: AppColors.gold, width: isPrimary ? 1.5 : 1),

          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withOpacity(isPrimary ? 0.12 : 0.05),
              blurRadius: isPrimary ? 24 : 12,
            ),
          ],
        ),

        child: Row(
          children: [
            Icon(icon, color: AppColors.gold, size: isPrimary ? 34 : 28),

            const SizedBox(width: 22),

            Text(
              title,

              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: isPrimary ? 24 : 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
