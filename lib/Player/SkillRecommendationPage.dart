import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:flutter/material.dart';

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Skill Tavsiyalari",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
                  backgroundColor: AppColors.cardSurface,
                  selectedColor: AppColors.accent,
                  labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal),
                  side: BorderSide.none,
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
                    const Color(0xFF6495ED)), // Cornflower Blue
                _buildSection(
                    "Special (Maxsus)",
                    skillData[positions[selectedIndex]]!.firstWhere(
                        (e) => e['type'] == 'special',
                        orElse: () => {})['skills'],
                    Colors.orange),
                _buildSection(
                    "Useful (Foydali)",
                    skillData[positions[selectedIndex]]!.firstWhere(
                        (e) => e['type'] == 'useful',
                        orElse: () => {})['skills'],
                    const Color(0xFF90EE90)), // Light Green
                _buildSection(
                    "Useful, not necessary (Kamroq foydali)",
                    skillData[positions[selectedIndex]]!.firstWhere(
                        (e) => e['type'] == 'useful_low',
                        orElse: () => {})['skills'],
                    const Color(0xFFF0E68C)), // Khaki
                _buildSection(
                    "Not necessary (Shart emas)",
                    skillData[positions[selectedIndex]]!.firstWhere(
                        (e) => e['type'] == 'not_necessary',
                        orElse: () => {})['skills'],
                    const Color(0xFFFF7F7F)), // Light Red
                _buildSection(
                    "Do not give (Bermang)",
                    skillData[positions[selectedIndex]]!.firstWhere(
                        (e) => e['type'] == 'do_not_give',
                        orElse: () => {})['skills'],
                    Colors.black87),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<dynamic>? skills, Color color) {
    if (skills == null || skills.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.8),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Text(
            title,
            style: TextStyle(
                color: (color == Colors.black87)
                    ? Colors.redAccent
                    : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 14),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(10)),
              border: Border.all(color: color.withOpacity(0.5))),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills
                .map((skill) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(skill.toString(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13)),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
