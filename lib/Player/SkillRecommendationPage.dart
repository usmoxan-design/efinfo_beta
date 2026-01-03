import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:efinfo_beta/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class SkillRecommendationPage extends StatefulWidget {
  const SkillRecommendationPage({super.key});

  @override
  State<SkillRecommendationPage> createState() =>
      _SkillRecommendationPageState();
}

class _SkillRecommendationPageState extends State<SkillRecommendationPage> {
  int selectedIndex = 0;

  final List<String> positions = [
    "CF",
    "L/RWF",
    "AMF",
    "L/RMF",
    "CMF",
    "DMF",
    "Attacking L/RB",
    "Defensive L/RB",
    "CB",
    "GK"
  ];

  // Data structure: Position -> List of Categories -> Skills
  final Map<String, List<Map<String, dynamic>>> skillData = {
    "CF": [
      {
        "type": "must_have",
        "skills": [
          "First-time Shot",
          "Long-range Shooting",
          "Long-range Curler",
          "One-touch Pass",
          "Outside Curler",
          "Fighting Spirit"
        ]
      },
      {
        "type": "special",
        "skills": ["Super-sub"]
      },
      {
        "type": "useful",
        "skills": [
          "Through Passing",
          "Chip Shot Control",
          "Heading",
          "Heel Trick"
        ]
      },
      {
        "type": "useful_low",
        "skills": ["Acrobatic Finishing", "Gamesmanship", "Aerial Superiority"]
      },
      {
        "type": "not_necessary",
        "skills": ["Track Back", "Weighted Pass"]
      }
    ],
    "L/RWF": [
      {
        "type": "must_have",
        "skills": [
          "Through Passing",
          "One-touch Pass",
          "Long-range Shooting",
          "Long-range Curler",
          "First-time Shot"
        ]
      },
      {
        "type": "special",
        "skills": ["Super-sub"]
      },
      {
        "type": "useful",
        "skills": [
          "Pinpoint Crossing",
          "Outside Curler",
          "Heel Trick",
          "Gamesmanship",
          "Weighted Pass",
          "Chip Shot Control"
        ]
      },
      {
        "type": "useful_low",
        "skills": ["Fighting Spirit", "Track Back"]
      }
    ],
    "AMF": [
      {
        "type": "must_have",
        "skills": [
          "One-touch Pass",
          "Through Passing",
          "Long-range Shooting",
          "Long-range Curler",
          "Outside Curler"
        ]
      },
      {
        "type": "special",
        "skills": ["Super-sub"]
      },
      {
        "type": "useful",
        "skills": [
          "First-time Shot",
          "Heel Trick",
          "Gamesmanship",
          "Fighting Spirit"
        ]
      },
      {
        "type": "useful_low",
        "skills": ["Pinpoint Crossing", "Weighted Pass"]
      },
      {
        "type": "not_necessary",
        "skills": ["Track Back", "Chip Shot Control"]
      }
    ],
    "L/RMF": [
      {
        "type": "must_have",
        "skills": [
          "One-touch Pass",
          "Through Passing",
          "Pinpoint Crossing",
          "Outside Curler"
        ]
      },
      {
        "type": "useful",
        "skills": ["Heel Trick", "Track Back", "Interception"]
      },
      {
        "type": "useful_low",
        "skills": [
          "Gamesmanship",
          "Fighting Spirit",
          "Long-range Shooting",
          "Long-range Curler"
        ]
      },
      {
        "type": "do_not_give",
        "skills": ["First-time Shot", "Weighted Pass"]
      }
    ],
    "CMF": [
      {
        "type": "must_have",
        "skills": ["One-touch Pass", "Through Passing", "Interception"]
      },
      {
        "type": "useful",
        "skills": [
          "Outside Curler",
          "Heel Trick",
          "Long-range Shooting",
          "Long-range Curler",
          "Weighted Pass",
          "Track Back"
        ]
      },
      {
        "type": "useful_low",
        "skills": [
          "Fighting Spirit",
          "Sliding Tackle",
          "Aerial Superiority",
          "First-time Shot"
        ]
      },
      {
        "type": "not_necessary",
        "skills": ["Super-sub"]
      }
    ],
    "DMF": [
      {
        "type": "must_have",
        "skills": [
          "Interception",
          "One-touch Pass",
          "Through Passing",
          "Man Marking",
          "Blocker"
        ]
      },
      {
        "type": "useful",
        "skills": [
          "Sliding Tackle",
          "Acrobatic Clearance",
          "Aerial Superiority",
          "Weighted Pass",
          "Heading"
        ]
      },
      {
        "type": "useful_low",
        "skills": ["Track Back", "Outside Curler"]
      },
      {
        "type": "not_necessary",
        "skills": ["Fighting Spirit"]
      },
      {
        "type": "do_not_give",
        "skills": ["Super-sub"]
      }
    ],
    "Attacking L/RB": [
      {
        "type": "must_have",
        "skills": [
          "Interception",
          "One-touch Pass",
          "Pinpoint Crossing",
          "Through Passing"
        ]
      },
      {
        "type": "useful",
        "skills": [
          "Blocker",
          "Man Marking",
          "Track Back",
          "Sliding Tackle",
          "Fighting Spirit"
        ]
      },
      {
        "type": "useful_low",
        "skills": ["Aerial Superiority", "Heading", "Weighted Pass"]
      },
      {
        "type": "not_necessary",
        "skills": ["Fighting Spirit"]
      },
      {
        "type": "do_not_give",
        "skills": ["Super-sub"]
      }
    ],
    "Defensive L/RB": [
      {
        "type": "must_have",
        "skills": [
          "Interception",
          "Man Marking",
          "Blocker",
          "Aerial Superiority",
          "Acrobatic Clearance",
          "Sliding Tackle"
        ]
      },
      {
        "type": "useful",
        "skills": [
          "Heading",
          "One-touch Pass",
          "Through Passing",
          "Weighted Pass",
          "Low Lofted Pass"
        ]
      },
      {
        "type": "useful_low",
        "skills": ["Pinpoint Crossing"]
      },
      {
        "type": "not_necessary",
        "skills": ["Fighting Spirit"]
      },
      {
        "type": "do_not_give",
        "skills": ["Track Back", "Super-sub"]
      }
    ],
    "CB": [
      {
        "type": "must_have",
        "skills": [
          "Interception",
          "Man Marking",
          "Blocker",
          "Aerial Superiority",
          "Acrobatic Clearance",
          "Sliding Tackle",
          "Heading"
        ]
      },
      {
        "type": "useful",
        "skills": ["Weighted Pass"]
      },
      {
        "type": "useful_low",
        "skills": ["One-touch Pass", "Through Passing", "Low Lofted Pass"]
      },
      {
        "type": "not_necessary",
        "skills": ["Fighting Spirit"]
      },
      {
        "type": "do_not_give",
        "skills": ["Track Back", "Super-sub"]
      }
    ],
    "GK": [
      {
        "type": "must_have",
        "skills": ["GK Low Punt", "GK Long Throw", "GK Penalty Saver"]
      },
      {
        "type": "useful",
        "skills": ["Weighted Pass", "GK High Punt", "One-touch Pass"]
      },
      {
        "type": "useful_low",
        "skills": ["Through Passing", "Low Lofted Pass"]
      },
      {
        "type": "not_necessary",
        "skills": ["Fighting Spirit"]
      },
      {
        "type": "do_not_give",
        "skills": ["Super-sub"]
      }
    ]
  };

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: themeProvider.getTheme().scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Skill Tavsiyalari",
            style: GoogleFonts.outfit(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: Column(
        children: [
          // Position Selector
          SizedBox(
            height: 60,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              scrollDirection: Axis.horizontal,
              itemCount: positions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                bool isSelected = selectedIndex == index;
                return ChoiceChip(
                  label: Text(positions[index]),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  backgroundColor: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.05),
                  selectedColor: const Color(0xFF06DF5D).withOpacity(0.2),
                  labelStyle: GoogleFonts.outfit(
                      color: isSelected
                          ? const Color(0xFF06DF5D)
                          : (isDark ? Colors.white70 : Colors.black54),
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF06DF5D)
                        : Colors.transparent,
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                );
              },
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSection(
                    "Must-have (Muhim)",
                    skillData[positions[selectedIndex]]!.firstWhere(
                        (e) => e['type'] == 'must_have',
                        orElse: () => {})['skills'],
                    const Color(0xFF6495ED),
                    isDark), // Cornflower Blue
                _buildSection(
                    "Special (Maxsus)",
                    skillData[positions[selectedIndex]]!.firstWhere(
                        (e) => e['type'] == 'special',
                        orElse: () => {})['skills'],
                    Colors.orange,
                    isDark),
                _buildSection(
                    "Useful (Foydali)",
                    skillData[positions[selectedIndex]]!.firstWhere(
                        (e) => e['type'] == 'useful',
                        orElse: () => {})['skills'],
                    const Color(0xFF90EE90),
                    isDark), // Light Green
                _buildSection(
                    "Useful, not necessary (Kamroq foydali)",
                    skillData[positions[selectedIndex]]!.firstWhere(
                        (e) => e['type'] == 'useful_low',
                        orElse: () => {})['skills'],
                    const Color(0xFFF0E68C),
                    isDark), // Khaki
                _buildSection(
                    "Not necessary (Shart emas)",
                    skillData[positions[selectedIndex]]!.firstWhere(
                        (e) => e['type'] == 'not_necessary',
                        orElse: () => {})['skills'],
                    const Color(0xFFFF7F7F),
                    isDark), // Light Red
                _buildSection(
                    "Do not give (Bermang)",
                    skillData[positions[selectedIndex]]!.firstWhere(
                        (e) => e['type'] == 'do_not_give',
                        orElse: () => {})['skills'],
                    Colors.black87,
                    isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      String title, List<dynamic>? skills, Color color, bool isDark) {
    if (skills == null || skills.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.8),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Text(
            title,
            style: GoogleFonts.outfit(
                color: (color == Colors.black87)
                    ? Colors.redAccent
                    : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 15),
          ),
        ),
        GlassContainer(
          borderRadius: 0,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(16)),
                border: Border.all(color: color.withOpacity(0.3))),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills
                  .map((skill) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: isDark ? Colors.white10 : Colors.black12),
                        ),
                        child: Text(skill.toString(),
                            style: GoogleFonts.outfit(
                                color: isDark ? Colors.white : Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                      ))
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
