import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:efinfo_beta/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PositionSkillPage extends StatefulWidget {
  const PositionSkillPage({super.key});

  @override
  State<PositionSkillPage> createState() => _PositionSkillPageState();
}

class _PositionSkillPageState extends State<PositionSkillPage> {
  // Football positions
  final List<String> positions = [
    'CF',
    'SS',
    'LWF',
    'RWF',
    'AMF',
    'LMF',
    'RMF',
    'CMF',
    'DMF',
    'Attacking RB',
    'Attacking LB',
    'Defensive RB',
    'Defensive LB',
    'CB',
    'GK'
  ];

  // Grouped Skills for UI
  final Map<String, List<String>> skillCategories = {
    'Shooting': [
      'First-time Shot',
      'Long-range Shooting',
      'Long-range Curler',
      'Chip Shot Control',
      'Acrobatic Finishing',
      'Knuckle Shot',
      'Dipping Shot',
      'Rising Shot',
      'Penalty Specialist',
    ],
    'Dribbling': [
      'Double Touch',
      'Marseille Turn',
      'Sombrero',
      'Chop Turn',
      'Cut Behind & Turn',
      'Scotch Move',
      'Scissors Feint',
      'Flip Flap',
      'Sole Control',
      'Heel Trick',
    ],
    'Passing': [
      'One-touch Pass',
      'Through Passing',
      'Weighted Pass',
      'Pinpoint Crossing',
      'Outside Curler',
      'Low Lofted Pass',
      'No Look Pass',
      'Rabona',
    ],
    'Defending': [
      'Interception',
      'Man Marking',
      'Blocker',
      'Track Back',
      'Sliding Tackle',
      'Acrobatic Clearance',
    ],
    'Physical / Mental': [
      'Heading',
      'Aerial Superiority',
      'Fighting Spirit',
      'Super-sub',
      'Captaincy',
      'Gamesmanship',
      'Long Throw',
    ],
    'Goalkeeper': [
      'GK Low Punt',
      'GK High Punt',
      'GK Long Throw',
      'GK Penalty Saver',
    ],
  };

