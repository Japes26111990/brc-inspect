import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/app_colors.dart';
import '../providers/inspection_provider.dart';
import 'inspection_flow_screen.dart';

class InspectionTypeScreen extends StatelessWidget {
  const InspectionTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ActiveInspectionProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Select Inspection Type',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: SizedBox(
          width: 520,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InspectionTypeButton(
                title: 'Multipoint Check',
                subtitle: '40-point visual and safety check',
                icon: Icons.assignment_outlined,
                onTap: () {
                  // 🌟 PURGES PREVIOUS MANIFEST ARTIFACTS IN REAL-TIME
                  provider.resetInspection();
                  provider.setInspectionType(InspectionType.multipointCheck);

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => _ClientIntakeDialog(provider: provider),
                  );
                },
              ),
              const SizedBox(height: 22),
              InspectionTypeButton(
                title: 'Condition Report',
                subtitle: 'Detailed vehicle condition assessment',
                icon: Icons.verified_outlined,
                onTap: () {
                  provider.resetInspection();
                  provider.setInspectionType(InspectionType.conditionReport);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InspectionFlowScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 22),
              InspectionTypeButton(
                title: 'Full Technical Report',
                subtitle: 'Comprehensive technical inspection',
                icon: Icons.build_circle_outlined,
                onTap: () {
                  provider.resetInspection();
                  provider.setInspectionType(InspectionType.technicalReport);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InspectionFlowScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClientIntakeDialog extends StatefulWidget {
  final ActiveInspectionProvider provider;
  const _ClientIntakeDialog({required this.provider});

  @override
  State<_ClientIntakeDialog> createState() => _ClientIntakeDialogState();
}

class _ClientIntakeDialogState extends State<_ClientIntakeDialog> {
  int _step = 0;

  final _nameCtrl = TextEditingController();
  final _surnameCtrl = TextEditingController();
  final _cellCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  void _saveClientDetailsAndContinue() {
    final name = _nameCtrl.text.trim();
    final surname = _surnameCtrl.text.trim();
    final cell = _cellCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    // 🛑 VALIDATION BLOCK: Name and Surname must be entered
    if (name.isEmpty || surname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '⚠️ Both First Name and Surname fields are mandatory.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // 🛑 VALIDATION BLOCK: Enforce at least one contact method (Cell or Email)
    if (cell.isEmpty && email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '⚠️ Please provide a Cell Number or Email Address to proceed.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    String initial = name.isNotEmpty ? name[0].toUpperCase() : '';
    widget.provider.vehicleDetails['Client Name'] = name;
    widget.provider.vehicleDetails['Owner Surname & Initials'] =
        '$surname $initial'.trim();
    widget.provider.vehicleDetails['Client Cell'] = cell;
    widget.provider.vehicleDetails['Client Email'] = email;

    setState(() => _step = 1);
  }

  void _confirmCancel() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: AppColors.card,
            title: const Text(
              'Cancel Inspection?',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Are you sure you want to cancel? All entered details will be cleared.',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'NO, CONTINUE',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text('YES, CANCEL'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(32),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildCurrentStep(),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    if (_step == 0) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        key: const ValueKey(0),
        children: [
          const Text(
            'Client Details Authorization',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please enter your contact information to authorize this inspection.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: _buildInput(
                  'First Name',
                  Icons.person_outline,
                  _nameCtrl,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInput(
                  'Surname',
                  Icons.badge_outlined,
                  _surnameCtrl,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInput(
            'Cell Number',
            Icons.phone_android,
            _cellCtrl,
            isNumber: true,
          ),
          const SizedBox(height: 16),
          _buildInput('Email Address', Icons.email_outlined, _emailCtrl),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _saveClientDetailsAndContinue,
              child: const Text('APPROVE & CONTINUE'),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: _confirmCancel,
              child: const Text(
                'CANCEL',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    } else if (_step == 1) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        key: const ValueKey(1),
        children: [
          const Icon(
            Icons.screen_share_outlined,
            size: 80,
            color: AppColors.gold,
          ),
          const SizedBox(height: 24),
          const Text(
            'Thank You!',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Please hand the tablet back to the BRC technician to commence the vehicle inspection.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
          ),
          const SizedBox(height: 40),
          TextButton.icon(
            onPressed: () => setState(() => _step = 2),
            icon: const Icon(Icons.lock_open, color: AppColors.border),
            label: const Text(
              'Technician Unlock',
              style: TextStyle(color: AppColors.border),
            ),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        key: const ValueKey(2),
        children: [
          const Icon(
            Icons.admin_panel_settings,
            size: 60,
            color: AppColors.primary,
          ),
          const SizedBox(height: 20),
          const Text(
            'Technician Controls',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const InspectionFlowScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.qr_code_scanner, size: 28),
              label: const Text(
                'SCAN LICENSE DISC',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: _confirmCancel,
            child: const Text(
              'CANCEL INSPECTION',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildInput(
    String hint,
    IconData icon,
    TextEditingController ctrl, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.gold),
      ),
    );
  }
}

class InspectionTypeButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const InspectionTypeButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gold, width: 1),
          boxShadow: [
            BoxShadow(color: AppColors.gold.withOpacity(0.08), blurRadius: 16),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.gold, size: 42),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
