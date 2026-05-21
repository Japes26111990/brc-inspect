import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class PhotosSection extends StatelessWidget {
  const PhotosSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 80),

          Icon(Icons.camera_alt_outlined, size: 100, color: AppColors.gold),

          const SizedBox(height: 30),

          const Text(
            'Vehicle Photos',

            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Photo upload system coming next.',

            style: TextStyle(color: AppColors.textSecondary, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
