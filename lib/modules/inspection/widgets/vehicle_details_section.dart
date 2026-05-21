import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class VehicleDetailsSection extends StatelessWidget {
  const VehicleDetailsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Vehicle Information',

            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Capture vehicle identification details.',

            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),

          const SizedBox(height: 40),

          /// ROW 1
          Row(
            children: [
              Expanded(
                child: InspectionTextField(label: 'Registration Number'),
              ),

              const SizedBox(width: 20),

              Expanded(child: InspectionTextField(label: 'VIN Number')),
            ],
          ),

          const SizedBox(height: 24),

          /// ROW 2
          Row(
            children: [
              Expanded(child: InspectionTextField(label: 'Make')),

              const SizedBox(width: 20),

              Expanded(child: InspectionTextField(label: 'Model')),
            ],
          ),

          const SizedBox(height: 24),

          /// ROW 3
          Row(
            children: [
              Expanded(child: InspectionTextField(label: 'Year Model')),

              const SizedBox(width: 20),

              Expanded(child: InspectionTextField(label: 'Mileage')),
            ],
          ),

          const SizedBox(height: 24),

          /// ROW 4
          Row(
            children: [
              Expanded(child: InspectionTextField(label: 'Fuel Type')),

              const SizedBox(width: 20),

              Expanded(child: InspectionTextField(label: 'Transmission')),
            ],
          ),

          const SizedBox(height: 24),

          /// ROW 5
          Row(
            children: [
              Expanded(child: InspectionTextField(label: 'Colour')),

              const SizedBox(width: 20),

              Expanded(child: InspectionTextField(label: 'Inspector Name')),
            ],
          ),

          const SizedBox(height: 24),

          InspectionTextField(label: 'Client Name'),
        ],
      ),
    );
  }
}

class InspectionTextField extends StatelessWidget {
  final String label;

  const InspectionTextField({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          label,

          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),

        const SizedBox(height: 10),

        TextField(
          style: const TextStyle(color: AppColors.textPrimary),

          decoration: InputDecoration(
            filled: true,

            fillColor: AppColors.background,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),

              borderSide: BorderSide(color: AppColors.gold.withOpacity(0.3)),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),

              borderSide: BorderSide(color: AppColors.gold.withOpacity(0.3)),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),

              borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
