import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isLarge;

  const StatusBadge({
    super.key,
    required this.status,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.getStatusBg(status);
    final fg = AppColors.getStatusFg(status);
    final label = AppColors.getStatusLabel(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 16 : 10,
        vertical: isLarge ? 8 : 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(isLarge ? 20 : 6),
        border: Border.all(color: fg.withOpacity(0.3), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: isLarge ? 13 : 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