  // Data structure from SkillRecommendationPage (Synced)
  final Map<String, List<Map<String, dynamic>>> skillDataSource = {
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

  late final Map<String, Map<String, int>> _positionRequirements;
  final Set<String> _personalPreference = {
    'Knuckle Shot',
    'Dipping Shot',
    'Rising Shot',
    'Double Touch',
    'Sole Control',
    'Flip Flap',
    'Marseille Turn',
    'Cut Behind & Turn',
    'Scissors Feint',
    'Chop Turn',
    'Scotch Move',
    'Rabona',
    'Sombrero'
  };

  @override
  void initState() {
    super.initState();
    _initRequirements();
  }

  void _initRequirements() {
    // Helper to process source data into score map
    Map<String, int> processSource(String sourceKey) {
      final List<Map<String, dynamic>>? data = skillDataSource[sourceKey];
      if (data == null) return {};

      final Map<String, int> scores = {};
      for (var group in data) {
        String type = group['type'];
        List<String> skills = List<String>.from(group['skills']);
        int score = 0;
        switch (type) {
          case 'must_have':
            score = 100;
            break;
          case 'special':
            score = 100; // Treated as high value
            break;
          case 'useful':
            score = 80;
            break;
          case 'useful_low':
            score = 60;
            break;
          case 'not_necessary':
            score = 20;
            break;
          case 'do_not_give':
            score = 0;
            break;
          default:
            score = 0;
        }
        for (var s in skills) {
          scores[s] = score;
        }
      }
      return scores;
    }

    // Map local positions to source keys
    _positionRequirements = {
      'CF': processSource('CF'),
      'SS': processSource('CF'), // SS shares CF logic
      'LWF': processSource('L/RWF'),
      'RWF': processSource('L/RWF'),
      'AMF': processSource('AMF'),
      'LMF': processSource('L/RMF'),
      'RMF': processSource('L/RMF'),
      'CMF': processSource('CMF'),
      'DMF': processSource('DMF'),
      'Attacking RB': processSource('Attacking L/RB'),
      'Attacking LB': processSource('Attacking L/RB'),
      'Defensive RB': processSource('Defensive L/RB'),
      'Defensive LB': processSource('Defensive L/RB'),
      'CB': processSource('CB'),
      'GK': processSource('GK'),
    };
  }

  String? selectedPosition;
  final Set<String> selectedSkills = {};
  String validationMessage = '';

  int getCompatibility(String skill, String position) {
    int score = 0;
    bool isDefined = false;

    // 1. Check Explicit Definition
    final posStats = _positionRequirements[position];
    if (posStats != null && posStats.containsKey(skill)) {
      score = posStats[skill]!;
      isDefined = true;
    }

    // 2. Check for Universally Useful Skills
    final universalUsefulSkills = {
      'Penalty Specialist',
      'Captaincy',
      'Fighting Spirit',
      'Super-sub'
    };

    if (universalUsefulSkills.contains(skill)) {
      // If the skill is explicitly defined as "Do Not Give" (0), respect that restriction.
      if (isDefined && score == 0) {
        return 0;
      }

      // Otherwise (if missing or defined as low value), boost it to "Useful" (80).
      if (score < 80) {
        return 80;
      }
      return score; // Maintain 100 if it's already high
    }

    // If we found a valid score from explicit definition that wasn't a universal skill
    if (isDefined) return score;

    // 3. Personal Preference Fallback
    bool isAttackingOrMid = [
      'CF',
      'SS',
      'LWF',
      'RWF',
      'AMF',
      'LMF',
      'RMF',
      'CMF'
    ].contains(position);

    if (_personalPreference.contains(skill)) {
      if (isAttackingOrMid) {
        return 70; // Personal Preference Score
      }
    }

    return 0;
  }

  void toggleSkill(String skill) {
    setState(() {
      if (selectedSkills.contains(skill)) {
        selectedSkills.remove(skill);
      } else {
        if (selectedSkills.length >= 5) {
          validationMessage = 'Maksimal 5 ta skill tanlash mumkin!';
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) setState(() => validationMessage = '');
          });
          return;
        }
        selectedSkills.add(skill);
      }
    });
  }

  void _clearAll() {
    setState(() {
      selectedSkills.clear();
      validationMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: themeProvider.getTheme().scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Skill Moslik Hisoblagich',
            style: GoogleFonts.outfit(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold)),
        backgroundColor: themeProvider.getTheme().scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        actions: [
          IconButton(
              onPressed: _clearAll,
              icon: Icon(Icons.refresh,
                  color: isDark ? Colors.white70 : Colors.black54))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Position Selector
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('1. Pozitsiyani tanlang',
                    style: GoogleFonts.outfit(
                        color: const Color(0xFF06DF5D),
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(
              height: 60,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: positions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final pos = positions[index];
                  bool isSelected = selectedPosition == pos;
                  return ChoiceChip(
                    label: Text(pos, style: GoogleFonts.outfit()),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        selectedPosition = pos;
                      });
                    },
                    backgroundColor:
                        isDark ? const Color(0xFF1C1C1E) : Colors.grey[200],
                    selectedColor: const Color(0xFF06DF5D),
                    labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black54),
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal),
                    side: BorderSide.none,
                  );
                },
              ),
            ),

            // Skills Selector Header
            Padding(
              padding: const EdgeInsets.only(
                  left: 16, top: 16, bottom: 8, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('2. Skillarni tanlang (${selectedSkills.length}/5)',
                      style: GoogleFonts.outfit(
                          color: const Color(0xFF06DF5D),
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  if (validationMessage.isNotEmpty)
                    Text(validationMessage,
                        style: GoogleFonts.outfit(
                            color: Colors.redAccent, fontSize: 12)),
                ],
              ),
            ),

            // Grouped Skills with ExpansionTiles or plain Sections
            // User requested organized and grouped. ExpansionTiles are cleaner.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: skillCategories.entries.map((entry) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: GlassContainer(
                      borderRadius: 16,
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          title: Text(entry.key,
                              style: GoogleFonts.outfit(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold)),
                          leading: _getCategoryIcon(entry.key, isDark),
                          childrenPadding: const EdgeInsets.all(12),
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: entry.value.map((s) {
                                bool isSelected = selectedSkills.contains(s);
                                return FilterChip(
                                  label: Text(s,
                                      style: GoogleFonts.outfit(fontSize: 12)),
                                  selected: isSelected,
                                  onSelected: (_) => toggleSkill(s),
                                  backgroundColor:
                                      isDark ? Colors.white10 : Colors.black12,
                                  selectedColor:
                                      const Color(0xFF06DF5D).withOpacity(0.8),
                                  checkmarkColor: Colors.white,
                                  labelStyle: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : (isDark
                                              ? Colors.white70
                                              : Colors.black87)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide.none),
                                );
                              }).toList(),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Analysis Result logic remains similar...
            if (selectedPosition != null && selectedSkills.isNotEmpty)
              _buildAnalysisResult(isDark),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Icon _getCategoryIcon(String category, bool isDark) {
    switch (category) {
      case 'Shooting':
        return const Icon(Icons.sports_soccer, color: Colors.orangeAccent);
      case 'Dribbling':
        return const Icon(Icons.directions_run, color: Colors.blueAccent);
      case 'Passing':
        return const Icon(Icons.transform, color: Colors.greenAccent);
      case 'Defending':
        return const Icon(Icons.shield, color: Colors.redAccent);
      case 'Physical / Mental':
        return const Icon(Icons.psychology, color: Colors.purpleAccent);
      case 'Goalkeeper':
        return const Icon(Icons.front_hand, color: Colors.yellowAccent);
      default:
        return Icon(Icons.circle, color: isDark ? Colors.white : Colors.black);
    }
  }

  Widget _buildAnalysisResult(bool isDark) {
    int total = selectedSkills.fold(
        0, (sum, s) => sum + getCompatibility(s, selectedPosition!));
    double avg = total / selectedSkills.length;

    Color scoreColor = avg >= 90
        ? Colors.cyanAccent
        : (avg >= 80
            ? Colors.green
            : (avg >= 60 ? Colors.orangeAccent : Colors.redAccent));

    String verdict = avg >= 95
        ? "Mukammal Moslik! 🔥"
        : (avg >= 80
            ? "Juda Yaxshi Tanlov ✅"
            : (avg >= 60 ? "Yomon emas ⚠️" : "Tavsiya etilmaydi ❌"));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tahlil Natijasi',
              style: GoogleFonts.outfit(
                  color: const Color(0xFF06DF5D),
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          GlassContainer(
            borderRadius: 20,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Umumiy Reyting:',
                        style: GoogleFonts.outfit(
                            color: isDark ? Colors.white70 : Colors.black54)),
                    Text('${avg.toStringAsFixed(0)}%',
                        style: GoogleFonts.outfit(
                            color: scoreColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(verdict,
                    style: GoogleFonts.outfit(
                        color: scoreColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const Divider(color: Colors.white12, height: 30),
                ...selectedSkills.map((s) {
                  int score = getCompatibility(s, selectedPosition!);
                  Color barColor;
                  String statusText;

                  if (score == 100) {
                    barColor = Colors.cyanAccent;
                    statusText = "Majburiy (Must-have)";
                  } else if (score >= 80) {
                    barColor = Colors.green;
                    statusText = "Foydali";
                  } else if (score >= 60) {
                    barColor = Colors.orangeAccent;
                    statusText = "Foydali, lekin shart emas";
                  } else if (score == 70) {
                    barColor = Colors.purpleAccent;
                    statusText = "Shaxsiy Tanlov";
                  } else if (score == 20) {
                    barColor = Colors.redAccent;
                    statusText = "Kerak emas";
                  } else {
                    barColor = Colors.grey;
                    statusText = "Tavsiya qilinmaydi";
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(s,
                                style: GoogleFonts.outfit(
                                    color: isDark ? Colors.white : Colors.black,
                                    fontSize: 13)),
                            Row(
                              children: [
                                Text(statusText,
                                    style: GoogleFonts.outfit(
                                        color: barColor.withOpacity(0.8),
                                        fontSize: 10)),
                                const SizedBox(width: 8),
                                Text('$score',
                                    style: GoogleFonts.outfit(
                                        color: barColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: score / 100,
                            backgroundColor: Colors.white10,
                            valueColor: AlwaysStoppedAnimation(barColor),
                            minHeight: 6,
                          ),
                        )
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
