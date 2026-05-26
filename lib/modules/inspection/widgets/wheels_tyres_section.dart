import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../providers/inspection_provider.dart';
import 'drive_system_section.dart';

class WheelsTyresSection extends StatefulWidget {
  final ActiveInspectionProvider provider;
  final String renderMode; 

  const WheelsTyresSection({super.key, required this.provider, required this.renderMode});

  @override
  State<WheelsTyresSection> createState() => _WheelsTyresSectionState();
}

class _WheelsTyresSectionState extends State<WheelsTyresSection> {
  Widget _buildNumericMetricBox({
    required String cellLabel,
    required String dataKey,
    required ActiveInspectionProvider state,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(cellLabel, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        SizedBox(
          height: 36,
          child: TextFormField(
            initialValue: state.vehicleDetails[dataKey] ?? '',
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
            onChanged: (v) {
              state.vehicleDetails[dataKey] = v;
              state.notifyListeners();
            },
            decoration: InputDecoration(
              // 🎨 HIGH-CONTRAST REWRITE: Forced panel theme fallback coloring layer explicitly
              fillColor: AppColors.panel,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8), 
                borderSide: const BorderSide(color: AppColors.border, width: 0.5)
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8), 
                borderSide: const BorderSide(color: AppColors.gold, width: 1.5)
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.renderMode == 'Brakes') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DriveSystemSection(provider: widget.provider, targetSectionName: 'Braking System'),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border, width: 0.5)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.gavel_rounded, color: Colors.red, size: 14),
                    SizedBox(width: 8),
                    Text('SERVICE BRAKES TESTING FORCE VALUES', style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.8,
                  children: [
                    _buildNumericMetricBox(cellLabel: 'L/F', dataKey: 'Brake_LF', state: widget.provider),
                    _buildNumericMetricBox(cellLabel: 'R/F', dataKey: 'Brake_RF', state: widget.provider),
                    _buildNumericMetricBox(cellLabel: 'L/R', dataKey: 'Brake_LR', state: widget.provider),
                    _buildNumericMetricBox(cellLabel: 'R/R', dataKey: 'Brake_RR', state: widget.provider),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border, width: 0.5)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.gavel_rounded, color: Colors.red, size: 14),
                    SizedBox(width: 8),
                    Text('TEST PARKING / EMERGENCY BRAKE SPECIFICS', style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.8,
                  children: [
                    _buildNumericMetricBox(cellLabel: 'L/F 1', dataKey: 'Park_LF1', state: widget.provider),
                    _buildNumericMetricBox(cellLabel: 'R/F 1', dataKey: 'Park_RF1', state: widget.provider),
                    _buildNumericMetricBox(cellLabel: 'L/R 2', dataKey: 'Park_LR2', state: widget.provider),
                    _buildNumericMetricBox(cellLabel: 'R/R 2', dataKey: 'Park_RR2', state: widget.provider),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DriveSystemSection(provider: widget.provider, targetSectionName: 'Wheels'),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border, width: 0.5)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  SizedBox(width: 4),
                  Text('CHECK TREAD DEPTH RUNOUT (OPTIONAL mm VALUES)', style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                childAspectRatio: 1.8,
                children: [
                  _buildNumericMetricBox(cellLabel: 'L/F (mm)', dataKey: 'Odo_LF', state: widget.provider),
                  _buildNumericMetricBox(cellLabel: 'R/F (mm)', dataKey: 'Odo_RF', state: widget.provider),
                  _buildNumericMetricBox(cellLabel: 'L/R (mm)', dataKey: 'Odo_LR', state: widget.provider),
                  _buildNumericMetricBox(cellLabel: 'R/R (mm)', dataKey: 'Odo_RR', state: widget.provider),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}