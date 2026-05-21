import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../providers/inspection_provider.dart';
import '../screens/license_scanner_screen.dart'; // <--- Add this import

class VehicleDetailsSection extends StatelessWidget {
  final ActiveInspectionProvider provider;

  const VehicleDetailsSection({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vehicle Information', style: TextStyle(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text('Capture vehicle identification details.', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                ],
              ),
              
              // --- THE SCANNER BUTTON ---
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                icon: const Icon(Icons.qr_code_scanner, color: Colors.black),
                label: const Text('SCAN LICENSE DISK', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                onPressed: () async {
                  final scannedData = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LicenseScannerScreen()),
                  );

                  if (scannedData != null && scannedData is Map<String, String>) {
                    // Inject the scanned data directly into your provider!
                    scannedData.forEach((key, value) {
                      if (provider.vehicleDetails.containsKey(key)) {
                        provider.updateVehicleDetail(key, value);
                      }
                    });
                  }
                },
              )
            ],
          ),

          const SizedBox(height: 40),

          // ... (Keep the rest of your Row/Field layout exactly the same) ...
          Row(
            children: [
              Expanded(child: _buildField('Registration Number')),
              const SizedBox(width: 20),
              Expanded(child: _buildField('VIN Number')),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildField('Make')),
              const SizedBox(width: 20),
              Expanded(child: _buildField('Model')),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildField('Year Model')),
              const SizedBox(width: 20),
              Expanded(child: _buildField('Mileage')),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildField('Fuel Type')),
              const SizedBox(width: 20),
              Expanded(child: _buildField('Transmission')),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildField('Colour')),
              const SizedBox(width: 20),
              Expanded(child: _buildField('Inspector Name')),
            ],
          ),
          const SizedBox(height: 24),
          _buildField('Client Name'),
        ],
      ),
    );
  }

  Widget _buildField(String label) {
    // Note: We use a controller here instead of initialValue so it updates LIVE when scanned
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        const SizedBox(height: 10),
        TextFormField(
          key: Key(provider.vehicleDetails[label] ?? label), // Forces rebuild on scan
          initialValue: provider.vehicleDetails[label],
          onChanged: (value) => provider.updateVehicleDetail(label, value),
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}