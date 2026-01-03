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
          "Formations",
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: allFormations.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final item = allFormations[index];
          return _buildFormationCard(context, item, isDark);
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
              // Chap taraf: Mini Maydon preview
              Container(
                width: 100,
                decoration: BoxDecoration(
                  color: (isDark ? Colors.green[900] : Colors.green[700])
                      ?.withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20)),
                ),
                child: CustomPaint(
                  painter: RealisticFieldPainter(
                      positions: formation.positions, playerRadius: 3.5),
                  child: Container(),
                ),
              ),
              // O'ng taraf: Ma'lumot
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            color: isDark ? Colors.white54 : Colors.black54,
                            fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(Icons.chevron_right,
                    color: isDark ? Colors.white24 : Colors.black26),
              )
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
        color = Colors.greenAccent;
        text = "Easy";
        break;
      case Difficulty.medium:
        color = Colors.orangeAccent;
        text = "Mid";
        break;
      case Difficulty.hard:
        color = Colors.redAccent;
        text = "Hard";
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5), width: 0.5),
      ),
      child: Text(
        text,
        style:
            TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
