import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:flutter/material.dart';

class BoosterRecommendationPage extends StatelessWidget {
  const BoosterRecommendationPage({super.key});

  final List<Map<String, dynamic>> recommendations = const [
    {
      "playstyle": "Goal Poacher (Hujumchi)",
      "boosters": ["Striker's Instinct", "Fantasista", "Shooting"]
    },
    {
      "playstyle": "Dummy Runner (Aldamchi Yuguruvchi)",
      "boosters": ["Striker's Instinct", "Fantasista", "Technique"]
    },
    {
      "playstyle": "Fox in the Box (Jarima Maydoni Tulki)",
      "boosters": ["Striker's Instinct", "Shooting", "Fantasista"]
    },
    {
      "playstyle": "Target Man (Nishon O'yinchi)",
      "boosters": ["Aerial", "Shooting", "Striker's Instinct"]
    },
    {
      "playstyle": "Deep-lying Forward (Chuqur Hujumchi)",
      "boosters": ["Technique", "Fantasista", "Ball Carrying"]
    },
    {
      "playstyle": "Creative Playmaker (Ijodkor O'yinchi)",
      "boosters": ["Technique", "Ball Carrying", "Fantasista"]
    },
    {
      "playstyle": "Hole Player (Bo'shliq O'yinchisi)",
      "boosters": ["Fantasista", "Technique", "Ball Carrying"]
    },
    {
      "playstyle": "Classic No. 10",
      "boosters": ["Technique", "Ball Carrying", "Fantasista"]
    },
    {
      "playstyle": "Prolific Winger (Samarali Qanot)",
      "boosters": ["Ball Carrying", "Technique", "Fantasista"]
    },
    {
      "playstyle": "Roaming Flank (Erkin Qanot)",
      "boosters": ["Ball Carrying", "Technique", "Fantasista"]
    },
    {
      "playstyle": "Cross Specialist (Kross Ustasi)",
      "boosters": ["Crossing", "Ball Carrying", "Agility"]
    },
    {
      "playstyle": "Box to Box (Maydon bo'ylab)",
      "boosters": ["Agility", "Hard Worker", "Duelling"]
    },
    {
      "playstyle": "Anchor Man (Tayanch Yarim Himoyachi)",
      "boosters": ["Shutdown", "Duelling", "Defending"]
    },
    {
      "playstyle": "Orchestrator - Attacking (Dirijyor)",
      "boosters": ["Agility", "Technique", "Ball Carrying"]
    },
    {
      "playstyle": "Orchestrator - Defensive (Dirijyor)",
      "boosters": ["Hard Worker", "Agility", "Duelling"]
    },
    {
      "playstyle": "Destroyer (Buzg'unchi)",
      "boosters": ["Shutdown", "Defending", "Duelling"]
    },
    {
      "playstyle": "Build Up (Hujum Boshlovchi)",
      "boosters": ["Defending", "Shutdown", "Duelling"]
    },
    {
      "playstyle": "Extra Frontman (Qo'shimcha Hujumchi)",
      "boosters": ["Shutdown", "Defending", "Duelling"]
    },
    {
      "playstyle": "Offensive Full-back (Hujumkor Qanot)",
      "boosters": ["Hard Worker", "Agility", "Crossing"]
    },
    {
      "playstyle": "Defensive Full-back (Himoyaviy Qanot)",
      "boosters": ["Shutdown", "Defending", "Duelling"]
    },
    {
      "playstyle": "Full-back Finisher (Yakunlovchi Qanot)",
      "boosters": ["Agility", "Hard Worker", "Duelling"]
    },
    {
      "playstyle": "Offensive Goalkeeper (Hujumkor GK)",
      "boosters": ["Saving", "Goalkeeping"]
    },
    {
      "playstyle": "Defensive Goalkeeper (Himoyaviy GK)",
      "boosters": ["Saving", "Goalkeeping"]
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Booster Tavsiyalari",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: recommendations.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = recommendations[index];
          List<String> boosters = item['boosters'];

          return Container(
            decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ]),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.flash_on,
                          color: AppColors.accent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item['playstyle'],
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildBoosterChip(boosters[0], 1)),
                    if (boosters.length > 1) ...[
                      const SizedBox(width: 8),
                      Expanded(child: _buildBoosterChip(boosters[1], 2)),
                    ],
                    if (boosters.length > 2) ...[
                      const SizedBox(width: 8),
                      Expanded(child: _buildBoosterChip(boosters[2], 3)),
                    ]
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBoosterChip(String label, int rank) {
    Color rankColor;
    Color bgColor;
    String rankLabel;

    if (rank == 1) {
      rankColor = const Color(0xFFFFD700); // Gold
      bgColor = const Color(0xFFFFD700).withOpacity(0.15);
      rankLabel = "1st Choice";
    } else if (rank == 2) {
      rankColor = const Color(0xFFC0C0C0); // Silver
      bgColor = const Color(0xFFC0C0C0).withOpacity(0.15);
      rankLabel = "2nd";
    } else {
      rankColor = const Color(0xFFCD7F32); // Bronze
      bgColor = const Color(0xFFCD7F32).withOpacity(0.15);
      rankLabel = "3rd";
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: rankColor.withOpacity(0.3))),
      child: Column(
        children: [
          Text(
            rankLabel,
            style: TextStyle(
                color: rankColor,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
