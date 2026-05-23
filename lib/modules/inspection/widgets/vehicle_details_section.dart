import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../providers/inspection_provider.dart';
import '../screens/license_scanner_screen.dart';

class VehicleDetailsSection extends StatefulWidget {
  final ActiveInspectionProvider provider;
  const VehicleDetailsSection({super.key, required this.provider});

  @override
  State<VehicleDetailsSection> createState() => _VehicleDetailsSectionState();
}

class _VehicleDetailsSectionState extends State<VehicleDetailsSection> {
  final List<String> _fuelTypes = ['Petrol', 'Diesel', 'Hybrid', 'Electric'];
  final List<String> _transmissionTypes = ['Manual', 'Automatic'];

  @override
  void initState() {
    super.initState();
    if (widget.provider.vehicleDetails['Inspector Name'] == null || 
        widget.provider.vehicleDetails['Inspector Name']!.isEmpty) {
      widget.provider.vehicleDetails['Inspector Name'] = 'Jean-Pierre';
    }
  }

  void _navigateToScanner() async {
    final Map<String, String>? scannedData = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LicenseScannerScreen()),
    );

    if (scannedData != null) {
      setState(() {
        scannedData.forEach((key, value) {
          if (value.isNotEmpty) {
            widget.provider.vehicleDetails[key] = value;
            // Activate lock constraints across automated inputs immediately
            if (widget.provider.scannedFieldsRegistry.containsKey(key)) {
              widget.provider.scannedFieldsRegistry[key] = true;
            }
          }
        });
        widget.provider.recalculateDynamicComponentBudgets();
      });
    }
  }

  Widget _buildResponsiveInputField({
    required String label,
    required String value,
    required String keyName,
    required ValueChanged<String> onChanged,
    String? suffixTag,
  }) {
    // Check if configuration maps declare this specific slot lock immutable
    bool isLocked = widget.provider.scannedFieldsRegistry[keyName] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
            if (isLocked) ...[
              const SizedBox(width: 6),
              const Icon(Icons.lock_outline, color: AppColors.gold, size: 12),
            ]
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          key: ValueKey('$keyName-$value'), 
          onChanged: onChanged,
          readOnly: isLocked, // 🚀 LOCK INPUT MODE ACTIVATED
          style: TextStyle(
            color: isLocked ? AppColors.textPrimary.withOpacity(0.6) : AppColors.textPrimary, 
            fontSize: 16,
            fontWeight: isLocked ? FontWeight.bold : FontWeight.normal
          ),
          decoration: InputDecoration(
            fillColor: isLocked ? AppColors.background.withOpacity(0.4) : AppColors.background,
            filled: true,
            suffixIcon: suffixTag != null 
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    child: Text(suffixTag, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), 
              borderSide: BorderSide(color: isLocked ? AppColors.gold.withOpacity(0.4) : AppColors.gold, width: 0.5)
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), 
              borderSide: const BorderSide(color: AppColors.gold, width: 1.5)
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomDropdownField({
    required String label,
    required String currentValue,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: options.contains(currentValue) ? currentValue : null,
          onChanged: onChanged,
          dropdownColor: AppColors.panel,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.gold),
          decoration: InputDecoration(
            fillColor: AppColors.background,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.gold, width: 0.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.gold, width: 1.5)),
          ),
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(color: AppColors.textPrimary)),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> data = widget.provider.vehicleDetails;

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobileWidth = constraints.maxWidth < 650;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SCANNING TRIGGER BLOCK ACTION ROW BANNER BOUNDS
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 0.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.qr_code_scanner, color: AppColors.gold, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Automated Telemetry Capture', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('Align the system camera frame on the official MVLX license disk barcode.', style: TextStyle(color: AppColors.textSecondary, fontSize: isMobileWidth ? 11 : 13)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _navigateToScanner,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.background,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('SCAN DISC', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isMobileWidth ? 1 : 2,
              childAspectRatio: isMobileWidth ? 4.2 : 3.4,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              children: [
                _buildResponsiveInputField(
                  label: 'Registration Number',
                  value: data['Registration Number'] ?? '',
                  keyName: 'Registration Number',
                  onChanged: (v) => widget.provider.vehicleDetails['Registration Number'] = v,
                ),
                _buildResponsiveInputField(
                  label: 'VIN Number',
                  value: data['VIN Number'] ?? '',
                  keyName: 'VIN Number',
                  onChanged: (v) => widget.provider.vehicleDetails['VIN Number'] = v,
                ),
                _buildResponsiveInputField(
                  label: 'Make',
                  value: data['Make'] ?? '',
                  keyName: 'Make',
                  onChanged: (v) => widget.provider.vehicleDetails['Make'] = v,
                ),
                _buildResponsiveInputField(
                  label: 'Model / Variant Description',
                  value: data['Model'] ?? '',
                  keyName: 'Model',
                  onChanged: (v) => widget.provider.vehicleDetails['Model'] = v,
                ),
                _buildResponsiveInputField(
                  label: 'Year Model',
                  value: data['Year Model'] ?? '',
                  keyName: 'Year Model',
                  onChanged: (v) => widget.provider.vehicleDetails['Year Model'] = v,
                ),
                _buildResponsiveInputField(
                  label: 'Mileage (Odometer)',
                  value: data['Mileage'] ?? '',
                  keyName: 'Mileage',
                  suffixTag: 'KM', // 🚀 ADDED SFIX METRIC STICKER TAG NATIVELY
                  onChanged: (v) => widget.provider.vehicleDetails['Mileage'] = v,
                ),
                _buildCustomDropdownField(
                  label: 'Fuel Type',
                  currentValue: data['Fuel Type'] ?? '',
                  options: _fuelTypes,
                  onChanged: (v) => widget.provider.vehicleDetails['Fuel Type'] = v ?? '',
                ),
                _buildCustomDropdownField(
                  label: 'Transmission',
                  currentValue: data['Transmission'] ?? '',
                  options: _transmissionTypes,
                  onChanged: (v) => widget.provider.vehicleDetails['Transmission'] = v ?? '',
                ),
                _buildResponsiveInputField(
                  label: 'Colour Attribute',
                  value: data['Colour'] ?? '',
                  keyName: 'Colour',
                  onChanged: (v) => widget.provider.vehicleDetails['Colour'] = v,
                ),
                _buildResponsiveInputField(
                  label: 'Inspector Session Profile Name',
                  value: data['Inspector Name'] ?? '',
                  keyName: 'Inspector Name',
                  onChanged: (v) => widget.provider.vehicleDetails['Inspector Name'] = v,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}