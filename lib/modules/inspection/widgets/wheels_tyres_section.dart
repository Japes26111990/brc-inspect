import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../theme/app_colors.dart';
import '../models/inspection_models.dart';
import '../providers/inspection_provider.dart';

class WheelsTyresSection extends StatefulWidget {
  final ActiveInspectionProvider provider;
  const WheelsTyresSection({super.key, required this.provider});

  @override
  State<WheelsTyresSection> createState() => _WheelsTyresSectionState();
}

class _WheelsTyresSectionState extends State<WheelsTyresSection> {
  final ImagePicker _imagePicker = ImagePicker();

  final List<String> _tyreMakes = ['Select Brand', 'Goodyear', 'Continental', 'Michelin', 'Bridgestone', 'Pirelli', 'Dunlop'];
  final List<String> _widths = ['Select Width', '185', '195', '205', '215', '225', '245'];
  final List<String> _profiles = ['Select Prof', '45', '50', '55', '60', '65', '70'];
  final List<String> _rimSizes = ['Select Rim', 'R15', 'R16', 'R17', 'R18', 'R19', 'R20'];
  final List<String> _speedRatings = ['Select Speed', 'H', 'T', 'V', 'W', 'Y'];

  void _captureTyreTreadPhoto(TyreResult tyre) async {
    final XFile? file = await _imagePicker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (file == null) return;
    setState(() => tyre.photoPath = file.path);
    widget.provider.notifyListeners();
  }

