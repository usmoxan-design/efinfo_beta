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
    // Determine background color based on shrinkOffset if transition needed,
    // but a solid color ensures content behind is hidden.
    return Container(
      color: const Color(0xFF011A0B), // Matches AppColors.background
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            // Matches the dark container style
            color: const Color(0xFF0D2418),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white12),
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF06DF5D)
              : Colors.transparent, // Green accent
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 70.0;

  @override
  double get minExtent => 70.0;

  @override
  bool shouldRebuild(covariant LevelToggleHeaderDelegate oldDelegate) {
    return oldDelegate.isMaxLevel != isMaxLevel;
  }
}
