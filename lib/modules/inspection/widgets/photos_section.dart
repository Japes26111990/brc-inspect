import 'dart:io';
import 'package:flutter/foundation.dart';
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

  final List<Map<String, String>> _photoManifest = [
    {'id': 'front', 'label': 'Vehicle Front Profile (45° View)'},
    {'id': 'rear', 'label': 'Vehicle Rear Profile (45° View)'},
    {'id': 'engine', 'label': 'Open Engine Compartment Grid'},
    {'id': 'dash', 'label': 'Instrument Odometer Running Profile'},
  ];

  void _captureGlobalAspectPhoto(Map<String, String> entry) async {
    final XFile? file = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (file == null) return;

    setState(() {
      entry['path'] = file.path;
    });

    widget.provider.vehicleDetails[entry['id']!] = file.path;
    widget.provider.notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _photoManifest.map((entry) {
        bool hasPhoto = entry.containsKey('path') && entry['path'] != null;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.background.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Expanded(
                child: Text(entry['label']!, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
              ),
              if (hasPhoto) ...[
                // 🚀 FIXED: Dynamic platform configuration blocks web image file execution crashes instantly
                if (!kIsWeb)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(File(entry['path']!), width: 75, height: 55, fit: BoxFit.cover),
                  )
                else
                  Container(
                    width: 75, height: 55,
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  ),
                const SizedBox(width: 12),
              ],
              IconButton(
                icon: Icon(hasPhoto ? Icons.cached : Icons.camera_alt, color: AppColors.gold),
                onPressed: () => _captureGlobalAspectPhoto(entry),
              )
            ],
          ),
        );
      }).toList(),
    );
  }
}