  Widget _buildCompactDropdown({
    required String label,
    required String currentVal,
    required List<String> itemsList,
    required ValueChanged<String?> onChanged,
  }) {
    final String safeValue = itemsList.contains(currentVal) && currentVal.isNotEmpty ? currentVal : itemsList.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
        const SizedBox(height: 3),
        SizedBox(
          height: 30,
          child: DropdownButtonFormField<String>(
            value: safeValue,
            dropdownColor: AppColors.panel,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              fillColor: AppColors.background,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.gold, width: 0.5)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.gold, width: 1)),
            ),
            // 🚀 FIXED: Appended .toList() explicitly onto the end of your map operation to satisfy type parameters
            items: itemsList.map((val) => DropdownMenuItem<String>(
              value: val, 
              child: Text(
                val, 
                style: TextStyle(color: val.contains('Select') ? AppColors.textSecondary : AppColors.textPrimary)
              )
            )).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.provider.tyres.map((tyre) {
        bool expectsTreadPhoto = tyre.position != 'Spare Tyre'; 

        // Extract internal component state strings
        String currentWidth = tyre.size.contains('/') ? tyre.size.split('/')[0] : '';
        String remainder = tyre.size.contains('/') ? tyre.size.split('/')[1] : '';
        String currentProfile = remainder.contains('R') ? remainder.split('R')[0] : remainder;
        String currentRim = remainder.contains('R') ? 'R' + remainder.split('R')[1] : '';

        // 🚀 LIVE VERIFICATION CHECK: Evaluate if this row is 100% completed
        bool specsFilled = tyre.make.isNotEmpty && 
                            !tyre.make.contains('Select') &&
                            currentWidth.isNotEmpty && 
                            !currentWidth.contains('Select') &&
                            currentProfile.isNotEmpty && 
                            !currentProfile.contains('Select') &&
                            currentRim.isNotEmpty && 
                            !currentRim.contains('Select') &&
                            tyre.loadSpeedIndex.isNotEmpty && 
                            !tyre.loadSpeedIndex.contains('Select') &&
                            tyre.treadDepthMm != -1;

        bool isCardFullyComplete = expectsTreadPhoto ? (specsFilled && tyre.photoPath != null) : specsFilled;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.panel,
            borderRadius: BorderRadius.circular(12),
            // 🚀 SMART GREEN HIGHLIGHTING INDICATION: Swaps borders instantly when done
            border: Border.all(
              color: isCardFullyComplete 
                  ? Colors.green.withOpacity(0.8) 
                  : (tyre.status == ItemStatus.fail ? Colors.red.withOpacity(0.4) : AppColors.gold.withOpacity(0.15)),
              width: isCardFullyComplete ? 2 : 1
            ),
            boxShadow: isCardFullyComplete ? [
              BoxShadow(color: Colors.green.withOpacity(0.06), blurRadius: 4, spreadRadius: 1)
            ] : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(tyre.position.toUpperCase(), style: TextStyle(color: isCardFullyComplete ? Colors.green : AppColors.gold, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5)),
                      if (isCardFullyComplete) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.check_circle, color: Colors.green, size: 14),
                      ]
                    ],
                  ),
                  if (tyre.treadDepthMm != -1)
                    Text(
                      '${tyre.treadDepthMm} mm • ${tyre.status.name.toUpperCase()}', 
                      style: TextStyle(color: tyre.status == ItemStatus.fail ? Colors.red : (tyre.status == ItemStatus.attention ? Colors.amber : Colors.green), fontWeight: FontWeight.bold, fontSize: 11)
                    ),
                ],
              ),
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tread Depth', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                        const SizedBox(height: 3),
                        SizedBox(
                          height: 30,
                          child: DropdownButtonFormField<int>(
                            value: tyre.treadDepthMm == -1 ? null : tyre.treadDepthMm,
                            hint: const Text('Select', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                            dropdownColor: AppColors.panel,
                            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12),
                            decoration: InputDecoration(
                              fillColor: AppColors.background,
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.gold, width: 0.5)),
                            ),
                            items: List.generate(9, (i) => i).map((mm) {
                              return DropdownMenuItem<int>(value: mm, child: Text('$mm mm'));
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                if (val != null) {
                                  tyre.treadDepthMm = val;
                                  tyre.evaluateRoadworthyLimit();
                                }
                              });
                              widget.provider.notifyListeners();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    flex: 3,
                    child: _buildCompactDropdown(
                      label: 'Brand / Make',
                      currentVal: tyre.make,
                      itemsList: _tyreMakes,
                      onChanged: (v) {
                        setState(() => tyre.make = (v == _tyreMakes.first) ? '' : (v ?? ''));
                        widget.provider.notifyListeners();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              
              Row(
                children: [
                  Expanded(
                    child: _buildCompactDropdown(
                      label: 'Width',
                      currentVal: currentWidth,
                      itemsList: _widths,
                      onChanged: (v) {
                        String w = (v == _widths.first) ? '' : (v ?? '205');
                        setState(() => tyre.size = '$w/$currentProfile$currentRim');
                        widget.provider.notifyListeners();
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _buildCompactDropdown(
                      label: 'Profile',
                      currentVal: currentProfile,
                      itemsList: _profiles,
                      onChanged: (v) {
                        String p = (v == _profiles.first) ? '' : (v ?? '55');
                        setState(() => tyre.size = '$currentWidth/$p$currentRim');
                        widget.provider.notifyListeners();
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _buildCompactDropdown(
                      label: 'Rim',
                      currentVal: currentRim,
                      itemsList: _rimSizes,
                      onChanged: (v) {
                        String r = (v == _rimSizes.first) ? '' : (v ?? 'R16');
                        setState(() => tyre.size = '$currentWidth/$currentProfile$r');
                        widget.provider.notifyListeners();
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _buildCompactDropdown(
                      label: 'Speed',
                      currentVal: tyre.loadSpeedIndex,
                      itemsList: _speedRatings,
                      onChanged: (v) {
                        setState(() => tyre.loadSpeedIndex = (v == _speedRatings.first) ? '' : (v ?? 'V'));
                        widget.provider.notifyListeners();
                      },
                    ),
                  ),
                ],
              ),

              if (expectsTreadPhoto) ...[
                const SizedBox(height: 6),
                const Divider(color: AppColors.background, thickness: 0.5, height: 10),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(tyre.photoPath == null ? Icons.camera_alt : Icons.check_circle, color: tyre.photoPath == null ? AppColors.gold : Colors.green, size: 18),
                      onPressed: () => _captureTyreTreadPhoto(tyre),
                    ),
                    Expanded(
                      child: Text(
                        'Take tread snap for proof verification.',
                        style: TextStyle(color: tyre.photoPath == null ? AppColors.gold : Colors.green, fontSize: 11, fontStyle: FontStyle.italic),
                      ),
                    ),
                    if (tyre.photoPath != null && !kIsWeb)
                      ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.file(File(tyre.photoPath!), width: 40, height: 30, fit: BoxFit.cover)),
                    if (tyre.photoPath != null && kIsWeb)
                      const Icon(Icons.cloud_done, color: Colors.green, size: 16),
                  ],
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}