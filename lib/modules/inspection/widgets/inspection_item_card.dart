import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class InspectionItemCard extends StatefulWidget {
  final String title;

  const InspectionItemCard({super.key, required this.title});

  @override
  State<InspectionItemCard> createState() => _InspectionItemCardState();
}

class _InspectionItemCardState extends State<InspectionItemCard> {
  String selectedStatus = 'PASS';

  final TextEditingController notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),

      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color: AppColors.card,

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: AppColors.gold.withOpacity(0.25)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          /// TITLE
          Text(
            widget.title,

            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          /// STATUS BUTTONS
          Row(
            children: [
              Expanded(
                child: StatusButton(
                  title: 'PASS',
                  selected: selectedStatus == 'PASS',

                  onTap: () {
                    setState(() {
                      selectedStatus = 'PASS';
                    });
                  },
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: StatusButton(
                  title: 'ATTENTION',
                  selected: selectedStatus == 'ATTENTION',

                  onTap: () {
                    setState(() {
                      selectedStatus = 'ATTENTION';
                    });
                  },
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: StatusButton(
                  title: 'FAIL',
                  selected: selectedStatus == 'FAIL',

                  onTap: () {
                    setState(() {
                      selectedStatus = 'FAIL';
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          /// NOTES
          TextField(
            controller: notesController,

            maxLines: 3,

            style: const TextStyle(color: AppColors.textPrimary),

            decoration: InputDecoration(
              hintText: 'Inspector notes...',

              hintStyle: const TextStyle(color: AppColors.textSecondary),

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

          const SizedBox(height: 24),

          /// ACTION ROW
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {},

                icon: const Icon(Icons.camera_alt_outlined),

                label: const Text('Add Photo'),
              ),

              const SizedBox(width: 20),

              OutlinedButton.icon(
                onPressed: () {},

                icon: const Icon(Icons.warning_amber_outlined),

                label: const Text('Roadworthy Relevant'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatusButton extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const StatusButton({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),

      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),

        decoration: BoxDecoration(
          color: selected ? AppColors.gold : AppColors.background,

          borderRadius: BorderRadius.circular(14),

          border: Border.all(color: AppColors.gold),
        ),

        alignment: Alignment.center,

        child: Text(
          title,

          style: TextStyle(
            color: selected ? Colors.black : AppColors.gold,

            fontWeight: FontWeight.bold,

            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
