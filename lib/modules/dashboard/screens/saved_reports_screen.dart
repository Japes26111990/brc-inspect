import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../inspection/providers/inspection_provider.dart';
import '../../inspection/screens/inspection_flow_screen.dart';

class SavedReportsScreen extends StatelessWidget {
  const SavedReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ActiveInspectionProvider>(context);

    // Dynamic mock list representing our in-progress inspection queue
    final List<Map<String, dynamic>> activeDrafts = [
      {
        'registration': 'CA 123-456',
        'vehicle': 'TOYOTA HILUX 2.8 GD-6',
        'type': InspectionType.roadworthy,
        'progress': 0.77,
        'lastUpdated': '20 mins ago',
      },
      {
        'registration': 'CY 987-654',
        'vehicle': 'VOLKSWAGEN GOLF 8 GTI',
        'type': InspectionType.conditionReport,
        'progress': 0.33,
        'lastUpdated': '2 hours ago',
      },
      {
        'registration': 'CAA 555-111',
        'vehicle': 'MERCEDES-BENZ ACTROS 2652',
        'type': InspectionType.fleet,
        'progress': 0.11,
        'lastUpdated': 'Yesterday',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.panel,
        elevation: 0,
        title: const Text('Saved & Draft Reports', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ACTIVE WORKSPACE QUEUE (${activeDrafts.length})',
                style: TextStyle(
                  color: AppColors.gold.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: activeDrafts.length,
                  itemBuilder: (context, index) {
                    final item = activeDrafts[index];
                    return _buildDraftCard(context, provider, item);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDraftCard(
    BuildContext context, 
    ActiveInspectionProvider provider, 
    Map<String, dynamic> item
  ) {
    String typeLabel = 'Condition Report';
    Color typeColor = AppColors.gold;
    
    if (item['type'] == InspectionType.roadworthy) {
      typeLabel = 'Roadworthy Inspection';
      typeColor = const Color(0xff10B981);
    } else if (item['type'] == InspectionType.fleet) {
      typeLabel = 'Fleet Operational Audit';
      typeColor = const Color(0xff0EA5E9);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.15), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          provider.setInspectionType(item['type']);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const InspectionFlowScreen(),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['registration'],
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: typeColor.withValues(alpha: 0.3), width: 0.5),
                    ),
                    child: Text(
                      typeLabel.toUpperCase(),
                      style: TextStyle(color: typeColor, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                item['vehicle'],
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress: ${(item['progress'] * 100).toInt()}%',
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Edited ${item['lastUpdated']}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: item['progress'],
                  minHeight: 6,
                  backgroundColor: AppColors.background,
                  valueColor: AlwaysStoppedAnimation<Color>(typeColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}