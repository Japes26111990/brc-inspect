import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../providers/inspection_provider.dart';

class VehicleDetailsSection extends StatelessWidget {
  final ActiveInspectionProvider provider;

  const VehicleDetailsSection({super.key, required this.provider});

  Widget _buildField(String label, String key, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: provider.vehicleDetails[key] ?? '',
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: const TextStyle(color: AppColors.textPrimary),
            onChanged: (val) {
              provider.vehicleDetails[key] = val;
              provider.notifyListeners();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vehicle & Examiner Details',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildField(
                  'Vehicle Registration No.',
                  'Vehicle Registration No',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildField(
                  'VIN / Chassis Number',
                  'Vehicle VIN Chassis Number',
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(child: _buildField('Vehicle Make', 'Vehicle Make')),
              const SizedBox(width: 16),
              Expanded(child: _buildField('Vehicle Model', 'Vehicle Model')),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _buildField('Engine Number', 'Vehicle Engine Number'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildField(
                  'Odometer Reading',
                  'Odometer Reading',
                  isNumber: true,
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            children: [
              Expanded(child: _buildField('Examiner Name', 'Examiner Name')),
              const SizedBox(width: 16),
              Expanded(
                child: _buildField('Examiner Number', 'Examiner Number'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
