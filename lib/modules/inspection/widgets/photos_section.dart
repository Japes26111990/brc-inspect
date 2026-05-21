import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../theme/app_colors.dart';
import '../providers/inspection_provider.dart';

class PhotosSection extends StatefulWidget {
  final ActiveInspectionProvider provider;

  const PhotosSection({super.key, required this.provider});

  @override
  State<PhotosSection> createState() => _PhotosSectionState();
}

class _PhotosSectionState extends State<PhotosSection> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePhoto(Map<String, dynamic> photoData) async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (photo != null) {
      setState(() {
        photoData['path'] = photo.path;
        photoData['hasDamage'] = null; // Reset damage check when a new photo is taken
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.provider.vehicle360Photos.map((photoData) {
        bool hasPhoto = photoData['path'] != null;
        bool? hasDamage = photoData['hasDamage'];

        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: hasPhoto ? AppColors.success.withValues(alpha: 0.5) : AppColors.border, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(photoData['label'], style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              if (!hasPhoto)
                // STEP 1: CAPTURE BUTTON
                InkWell(
                  onTap: () => _takePhoto(photoData),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.gold, width: 1.5),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.camera_alt, color: AppColors.gold, size: 32),
                        SizedBox(height: 8),
                        Text('CAPTURE PHOTO', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                )
              else ...[
                // STEP 2: PHOTO TAKEN, ASK ABOUT DAMAGES
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.success),
                    const SizedBox(width: 8),
                    const Text('Photo Captured', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () => _takePhoto(photoData), // Retake option
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Retake'),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(color: AppColors.border),
                ),
                const Text('Are there any visible damages in this view?', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
                const SizedBox(height: 16),
                
                // YES / NO BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() {
                          photoData['hasDamage'] = false;
                          photoData['notes'] = ''; // Clear notes if no damage
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: hasDamage == false ? AppColors.success : AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: hasDamage == false ? AppColors.success : AppColors.border),
                          ),
                          alignment: Alignment.center,
                          child: Text('NO DAMAGE', style: TextStyle(color: hasDamage == false ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => photoData['hasDamage'] = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: hasDamage == true ? AppColors.danger : AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: hasDamage == true ? AppColors.danger : AppColors.border),
                          ),
                          alignment: Alignment.center,
                          child: Text('YES, HAS DAMAGE', style: TextStyle(color: hasDamage == true ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),

                // STEP 3: COMMENT BOX IF YES
                if (hasDamage == true) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: photoData['notes'],
                    onChanged: (val) => photoData['notes'] = val,
                    style: const TextStyle(color: AppColors.textPrimary),
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Required: Describe the damages...',
                      hintStyle: const TextStyle(color: AppColors.danger),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  )
                ]
              ]
            ],
          ),
        );
      }).toList(),
    );
  }
}