import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../inspection/screens/inspection_type_screen.dart';
import 'saved_reports_screen.dart'; // 🚀 INJECTED: Imports your new active workspace queue screen

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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// 🚀 MAIN ACTION
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

                  /// 📂 CORE WORKSPACE ACTION
                  DashboardButton(
                    title: 'Saved & Draft Reports',
                    icon: Icons.folder_open_outlined,
                    onTap: () {
                      // 🚀 FIXED: Links directly to your interactive Saved & Draft workspace screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SavedReportsScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),
                  const Divider(color: AppColors.gold, thickness: 0.5, indent: 20, endIndent: 20),
                  const SizedBox(height: 24),

                  /// 📊 OWNER'S ANALYTICS CONTROL PANEL
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(Icons.analytics_outlined, color: AppColors.gold, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'BUSINESS INSIGHTS (MANAGEMENT)',
                        style: TextStyle(
                          color: AppColors.gold.withValues(alpha: 0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),

                  // 💰 Analytics Widget 1: Throughput Metrics
                  _buildStatCard(
                    context,
                    title: 'Monthly Throughput Variance',
                    subtitle: 'Total volume generated this month',
                    value: '142 Vehicles',
                    trendText: '+18% vs last month',
                    isPositiveTrend: true,
                    icon: Icons.trending_up_rounded,
                  ),

                  const SizedBox(height: 16),

                  // ⚖️ Analytics Widget 2: Pass/Fail Compliance
                  _buildStatCard(
                    context,
                    title: 'Roadworthy Compliance Yield',
                    subtitle: 'Pass vs fail evaluation metrics',
                    value: '74% Pass Rate',
                    trendText: '37 Fails Documented',
                    isPositiveTrend: false,
                    icon: Icons.gavel_rounded,
                  ),

                  const SizedBox(height: 16),

                  // 🚚 Analytics Widget 3: Corporate Fleet Focus
                  _buildStatCard(
                    context,
                    title: 'Commercial Fleet Utilization',
                    subtitle: 'Active corporate utility service logs',
                    value: '18 Open Accounts',
                    trendText: 'Active contract tokens nominal',
                    isPositiveTrend: true,
                    icon: Icons.business_center_rounded,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🛠️ Premium Analytics Card View Builder
  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String value,
    required String trendText,
    required bool isPositiveTrend,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.15), width: 1),
            ),
            child: Icon(icon, color: AppColors.gold, size: 24),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w900)),
                    const SizedBox(width: 10),
                    Text(
                      trendText,
                      style: TextStyle(
                        color: isPositiveTrend ? Colors.green : AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
              color: AppColors.gold.withValues(alpha: isPrimary ? 0.12 : 0.05),
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