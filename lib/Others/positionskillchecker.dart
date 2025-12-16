import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:flutter/material.dart';

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
    'RWF',
    'LWF',
    'AMF',
    'RMF',
    'LMF',
    'CMF',
    'DMF',
    'RB',
    'LB',
    'CB',
    'RWB',
    'LWB',
    'GK'
  ];

  // eFootball skills list
  final List<String> skills = [
    'Scissors Feint',
    'Double Touch',
    'Flip Flap',
    'Marseille Turn',
    'Sombrero',
    'Chop Turn',
    'Cut Behind & Turn',
    'Scotch Move',
    'Sole Control',
    'Heading',
    'Long-range Curler',
    'Chip Shot Control',
    'Knuckle Shot',
    'Dipping Shot',
    'Rising Shot',
    'Long-range Shooting',
    'Acrobatic Finishing',
    'Heel Trick',
    'First-time Shot',
    'One-touch Pass',
    'Through Passing',
    'Weighted Pass',
    'Pinpoint Crossing',
    'Outside Curler',
    'Rabona',
    'No Look Pass',
    'Low Lofted Pass',
    'Long Throw',
    'Penalty Specialist',
    'Gamesmanship',
    'Man Marking',
    'Track Back',
    'Interception',
    'Blocker',
    'Aerial Superiority',
    'Sliding Tackle',
    'Acrobatic Clearance',
    'Captaincy',
    'Super-sub',
    'Fighting Spirit'
  ];

  // Updated Logic map based on the provided matrix and eFootball meta
  final Map<String, Map<String, int>> compatibility = {
    // Top Tier for Attackers
    'First-time Shot': {
      'CF': 100,
      'SS': 95,
      'RWF': 95,
      'LWF': 95,
      'AMF': 90,
      'LMF': 80,
      'RMF': 80
    },
    'Long-range Shooting': {
      'CF': 95,
      'SS': 85,
      'AMF': 95,
      'RWF': 90,
      'LWF': 90,
      'CMF': 85,
      'LMF': 80,
      'RMF': 80
    },
    'Long-range Curler': {
      'CF': 95,
      'SS': 85,
      'RWF': 95,
      'LWF': 95,
      'AMF': 95,
      'CMF': 85,
      'LMF': 80,
      'RMF': 80
    },
    'One-touch Pass': {
      'CF': 95,
      'SS': 95,
      'AMF': 100,
      'RWF': 95,
      'LWF': 95,
      'CMF': 100,
      'DMF': 100,
      'LMF': 100,
      'RMF': 100,
      'RB': 90,
      'LB': 90,
      'CB': 60
    },
    'Through Passing': {
      'CF': 80,
      'SS': 90,
      'AMF': 95,
      'RWF': 100,
      'LWF': 100,
      'CMF': 95,
      'DMF': 95,
      'LMF': 95,
      'RMF': 95,
      'RB': 90,
      'LB': 90
    },
    'Outside Curler': {
      'CF': 95,
      'SS': 90,
      'RWF': 90,
      'LWF': 90,
      'AMF': 95,
      'CMF': 90,
      'LMF': 90,
      'RMF': 90,
      'DMF': 60
    },
    'Fighting Spirit': {
      'CF': 95,
      'SS': 85,
      'AMF': 85,
      'RWF': 80,
      'LWF': 80,
      'CMF': 85,
      'DMF': 40,
      'CB': 40,
      'RB': 40,
      'LB': 40
    }, // High for attackers, low for defenders per matrix
    'Super-sub': {
      'CF': 100,
      'SS': 100,
      'RWF': 100,
      'LWF': 100,
      'AMF': 100,
      'RMF': 50,
      'LMF': 50,
      'CMF': 20,
      'DMF': 0,
      'CB': 0,
      'RB': 0,
      'LB': 0,
      'GK': 0
    },

    // Technical / Dribbling
    'Chip Shot Control': {
      'CF': 85,
      'SS': 80,
      'RWF': 40,
      'LWF': 40,
      'AMF': 60,
      'CMF': 20
    },
    'Heading': {
      'CF': 85,
      'SS': 60,
      'RWF': 60,
      'LWF': 60,
      'CB': 80,
      'RB': 80,
      'LB': 80,
      'DMF': 70
    }, // CF useful/low, Defenders useful
    'Heel Trick': {
      'CF': 80,
      'SS': 80,
      'RWF': 70,
      'LWF': 70,
      'AMF': 85,
      'CMF': 90,
      'LMF': 90,
      'RMF': 90
    },
    'Acrobatic Finishing': {'CF': 80, 'SS': 70, 'RWF': 60, 'LWF': 60},
    'Gamesmanship': {
      'CF': 75,
      'SS': 75,
      'RWF': 80,
      'LWF': 80,
      'AMF': 80,
      'LMF': 80,
      'RMF': 80
    },
    'Aerial Superiority': {
      'CF': 80,
      'CB': 95,
      'RB': 90,
      'LB': 90,
      'DMF': 85,
      'CMF': 70
    },

    // Special Skills
    'Pinpoint Crossing': {
      'RWF': 90,
      'LWF': 90,
      'RMF': 95,
      'LMF': 95,
      'RB': 95,
      'LB': 95,
      'RWB': 95,
      'LWB': 95,
      'AMF': 70
    },
    'Track Back': {
      'RWF': 70,
      'LWF': 70,
      'AMF': 40,
      'LMF': 85,
      'RMF': 85,
      'CMF': 80,
      'RWB': 85,
      'LWB': 85,
      'RB': 85,
      'LB': 85,
      'DMF': 20,
      'CB': 0
    },
    'Weighted Pass': {
      'RWF': 40,
      'LWF': 40,
      'AMF': 70,
      'LMF': 40,
      'RMF': 40,
      'CMF': 80,
      'DMF': 80,
      'RB': 60,
      'LB': 60,
      'CB': 80
    },

    // Midfield / Defence
    'Interception': {
      'CMF': 95,
      'DMF': 100,
      'LMF': 80,
      'RMF': 80,
      'RB': 100,
      'LB': 100,
      'CB': 100
    },
    'Man Marking': {'DMF': 95, 'RB': 90, 'LB': 90, 'CB': 95},
    'Blocker': {'DMF': 95, 'RB': 90, 'LB': 90, 'CB': 95},
    'Sliding Tackle': {'CMF': 70, 'DMF': 85, 'RB': 85, 'LB': 85, 'CB': 95},
    'Acrobatic Clearance': {'DMF': 85, 'RB': 85, 'LB': 85, 'CB': 95},

    // Goalkeeper
    'GK Low Punt': {'GK': 100},
    'GK Long Throw': {'GK': 100},
    'GK Penalty Saver': {'GK': 100},
    'GK High Punt': {'GK': 80},

    // Dribbling Specific
    'Double Touch': {
      'CF': 90,
      'SS': 95,
      'RWF': 95,
      'LWF': 95,
      'AMF': 95,
      'RMF': 85,
      'LMF': 85
    },
    'Sole Control': {
      'CF': 80,
      'SS': 85,
      'RWF': 85,
      'LWF': 85,
      'AMF': 90,
      'CMF': 85
    },
    'Flip Flap': {
      'RWF': 80,
      'LWF': 80,
      'SS': 80
    }, // Only if combined for special double touch, generally lower generic value
    'Marsielle Turn': {'AMF': 70, 'RWF': 70, 'LWF': 70},

    // Other
    'Knuckle Shot': {'CF': 60, 'SS': 50, 'AMF': 50},
    'Dipping Shot': {'CF': 60, 'SS': 50, 'AMF': 50},
    'Rising Shot': {'CF': 60, 'SS': 50, 'AMF': 50},
  };

  String? selectedPosition;
  final Set<String> selectedSkills = {};
  String validationMessage = '';

  // Get compatibility percentage
  int getCompatibility(String skill, String position) {
    final map = compatibility[skill];
    if (map != null && map.containsKey(position)) return map[position]!;

    // Better defaults based on matrix "useful" vs "not necessary"
    if (position == 'GK') return 0;

    // Defenders
    if (['CB', 'RB', 'LB'].contains(position)) {
      if (['Long-range Shooting', 'Super-sub', 'Track Back'].contains(skill))
        return 0; // Do not give
      if (['One-touch Pass', 'Through Passing', 'Weighted Pass']
          .contains(skill)) return 60; // Useful low
    }

    // Attackers
    if (['CF', 'SS', 'RWF', 'LWF'].contains(skill)) {
      if (['Man Marking', 'Interception', 'Blocker'].contains(skill)) return 10;
    }

    return 45; // Generic low-mid match
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Skill Moslik Hisoblagich',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
              onPressed: _clearAll,
              icon: const Icon(Icons.refresh, color: Colors.white70))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Position Section
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('1. Pozitsiyani tanlang',
                    style: TextStyle(
                        color: AppColors.accent,
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
                    label: Text(pos),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        selectedPosition = pos;
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

            // Skills Section
            Padding(
              padding: const EdgeInsets.only(
                  left: 16, top: 16, bottom: 8, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('2. Skillarni tanlang (${selectedSkills.length}/5)',
                      style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  if (validationMessage.isNotEmpty)
                    Text(validationMessage,
                        style: const TextStyle(
                            color: Colors.redAccent, fontSize: 12)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills.map((s) {
                    bool isSelected = selectedSkills.contains(s);
                    return FilterChip(
                      label: Text(s),
                      selected: isSelected,
                      onSelected: (_) => toggleSkill(s),
                      backgroundColor: Colors.white10,
                      selectedColor: AppColors.accent.withOpacity(0.8),
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide.none),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Analysis Section
            if (selectedPosition != null && selectedSkills.isNotEmpty)
              _buildAnalysisResult(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisResult() {
    // Calculate Average
    int total = selectedSkills.fold(
        0, (sum, s) => sum + getCompatibility(s, selectedPosition!));
    double avg = total / selectedSkills.length;
    Color scoreColor = avg >= 90
        ? Colors.cyanAccent
        : (avg >= 80
            ? Colors.green
            : (avg >= 50 ? Colors.orange : Colors.redAccent));
    String verdict = avg >= 90
        ? "Mukammal Moslik! 🔥"
        : (avg >= 80
            ? "Juda Yaxshi Tanlov ✅"
            : (avg >= 50 ? "O'rtacha ⚠️" : "Tavsiya etilmaydi ❌"));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tahlil Natijasi',
              style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppColors.accent.withOpacity(0.2),
                  AppColors.cardSurface
                ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accent.withOpacity(0.3))),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Umumiy Reyting:',
                        style: TextStyle(color: Colors.white70)),
                    Text('${avg.toStringAsFixed(1)}%',
                        style: TextStyle(
                            color: scoreColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(verdict,
                    style: TextStyle(
                        color: scoreColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const Divider(color: Colors.white12, height: 30),
                ...selectedSkills.map((s) {
                  int score = getCompatibility(s, selectedPosition!);
                  Color barColor = score >= 90
                      ? Colors.cyanAccent
                      : (score >= 80
                          ? Colors.green
                          : (score >= 50 ? Colors.orange : Colors.redAccent));
                  String status = "Mos";
                  if (score >= 95)
                    status = "Must-have";
                  else if (score <= 20)
                    status = "Do not give";
                  else if (score <= 50) status = "Not necessary";

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(s,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500)),
                            Row(
                              children: [
                                Text(status,
                                    style: const TextStyle(
                                        color: Colors.white54, fontSize: 10)),
                                const SizedBox(width: 8),
                                Text('$score%',
                                    style: TextStyle(
                                        color: barColor,
                                        fontWeight: FontWeight.bold)),
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
