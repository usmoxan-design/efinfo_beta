import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:efinfo_beta/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class BoosterRecommendationPage extends StatefulWidget {
  const BoosterRecommendationPage({super.key});

  @override
  State<BoosterRecommendationPage> createState() =>
      _BoosterRecommendationPageState();
}

class _BoosterRecommendationPageState extends State<BoosterRecommendationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> boosterData = const [
    {
      "name": "Shooting",
      "effect": [
        "Ball Control",
        "Finishing",
        "Kicking Power",
        "Physical Contact"
      ]
    },
    {
      "name": "Free-kick Taking",
      "effect": ["Finishing", "Set Piece Taking", "Curl", "Kicking Power"]
    },
    {
      "name": "Aerial",
      "effect": ["Heading", "Jumping", "Physical Contact", "Finishing"]
    },
    {
      "name": "Passing",
      "effect": ["Curl", "Low Pass", "Lofted Pass", "Kicking Power"]
    },
    {
      "name": "Ball-carrying",
      "effect": ["Dribbling", "Tight Possession", "Speed", "Balance"]
    },
    {
      "name": "Technique",
      "effect": ["Dribbling", "Tight Possession", "Low Pass", "Ball Control"]
    },
    {
      "name": "Defending",
      "effect": ["Defensive Awareness", "Tackling", "Acceleration", "Jumping"]
    },
    {
      "name": "Dueling",
      "effect": ["Defensive Awareness", "Tackling", "Speed", "Stamina"]
    },
    {
      "name": "Agility",
      "effect": ["Speed", "Acceleration", "Balance", "Stamina"]
    },
    {
      "name": "Physicality",
      "effect": ["Physical Contact", "Jumping", "Stamina", "Balance"]
    },
    {
      "name": "Goalkeeping",
      "effect": ["GK Awareness", "GK Catching", "GK Parrying", "GK Reflexes"]
    },
    {
      "name": "Striker's Instinct",
      "effect": [
        "Attacking Awareness",
        "Ball Control",
        "Finishing",
        "Acceleration"
      ]
    },
    {
      "name": "Shutdown",
      "effect": [
        "Defensive Awareness",
        "Tackling",
        "Defensive Engagement",
        "Speed"
      ]
    },
    {
      "name": "Hard Worker",
      "effect": ["Aggression", "Acceleration", "Stamina", "Physical Contact"]
    },
    {
      "name": "Saving",
      "effect": ["GK Reflexes", "GK Parrying", "GK Reach", "GK Awareness"]
    },
    {
      "name": "Crossing",
      "effect": ["Lofted Pass", "Curl", "Speed", "Stamina"]
    },
    {
      "name": "Fantasista",
      "effect": ["Ball Control", "Finishing", "Dribbling", "Balance"]
    },
    {
      "name": "Regista",
      "effect": [
        "Tight Possession",
        "Low Pass",
        "Defensive Awareness",
        "Tackling"
      ]
    },
    {
      "name": "Rebuilding",
      "effect": [
        "Low Pass",
        "Defensive Awareness",
        "Aggression",
        "Defensive Engagement"
      ]
    },
    {
      "name": "Accuracy",
      "effect": ["Low Pass", "Lofted Pass", "Finishing", "Kicking Power"]
    },
    {
      "name": "Offence Creator",
      "effect": [
        "Attacking Awareness",
        "Ball Control",
        "Low Pass",
        "Kicking Power"
      ]
    },
    {
      "name": "Ball Protection",
      "effect": [
        "Ball Control",
        "Tight Possession",
        "Physical Contact",
        "Balance"
      ]
    },
    {
      "name": "Balancer",
      "effect": [
        "Attacking Awareness",
        "Defensive Engagement",
        "Acceleration",
        "Stamina"
      ]
    },
    {
      "name": "Counter",
      "effect": [
        "Low Pass",
        "Tackling",
        "Defensive Engagement",
        "Physical Contact"
      ]
    },
    {
      "name": "Aerial Block",
      "effect": [
        "Heading",
        "Jumping",
        "Physical Contact",
        "Defensive Awareness"
      ]
    },
    {
      "name": "Breakthrough",
      "effect": ["Dribbling", "Speed", "Kicking Power", "Physical Contact"]
    },
    {
      "name": "Strength",
      "effect": ["Physical Contact", "Jumping", "Kicking Power", "Speed"]
    },
    {
      "name": "Off the Ball",
      "effect": ["Attacking Awareness", "Speed", "Acceleration", "Stamina"]
    },
    {
      "name": "Stealing",
      "effect": ["Tackling", "Aggression", "Acceleraton", "Physical Contact"]
    },
  ];

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
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatEffect(List<String> effects) {
    return effects.map((e) => "$e +1").join(", ");
  }

  void _showBoosterDialog(String name, List<String> effects, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(name,
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold, color: const Color(0xFF06DF5D))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "O'yinchining quyidagi ko'rsatkichlarini oshiradi:",
              style: GoogleFonts.outfit(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontSize: 13),
            ),
            const SizedBox(height: 12),
            Text(
              _formatEffect(effects),
              style: GoogleFonts.outfit(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Tushunarli",
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF06DF5D))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: themeProvider.getTheme().scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Boosterlar",
            style: GoogleFonts.outfit(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF06DF5D),
          labelColor: const Color(0xFF06DF5D),
          unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Boosterlar"),
            Tab(text: "Tavsiyalar"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBoosterList(isDark),
          _buildRecommendationsList(isDark),
        ],
      ),
    );
  }

  Widget _buildBoosterList(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: boosterData.length,
      itemBuilder: (context, index) {
        final booster = boosterData[index];
        final String name = booster['name'] ?? '';
        final List<String> effects = List<String>.from(booster['effect'] ?? []);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassContainer(
            borderRadius: 16,
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF06DF5D).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.asset(
                  "assets/images/booster.png",
                  width: 30,
                  height: 30,
                ),
              ),
              title: Text(
                name,
                style: GoogleFonts.outfit(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                _formatEffect(effects),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontSize: 12,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.grey),
              onTap: () => _showBoosterDialog(name, effects, isDark),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecommendationsList(bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: recommendations.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = recommendations[index];
        List<String> boostersList = List<String>.from(item['boosters']);

        return GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: const Color(0xFF06DF5D).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.flash_on,
                        color: Color(0xFF06DF5D), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item['playstyle'],
                      style: GoogleFonts.outfit(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _buildBoosterChip(boostersList[0], 1, isDark)),
                  if (boostersList.length > 1) ...[
                    const SizedBox(width: 8),
                    Expanded(
                        child: _buildBoosterChip(boostersList[1], 2, isDark)),
                  ],
                  if (boostersList.length > 2) ...[
                    const SizedBox(width: 8),
                    Expanded(
                        child: _buildBoosterChip(boostersList[2], 3, isDark)),
                  ]
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildBoosterChip(String label, int rank, bool isDark) {
    Color rankColor;
    Color bgColor;
    String rankLabel;

    if (rank == 1) {
      rankColor = const Color(0xFFFFD700); // Gold
      bgColor = const Color(0xFFFFD700).withOpacity(0.15);
      rankLabel = "1-tanlov";
    } else if (rank == 2) {
      rankColor = const Color(0xFFC0C0C0); // Silver
      bgColor = const Color(0xFFC0C0C0).withOpacity(0.15);
      rankLabel = "2-tanlov";
    } else {
      rankColor = const Color(0xFFCD7F32); // Bronze
      bgColor = const Color(0xFFCD7F32).withOpacity(0.15);
      rankLabel = "3-tanlov";
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
            style: GoogleFonts.outfit(
                color: rankColor,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
