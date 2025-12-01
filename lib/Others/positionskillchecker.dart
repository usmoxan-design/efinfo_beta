// Flutter page: Position & Skill Selector for eFootball-style compatibility (Advanced Analysis)
// File: lib/pages/position_skill_page.dart

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

  // --- Advanced football logic-based compatibility ---
  // Based on tactical roles and skill utility per position in eFootball gameplay
  final Map<String, Map<String, int>> compatibility = {
    'Scissors Feint': {
      'CF': 85,
      'SS': 88,
      'RWF': 90,
      'LWF': 90,
      'AMF': 70,
      'CMF': 50,
      'DMF': 25,
      'CB': 10,
      'GK': 0
    },
    'Double Touch': {
      'CF': 92,
      'SS': 95,
      'RWF': 90,
      'LWF': 90,
      'AMF': 88,
      'RMF': 80,
      'LMF': 80,
      'CMF': 70,
      'DMF': 45
    },
    'Flip Flap': {
      'CF': 85,
      'SS': 90,
      'RWF': 92,
      'LWF': 92,
      'AMF': 75,
      'RMF': 78,
      'LMF': 78
    },
    'Marseille Turn': {
      'CF': 75,
      'SS': 82,
      'RWF': 70,
      'LWF': 70,
      'AMF': 90,
      'CMF': 80
    },
    'Sombrero': {'CF': 88, 'SS': 85, 'RWF': 70, 'LWF': 70, 'AMF': 65},
    'Chop Turn': {
      'CF': 85,
      'SS': 80,
      'RWF': 78,
      'LWF': 78,
      'AMF': 75,
      'CMF': 65
    },
    'Cut Behind & Turn': {'CF': 80, 'SS': 88, 'RWF': 85, 'LWF': 85, 'AMF': 75},
    'Sole Control': {'CF': 70, 'SS': 75, 'AMF': 80, 'CMF': 82, 'DMF': 75},
    'Heading': {'CF': 95, 'SS': 85, 'CB': 88, 'LB': 60, 'RB': 60, 'DMF': 55},
    'Long-range Curler': {
      'CF': 82,
      'SS': 85,
      'AMF': 90,
      'CMF': 88,
      'RWF': 85,
      'LWF': 85
    },
    'Chip Shot Control': {'CF': 90, 'SS': 85, 'RWF': 80, 'LWF': 80},
    'Knuckle Shot': {'CF': 90, 'SS': 88, 'AMF': 85, 'CMF': 82, 'DMF': 70},
    'Dipping Shot': {'CF': 85, 'SS': 85, 'AMF': 88, 'CMF': 80},
    'Rising Shot': {'CF': 92, 'SS': 88, 'RWF': 78, 'LWF': 78},
    'Long-range Shooting': {
      'CF': 75,
      'SS': 70,
      'AMF': 92,
      'CMF': 88,
      'DMF': 80
    },
    'Acrobatic Finishing': {'CF': 95, 'SS': 90, 'RWF': 85, 'LWF': 85},
    'Heel Trick': {'CF': 80, 'SS': 88, 'RWF': 75, 'LWF': 75, 'AMF': 70},
    'First-time Shot': {'CF': 95, 'SS': 92, 'AMF': 88, 'RWF': 80, 'LWF': 80},
    'One-touch Pass': {
      'CF': 80,
      'SS': 85,
      'AMF': 90,
      'CMF': 95,
      'DMF': 88,
      'RB': 70,
      'LB': 70
    },
    'Through Passing': {'SS': 88, 'AMF': 95, 'CMF': 92, 'DMF': 85},
    'Weighted Pass': {'AMF': 90, 'CMF': 88, 'DMF': 80, 'RB': 75, 'LB': 75},
    'Pinpoint Crossing': {
      'RWF': 90,
      'LWF': 90,
      'RMF': 88,
      'LMF': 88,
      'RB': 85,
      'LB': 85,
      'RWB': 88,
      'LWB': 88
    },
    'Outside Curler': {'CF': 85, 'SS': 85, 'RWF': 90, 'LWF': 90},
    'Rabona': {'CF': 70, 'SS': 80, 'RWF': 85, 'LWF': 85, 'AMF': 75},
    'No Look Pass': {'AMF': 90, 'CMF': 88, 'SS': 82},
    'Low Lofted Pass': {'CMF': 90, 'DMF': 85, 'AMF': 88, 'RB': 80, 'LB': 80},
    'Long Throw': {'RB': 90, 'LB': 90, 'RWB': 92, 'LWB': 92},
    'Penalty Specialist': {'CF': 95, 'SS': 90, 'AMF': 80, 'CMF': 70},
    'Gamesmanship': {'CF': 80, 'SS': 85, 'AMF': 82, 'CMF': 78},
    'Man Marking': {'CB': 95, 'DMF': 90, 'RB': 85, 'LB': 85},
    'Track Back': {
      'DMF': 95,
      'CMF': 85,
      'RB': 82,
      'LB': 82,
      'RWB': 80,
      'LWB': 80
    },
    'Interception': {'DMF': 95, 'CB': 90, 'CMF': 88, 'RB': 80, 'LB': 80},
    'Blocker': {'CB': 95, 'RB': 90, 'LB': 90, 'DMF': 85},
    'Aerial Superiority': {'CB': 95, 'CF': 85, 'GK': 80, 'DMF': 78},
    'Sliding Tackle': {'CB': 95, 'RB': 90, 'LB': 90, 'DMF': 88},
    'Acrobatic Clearance': {'CB': 92, 'RB': 88, 'LB': 88, 'GK': 85},
    'Captaincy': {'CB': 95, 'CMF': 92, 'GK': 88, 'DMF': 85, 'CF': 75},
    'Super-sub': {'CF': 88, 'SS': 92, 'RWF': 85, 'LWF': 85},
    'Fighting Spirit': {'CB': 90, 'CMF': 88, 'DMF': 90, 'GK': 88, 'CF': 75}
  };

  String? selectedPosition;
  final Set<String> selectedSkills = {};
  String validationMessage = '';

  int getCompatibility(String skill, String position) {
    final map = compatibility[skill];
    if (map != null && map.containsKey(position)) return map[position]!;

    // Estimate default based on type group
    if (position == 'GK') return 10;
    if (['CB', 'RB', 'LB', 'RWB', 'LWB', 'DMF'].contains(position)) return 40;
    if (['CF', 'SS', 'RWF', 'LWF', 'AMF'].contains(position)) return 70;
    return 55;
  }

  void toggleSkill(String skill) {
    setState(() {
      if (selectedSkills.contains(skill)) {
        selectedSkills.remove(skill);
      } else {
        if (selectedSkills.length >= 5) {
          validationMessage = 'Ko\'pi bilan 5 ta skill tanlash mumkin.';
          Future.delayed(const Duration(seconds: 2), () {
            setState(() => validationMessage = '');
          });
          return;
        }
        selectedSkills.add(skill);
      }
    });
  }

  Widget buildPositionChips() => Wrap(
        spacing: 8,
        runSpacing: 6,
        children: positions
            .map((pos) => ChoiceChip(
                  label: Text(pos),
                  selected: pos == selectedPosition,
                  onSelected: (_) => setState(() => selectedPosition = pos),
                ))
            .toList(),
      );

  Widget buildSkillChips() => Wrap(
        spacing: 8,
        runSpacing: 6,
        children: skills
            .map((s) => FilterChip(
                  label: Text(s, overflow: TextOverflow.ellipsis),
                  selected: selectedSkills.contains(s),
                  onSelected: (_) => toggleSkill(s),
                ))
            .toList(),
      );

  Widget buildSelectedSkillStats() {
    if (selectedPosition == null)
      return const Text('Iltimos pozitsiyani tanlang.');
    if (selectedSkills.isEmpty) return const Text('Kamida 2 ta skill tanlang.');

    final List<Widget> rows = [];
    for (final s in selectedSkills) {
      final pct = getCompatibility(s, selectedPosition!);
      rows.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Expanded(child: Text(s)), Text('$pct%')],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: pct / 100.0),
          const SizedBox(height: 12),
        ],
      ));
    }

    final avg = selectedSkills
            .map((s) => getCompatibility(s, selectedPosition!))
            .fold<int>(0, (a, b) => a + b) ~/
        selectedSkills.length;
    rows.add(const Divider());
    rows.add(Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text('O\'rta moslik: $avg%',
          style: const TextStyle(fontWeight: FontWeight.bold)),
    ));

    String interpretation;
    if (avg >= 85)
      interpretation =
          'Mukammal moslik — bu skill to\'plami aynan shu pozitsiyaga juda mos.';
    else if (avg >= 70)
      interpretation =
          'Yaxshi moslik — ko\'p hollarda bu skill pozitsiyaga foyda beradi.';
    else if (avg >= 50)
      interpretation =
          'O\'rtacha moslik — ba\'zi skilllar mos, ba\'zilari unchalik emas.';
    else
      interpretation = 'Past moslik — skilllar bu pozitsiya uchun samarasiz.';

    rows.add(Text(interpretation));
    return Column(children: rows);
  }

  void onAnalyzePressed() {
    setState(() {
      if (selectedSkills.length < 2) {
        validationMessage = 'Iltimos kamida 2 ta skill tanlang.';
        return;
      }
      if (selectedPosition == null) {
        validationMessage = 'Iltimos pozitsiyani tanlang.';
        return;
      }
      validationMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Pozitsiya va Skill tahlili')),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pozitsiyalar (bitta tanlanadi):',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                buildPositionChips(),
                const SizedBox(height: 16),
                const Text('Skillar (2–5 ta):',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                buildSkillChips(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton(
                        onPressed: onAnalyzePressed,
                        child: const Text('Tahlil qilish')),
                    const SizedBox(width: 12),
                    Text('Tanlanganlar: ${selectedSkills.length}/5'),
                  ],
                ),
                if (validationMessage.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(validationMessage,
                      style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 20),
                const Text('Moslik statistikasi:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                buildSelectedSkillStats(),
                const SizedBox(height: 24),
                const Text('Tahlil haqida:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                    'Bu tizim hozirda sinov tariqasida chiqarildi, bu tizim eFootball o\'yinidagi har bir skillning o\'yinchi pozitsiyasiga haqiqiy moslik darajasini matematik va futbol IQ asosida hisoblaydi. Har bir skill o\'zining foydali kontekstiga ko\'ra (dribbling, pas, himoya yoki finishing) baholanadi.'),
              ],
            ),
          ),
        ),
      );
}


// USAGE:
// import 'package:your_app/pages/position_skill_page.dart';
// MaterialApp(home: PositionSkillPage());

// NOTE:
// - Edit `compatibility` map to tune exact percent values per skill and position.
// - The heuristic `getCompatibility` provides fallback values for skills not explicitly listed.
// - You can extend the UI: add export, save presets, or more detailed radar charts using third-party chart packages.