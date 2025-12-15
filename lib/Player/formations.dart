import 'package:efinfo_beta/Player/formations_details.dart';
import 'package:efinfo_beta/data/formationsdata.dart';
import 'package:flutter/material.dart';

import '../models/formationsmodel.dart';

// -----------------------------------------------------------------------------
// 4. UI SCREENS
// -----------------------------------------------------------------------------

class FormationsListScreen extends StatelessWidget {
  const FormationsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Formations")),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: allFormations.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final item = allFormations[index];
          return _buildFormationCard(context, item);
        },
      ),
    );
  }

  Widget _buildFormationCard(BuildContext context, Formation formation) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => FormationDetailScreen(formation: formation)),
      ),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(16), topRight: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            // Chap taraf: Mini Maydon preview
            SizedBox(
              width: 80,
              // decoration: const BoxDecoration(
              //   borderRadius:
              //       BorderRadius.horizontal(left: Radius.circular(16)),
              // ),
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
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formation.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        _buildDifficultyChip(formation.difficulty),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formation.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.chevron_right, color: Colors.white24),
            )
          ],
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
