import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:flutter/material.dart';

class LevelToggleHeaderDelegate extends SliverPersistentHeaderDelegate {
  final bool isMaxLevel;
  final Function(bool) onToggle;

  final Color backgroundColor;
  final Color surfaceColor;
  final Color borderColor;
  final Color textColor;
  final Color secondaryTextColor;

  LevelToggleHeaderDelegate({
    required this.isMaxLevel,
    required this.onToggle,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.borderColor,
    required this.textColor,
    required this.secondaryTextColor,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLevelChip('Level 1', !isMaxLevel, () => onToggle(false)),
              _buildLevelChip('Max Level', isMaxLevel, () => onToggle(true)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : secondaryTextColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 80.0;

  @override
  double get minExtent => 80.0;

  @override
  bool shouldRebuild(covariant LevelToggleHeaderDelegate oldDelegate) {
    return oldDelegate.isMaxLevel != isMaxLevel ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.surfaceColor != surfaceColor ||
        oldDelegate.borderColor != borderColor;
  }
}
