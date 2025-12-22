import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:flutter/material.dart';

class LevelToggleHeaderDelegate extends SliverPersistentHeaderDelegate {
  final bool isMaxLevel;
  final Function(bool) onToggle;

  LevelToggleHeaderDelegate({
    required this.isMaxLevel,
    required this.onToggle,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.border, width: 1),
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
            color: isSelected ? Colors.white : AppColors.textDim,
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
    return oldDelegate.isMaxLevel != isMaxLevel;
  }
}
