import 'package:efinfo_beta/Player/formations_details.dart';
import 'package:efinfo_beta/data/formationsdata.dart';
import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:efinfo_beta/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/formationsmodel.dart';

// -----------------------------------------------------------------------------
// 4. UI SCREENS
// -----------------------------------------------------------------------------

class FormationsListScreen extends StatelessWidget {
  const FormationsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: themeProvider.getTheme().scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Tactical Formations",
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: allFormations.length,
        itemBuilder: (context, index) {
          final item = allFormations[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildFormationCard(context, item, isDark),
          );
        },
      ),
    );
  }

  Widget _buildFormationCard(
      BuildContext context, Formation formation, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => FormationDetailScreen(formation: formation)),
      ),
      child: GlassContainer(
        padding: EdgeInsets.zero,
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left side: Mini Field Preview
              Container(
                width: 110,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF06DF5D).withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      bottomLeft: Radius.circular(24)),
                ),
                child: AspectRatio(
                  aspectRatio: 0.8,
                  child: CustomPaint(
                    painter: RealisticFieldPainter(
                        positions: formation.positions, playerRadius: 4.0),
                    child: Container(),
                  ),
                ),
              ),
              // Right side: Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              formation.name,
                              style: GoogleFonts.outfit(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          _buildDifficultyChip(formation.difficulty),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formation.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: 13,
                            height: 1.3),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.auto_awesome,
                              size: 14,
                              color: const Color(0xFF06DF5D).withOpacity(0.7)),
                          const SizedBox(width: 4),
                          Text(
                            "Batafsil ma'lumot",
                            style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: const Color(0xFF06DF5D),
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(Difficulty diff) {
    Color color;
    String text;
    switch (diff) {
      case Difficulty.easy:
        color = const Color(0xFF06DF5D);
        text = "Oson";
        break;
      case Difficulty.medium:
        color = Colors.orangeAccent;
        text = "O'rta";
        break;
      case Difficulty.hard:
        color = Colors.redAccent;
        text = "Qiyin";
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5),
      ),
    );
  }
}
