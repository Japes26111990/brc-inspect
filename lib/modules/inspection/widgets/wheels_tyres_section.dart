import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../theme/app_colors.dart';
import '../providers/inspection_provider.dart';
import '../models/inspection_models.dart';

class WheelsTyresSection extends StatelessWidget {
  final ActiveInspectionProvider provider;

  const WheelsTyresSection({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: provider.tyres.map((tyre) {
        return TyreItemCard(
          tyre: tyre,
          provider: provider,
        );
      }).toList(),
    );
  }
}

class TyreItemCard extends StatefulWidget {
  final TyreResult tyre;
  final ActiveInspectionProvider provider;

  const TyreItemCard({super.key, required this.tyre, required this.provider});

  @override
  State<TyreItemCard> createState() => _TyreItemCardState();
}

class _TyreItemCardState extends State<TyreItemCard> {
  final ImagePicker _picker = ImagePicker();
  bool _isAssessed = false;

  @override
  void initState() {
    super.initState();
    if (widget.tyre.status != ItemStatus.pending || widget.tyre.make.isNotEmpty) {
      _isAssessed = true;
    }
  }

  Future<void> _startCaptureWorkflow() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (photo == null) return; 

    setState(() {
      _isAssessed = true;
      widget.tyre.evaluateRoadworthyLimit();
      widget.provider.notifyListeners();
    });
  }

  void _updateTyre() {
    setState(() {
      widget.tyre.evaluateRoadworthyLimit();
      widget.provider.notifyListeners();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getBorderColor(widget.tyre.status), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.tyre.position,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              if (_isAssessed) _buildStatusBadge(widget.tyre.status),
            ],
          ),
          const SizedBox(height: 24),
          
          if (!_isAssessed)
            // THE LOCKOUT: Forced Visual Compliance
            InkWell(
              onTap: _startCaptureWorkflow,
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
                    Text('CAPTURE TYRE CONDITION', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            )
          else
            // THE UNLOCKED CONTROL PANEL: High-Density Layout
            Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildSmallField('Make (e.g., Goodyear)', widget.tyre.make, (val) => widget.tyre.make = val)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildSmallField('Model (e.g., EfficientGrip)', widget.tyre.tyreModel, (val) => widget.tyre.tyreModel = val)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildSmallField('Size (e.g., 205/55R16)', widget.tyre.size, (val) => widget.tyre.size = val)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildSmallField('Load/Speed (e.g., 91W)', widget.tyre.loadSpeedIndex, (val) => widget.tyre.loadSpeedIndex = val)),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(
                      flex: 2,
                      child: Text('Tread Depth (mm) - 0mm is an instant failure:', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                    ),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        initialValue: widget.tyre.treadDepthMm.toString(),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (val) {
                          widget.tyre.treadDepthMm = int.tryParse(val) ?? 0;
                          _updateTyre();
                        },
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSmallField(String label, String initial, Function(String) onChanged) {
    return TextFormField(
      initialValue: initial,
      onChanged: (val) {
        onChanged(val);
        _updateTyre();
      },
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
    );
  }

  Color _getBorderColor(ItemStatus status) {
    if (!_isAssessed) return AppColors.border;
    if (status == ItemStatus.fail) return AppColors.danger;
    if (status == ItemStatus.attention) return AppColors.warning;
    if (status == ItemStatus.pending) return AppColors.gold; 
    return AppColors.success;
  }

  Widget _buildStatusBadge(ItemStatus status) {
    String text = 'PASS';
    Color color = AppColors.success;

    if (status == ItemStatus.pending) {
      text = 'INCOMPLETE DATA';
      color = AppColors.gold;
    } else if (status == ItemStatus.attention) {
      text = 'ATTN (1mm)';
      color = AppColors.warning;
    } else if (status == ItemStatus.fail) {
      text = 'FAIL (0mm)';
      color = AppColors.danger;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}