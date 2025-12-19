// import 'package:efinfo_beta/theme/app_colors.dart';
// import 'package:flutter/material.dart';

// class PositionSkillPage extends StatefulWidget {
//   const PositionSkillPage({super.key});

//   @override
//   State<PositionSkillPage> createState() => _PositionSkillPageState();
// }

// class _PositionSkillPageState extends State<PositionSkillPage> {
//   // Football positions
//   final List<String> positions = [
//     'CF',
//     'SS',
//     'RWF',
//     'LWF',
//     'AMF',
//     'RMF',
//     'LMF',
//     'CMF',
//     'DMF',
//     'RB(Defensive)',
//     'RB(Attacking)',
//     'LB(Defensive)',
//     'LB(Attacking)',
//     'CB',
//     'RWB',
//     'LWB',
//     'GK'
//   ];

//   // eFootball skills list
//   final List<String> skills = [
//     'Scissors Feint',
//     'Double Touch',
//     'Flip Flap',
//     'Marseille Turn',
//     'Sombrero',
//     'Chop Turn',
//     'Cut Behind & Turn',
//     'Scotch Move',
//     'Sole Control',
//     'Heading',
//     'Long-range Curler',
//     'Chip Shot Control',
//     'Knuckle Shot',
//     'Dipping Shot',
//     'Rising Shot',
//     'Long-range Shooting',
//     'Acrobatic Finishing',
//     'Heel Trick',
//     'First-time Shot',
//     'One-touch Pass',
//     'Through Passing',
//     'Weighted Pass',
//     'Pinpoint Crossing',
//     'Outside Curler',
//     'Rabona',
//     'No Look Pass',
//     'Low Lofted Pass',
//     'Long Throw',
//     'Penalty Specialist',
//     'Gamesmanship',
//     'Man Marking',
//     'Track Back',
//     'Interception',
//     'Blocker',
//     'Aerial Superiority',
//     'Sliding Tackle',
//     'Acrobatic Clearance',
//     'Captaincy',
//     'Super-sub',
//     'Fighting Spirit',
//     'GK Low Punt',
//     'GK High Punt',
//     'GK Long Throw',
//     'GK Penalty Saver'
//   ];

//   // Personal Preference Skills (Purple Category)
//   final Set<String> _personalPreference = {
//     'Knuckle Shot',
//     'Dipping Shot',
//     'Rising Shot',
//     'Double Touch',
//     'Sole Control',
//     'Flip Flap',
//     'Marseille Turn',
//     'Cut Behind & Turn',
//     'Scissors Feint',
//     'Chop Turn',
//     'Scotch Move',
//     'Rabona',
//     'Sombrero'
//   };

//   // Logic map based on the provided matrix
//   // 100: Must-have (Blue)
//   // 80: Useful (Green)
//   // 60: Useful, not necessary (Yellow)
//   // 20: Not necessary (Red)
//   // 0: Do not give (Black/Grey) or Unlisted
//   late final Map<String, Map<String, int>> _positionRequirements = {
//     // CF / SS (Mapped to CF logic)
//     'CF': _buildScores(
//       mustHave: [
//         'First-time Shot',
//         'Long-range Shooting',
//         'Long-range Curler',
//         'One-touch Pass',
//         'Outside Curler',
//         'Fighting Spirit',
//         'Super-sub'
//       ],
//       useful: ['Through Passing', 'Chip Shot Control', 'Heading', 'Heel Trick'],
//       usefulNotNecessary: [
//         'Acrobatic Finishing',
//         'Gamesmanship',
//         'Aerial Superiority'
//       ],
//     ),
//     'SS': _buildScores(
//       mustHave: [
//         'First-time Shot',
//         'Long-range Shooting',
//         'Long-range Curler',
//         'One-touch Pass',
//         'Outside Curler',
//         'Fighting Spirit',
//         'Super-sub'
//       ],
//       useful: ['Through Passing', 'Chip Shot Control', 'Heading', 'Heel Trick'],
//       usefulNotNecessary: [
//         'Acrobatic Finishing',
//         'Gamesmanship',
//         'Aerial Superiority'
//       ],
//     ),

//     // L/RWF
//     'LWF': _buildScores(
//       mustHave: [
//         'Through Passing',
//         'One-touch Pass',
//         'Long-range Shooting',
//         'Long-range Curler',
//         'First-time Shot',
//         'Super-sub',
//         'Pinpoint Crossing',
//         'Outside Curler'
//       ],
//       useful: [
//         'Heel Trick',
//         'Gamesmanship',
//         'Fighting Spirit',
//         'Track Back',
//         'Weighted Pass',
//         'Chip Shot Control'
//       ],
//     ),
//     'RWF': _buildScores(
//       mustHave: [
//         'Through Passing',
//         'One-touch Pass',
//         'Long-range Shooting',
//         'Long-range Curler',
//         'First-time Shot',
//         'Super-sub',
//         'Pinpoint Crossing',
//         'Outside Curler'
//       ],
//       useful: [
//         'Heel Trick',
//         'Gamesmanship',
//         'Fighting Spirit',
//         'Track Back',
//         'Weighted Pass',
//         'Chip Shot Control'
//       ],
//     ),

//     // AMF
//     'AMF': _buildScores(
//       mustHave: [
//         'One-touch Pass',
//         'Through Passing',
//         'Long-range Shooting',
//         'Long-range Curler',
//         'Outside Curler',
//         'Super-sub'
//       ],
//       useful: [
//         'First-time Shot',
//         'Heel Trick',
//         'Fighting Spirit',
//         'Gamesmanship',
//         'Pinpoint Crossing',
//         'Weighted Pass',
//         'Chip Shot Control'
//       ],
//       notNecessary: ['Track Back'],
//     ),

//     // L/RMF
//     'LMF': _buildScores(
//       mustHave: [
//         'One-touch Pass',
//         'Through Passing',
//         'Pinpoint Crossing',
//         'Outside Curler',
//         'Heel Trick',
//         'Track Back'
//       ],
//       useful: ['Interception', 'Gamesmanship', 'Fighting Spirit'],
//       usefulNotNecessary: [
//         'Long-range Shooting',
//         'Long-range Curler',
//         'Weighted Pass',
//         'First-time Shot'
//       ],
//       notNecessary: ['Super-sub'],
//     ),
//     'RMF': _buildScores(
//       mustHave: [
//         'One-touch Pass',
//         'Through Passing',
//         'Pinpoint Crossing',
//         'Outside Curler',
//         'Heel Trick',
//         'Track Back'
//       ],
//       useful: ['Interception', 'Gamesmanship', 'Fighting Spirit'],
//       usefulNotNecessary: [
//         'Long-range Shooting',
//         'Long-range Curler',
//         'Weighted Pass',
//         'First-time Shot'
//       ],
//       notNecessary: ['Super-sub'],
//     ),

//     // CMF
//     'CMF': _buildScores(
//       mustHave: [
//         'One-touch Pass',
//         'Through Passing',
//         'Interception',
//         'Outside Curler',
//         'Heel Trick'
//       ],
//       useful: [
//         'Long-range Shooting',
//         'Long-range Curler',
//         'Weighted Pass',
//         'Track Back',
//         'Fighting Spirit',
//         'Sliding Tackle',
//         'Aerial Superiority'
//       ],
//       usefulNotNecessary: ['First-time Shot'],
//       notNecessary: ['Super-sub'],
//     ),

//     // DMF
//     'DMF': _buildScores(
//       mustHave: [
//         'Interception',
//         'One-touch Pass',
//         'Through Passing',
//         'Man Marking',
//         'Blocker',
//         'Sliding Tackle',
//         'Acrobatic Clearance',
//         'Aerial Superiority'
//       ],
//       useful: ['Weighted Pass', 'Heading', 'Outside Curler'],
//       usefulNotNecessary: ['Track Back'],
//       notNecessary: ['Fighting Spirit', 'Super-sub'],
//     ),

//     // RB / LB / RWB / LWB (Using Attacking L/RB logic)
//     'RB(Defensive)': _buildDefBackScores(),
//     'LB(Defensive)': _buildDefBackScores(),
//     'RWB(Defensive)': _buildDefBackScores(),
//     'LWB(Defensive)': _buildDefBackScores(),
//     'RB(Attacking)': _buildAttBackScores(),
//     'LB(Attacking)': _buildAttBackScores(),
//     'RWB(Attacking)': _buildAttBackScores(),
//     'LWB(Attacking)': _buildAttBackScores(),

//     // CB
//     'CB': _buildScores(
//       mustHave: [
//         'Interception',
//         'Man Marking',
//         'Blocker',
//         'Aerial Superiority',
//         'Acrobatic Clearance',
//         'Sliding Tackle',
//         'Heading'
//       ],
//       useful: ['Weighted Pass', 'One-touch Pass', 'Through Passing'],
//       usefulNotNecessary: ['Low Lofted Pass'],
//       notNecessary: ['Fighting Spirit'],
//       doNotGive: ['Track Back', 'Super-sub'],
//     ),

//     // GK
//     'GK': _buildScores(
//       mustHave: ['GK Low Punt', 'GK Long Throw', 'GK Penalty Saver'],
//       useful: ['Weighted Pass', 'GK High Punt', 'One-touch Pass'],
//       usefulNotNecessary: ['Through Passing', 'Low Lofted Pass'],
//       notNecessary: ['Fighting Spirit'],
//       doNotGive: ['Super-sub'],
//     ),
//   };

//   Map<String, int> _buildScores({
//     List<String> mustHave = const [],
//     List<String> useful = const [],
//     List<String> usefulNotNecessary = const [],
//     List<String> notNecessary = const [],
//     List<String> doNotGive = const [],
//   }) {
//     final Map<String, int> scores = {};
//     for (var s in mustHave) {
//       scores[s] = 100;
//     }
//     for (var s in useful) {
//       scores[s] = 80;
//     }
//     for (var s in usefulNotNecessary) {
//       scores[s] = 60;
//     }
//     for (var s in notNecessary) {
//       scores[s] = 20;
//     }
//     for (var s in doNotGive) {
//       scores[s] = 0;
//     }
//     return scores;
//   }

//   Map<String, int> _buildDefBackScores() {
//     return _buildScores(
//       mustHave: [
//         'Interception',
//         'One-touch Pass',
//         'Pinpoint Crossing',
//         'Through Passing',
//         'Blocker',
//         'Man Marking',
//         'Acrobatic Clearance',
//         'Track Back',
//         'Sliding Tackle',
//         'Aerial Superiority'
//       ],
//       useful: ['Heading'],
//       usefulNotNecessary: ['Weighted Pass', 'Fighting Spirit'],
//       doNotGive: ['Super-sub'],
//     );
//   }

//   Map<String, int> _buildAttBackScores() {
//     return _buildScores(
//       mustHave: [
//         'Interception',
//         'One-touch Pass',
//         'Pinpoint Crossing',
//         'Through Passing',
//       ],
//       useful: [
//         'Blocker',
//         'Man Marking',
//         'Acrobatic Clearance',
//         'Track Back',
//         'Sliding Tackle'
//       ],
//       usefulNotNecessary: [
//         'Weighted Pass',
//         'Aerial Superiority',
//         'Heading',
//       ],
//       notNecessary: [
//         'Fighting Spirit',
//       ],
//       doNotGive: ['Super-sub'],
//     );
//   }

//   String? selectedPosition;
//   final Set<String> selectedSkills = {};
//   String validationMessage = '';

//   // Get compatibility percentage
//   int getCompatibility(String skill, String position) {
//     // 1. Check specific matrix score
//     final posStats = _positionRequirements[position];
//     if (posStats != null && posStats.containsKey(skill)) {
//       return posStats[skill]!;
//     }

//     // 2. Check Personal Preference (Purple Category)
//     // Generally useful for non-defenders (Attackers + Midfielders)
//     if (_personalPreference.contains(skill)) {
//       if (['CF', 'SS', 'LWF', 'RWF', 'AMF', 'LMF', 'RMF', 'CMF']
//           .contains(position)) {
//         return 75; // "Good/Personal Preference"
//       }
//       return 0; // Not recommended for pure defenders/GK
//     }

//     // 3. Fallback for unlisted skills
//     return 0;
//   }

//   void toggleSkill(String skill) {
//     setState(() {
//       if (selectedSkills.contains(skill)) {
//         selectedSkills.remove(skill);
//       } else {
//         if (selectedSkills.length >= 5) {
//           validationMessage = 'Maksimal 5 ta skill tanlash mumkin!';
//           Future.delayed(const Duration(seconds: 2), () {
//             if (mounted) setState(() => validationMessage = '');
//           });
//           return;
//         }
//         selectedSkills.add(skill);
//       }
//     });
//   }

//   void _clearAll() {
//     setState(() {
//       selectedSkills.clear();
//       validationMessage = '';
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: const Text('Skill Moslik Hisoblagich',
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//         backgroundColor: AppColors.background,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//         actions: [
//           IconButton(
//               onPressed: _clearAll,
//               icon: const Icon(Icons.refresh, color: Colors.white70))
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // Position Section
//             const Padding(
//               padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text('1. Pozitsiyani tanlang',
//                     style: TextStyle(
//                         color: AppColors.accent,
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold)),
//               ),
//             ),
//             SizedBox(
//               height: 60,
//               child: ListView.separated(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 scrollDirection: Axis.horizontal,
//                 itemCount: positions.length,
//                 separatorBuilder: (_, __) => const SizedBox(width: 8),
//                 itemBuilder: (context, index) {
//                   final pos = positions[index];
//                   bool isSelected = selectedPosition == pos;
//                   return ChoiceChip(
//                     label: Text(pos),
//                     selected: isSelected,
//                     onSelected: (bool selected) {
//                       setState(() {
//                         selectedPosition = pos;
//                       });
//                     },
//                     backgroundColor: AppColors.cardSurface,
//                     selectedColor: AppColors.accent,
//                     labelStyle: TextStyle(
//                         color: isSelected ? Colors.white : Colors.white70,
//                         fontWeight:
//                             isSelected ? FontWeight.bold : FontWeight.normal),
//                     side: BorderSide.none,
//                   );
//                 },
//               ),
//             ),

//             // Skills Section
//             Padding(
//               padding: const EdgeInsets.only(
//                   left: 16, top: 16, bottom: 8, right: 16),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text('2. Skillarni tanlang (${selectedSkills.length}/5)',
//                       style: const TextStyle(
//                           color: AppColors.accent,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold)),
//                   if (validationMessage.isNotEmpty)
//                     Text(validationMessage,
//                         style: const TextStyle(
//                             color: Colors.redAccent, fontSize: 12)),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: AppColors.cardSurface,
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Wrap(
//                   spacing: 8,
//                   runSpacing: 8,
//                   children: skills.map((s) {
//                     bool isSelected = selectedSkills.contains(s);
//                     return FilterChip(
//                       label: Text(s),
//                       selected: isSelected,
//                       onSelected: (_) => toggleSkill(s),
//                       backgroundColor: Colors.white10,
//                       selectedColor: AppColors.accent.withOpacity(0.8),
//                       checkmarkColor: Colors.white,
//                       labelStyle: TextStyle(
//                           color: isSelected ? Colors.white : Colors.white70,
//                           fontSize: 12),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20),
//                           side: BorderSide.none),
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 20),

//             // Analysis Section
//             if (selectedPosition != null && selectedSkills.isNotEmpty)
//               _buildAnalysisResult(),

//             const SizedBox(height: 40),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAnalysisResult() {
//     // Calculate Average
//     int total = selectedSkills.fold(
//         0, (sum, s) => sum + getCompatibility(s, selectedPosition!));
//     double avg = total / selectedSkills.length;
//     Color scoreColor = avg >= 90
//         ? Colors.cyanAccent
//         : (avg >= 80
//             ? Colors.green
//             : (avg >= 50 ? Colors.orange : Colors.redAccent));
//     String verdict = avg >= 90
//         ? "Mukammal Moslik! 🔥"
//         : (avg >= 80
//             ? "Juda Yaxshi Tanlov ✅"
//             : (avg >= 50 ? "O'rtacha ⚠️" : "Tavsiya etilmaydi ❌"));

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('Tahlil Natijasi',
//               style: TextStyle(
//                   color: AppColors.accent,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold)),
//           const SizedBox(height: 10),
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//                 gradient: LinearGradient(colors: [
//                   AppColors.accent.withOpacity(0.2),
//                   AppColors.cardSurface
//                 ], begin: Alignment.topLeft, end: Alignment.bottomRight),
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(color: AppColors.accent.withOpacity(0.3))),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text('Umumiy Reyting:',
//                         style: TextStyle(color: Colors.white70)),
//                     Text('${avg.toStringAsFixed(1)}%',
//                         style: TextStyle(
//                             color: scoreColor,
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold)),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Text(verdict,
//                     style: TextStyle(
//                         color: scoreColor,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold)),
//                 const Divider(color: Colors.white12, height: 30),
//                 ...selectedSkills.map((s) {
//                   int score = getCompatibility(s, selectedPosition!);
//                   Color barColor = score >= 90
//                       ? Colors.cyanAccent
//                       : (score >= 80
//                           ? Colors.green
//                           : (score >= 50 ? Colors.orange : Colors.redAccent));
//                   String status = "Yaxshi";
//                   // Custom status text based on score can be refined
//                   if (score >= 95) {
//                     status = "Berilishi kerak";
//                   } else if (score >= 80) {
//                     status = "Foydali";
//                   } else if (score <= 20) {
//                     status = "Kerak emas";
//                   } else if (score <= 50) {
//                     status = "Tavsiya etilmaydi";
//                   }

//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 12),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(s,
//                                 style: const TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.w500)),
//                             Row(
//                               children: [
//                                 Text(status,
//                                     style: const TextStyle(
//                                         color: Colors.white54, fontSize: 10)),
//                                 const SizedBox(width: 8),
//                                 Text('$score%',
//                                     style: TextStyle(
//                                         color: barColor,
//                                         fontWeight: FontWeight.bold)),
//                               ],
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 6),
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(4),
//                           child: LinearProgressIndicator(
//                             value: score / 100,
//                             backgroundColor: Colors.white10,
//                             valueColor: AlwaysStoppedAnimation(barColor),
//                             minHeight: 6,
//                           ),
//                         )
//                       ],
//                     ),
//                   );
//                 }),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
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

  // Full eFootball skills list
  final List<String> skills = [
    // Shooting
    'First-time Shot',
    'Long-range Shooting',
    'Long-range Curler',
    'Chip Shot Control',
    'Acrobatic Finishing',
    'Knuckle Shot',
    'Dipping Shot',
    'Rising Shot',
    'Penalty Specialist',

    // Dribbling
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

    // Passing
    'One-touch Pass',
    'Through Passing',
    'Weighted Pass',
    'Pinpoint Crossing',
    'Outside Curler',
    'Low Lofted Pass',
    'No Look Pass',
    'Rabona',

    // Defending
    'Interception',
    'Man Marking',
    'Blocker',
    'Track Back',
    'Sliding Tackle',
    'Acrobatic Clearance',

    // Physical / Mental
    'Heading',
    'Aerial Superiority',
    'Fighting Spirit',
    'Super-sub',
    'Captaincy',
    'Gamesmanship',
    'Long Throw',

    // GK
    'GK Low Punt',
    'GK High Punt',
    'GK Long Throw',
    'GK Penalty Saver'
  ];

  // Personal Preference Skills (Purple Category in Image)
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

  // Grey Category (Not worth adding generally)
  final Set<String> _notWorthAdding = {
    'No Look Pass',
    'Long Throw',
    'Penalty Specialist',
    'Captaincy' // Added conditionally in logic, but generally grey
  };

  late final Map<String, Map<String, int>> _positionRequirements;

  @override
  void initState() {
    super.initState();
    _initRequirements();
  }

  void _initRequirements() {
    // Score Key:
    // 100: Must-have (Blue)
    // 80: Useful (Green)
    // 60: Useful, not necessary (Yellow)
    // 20: Not necessary (Red)
    // 0: Do not give (Black)

    final cfLogic = _buildScores(
      mustHave: [
        'First-time Shot',
        'Long-range Shooting',
        'Long-range Curler',
        'One-touch Pass',
        'Outside Curler',
        'Fighting Spirit',
        'Super-sub'
      ],
      useful: ['Through Passing', 'Chip Shot Control', 'Heading', 'Heel Trick'],
      usefulNotNecessary: [
        'Acrobatic Finishing',
        'Gamesmanship',
        'Aerial Superiority'
      ],
      notNecessary: ['Track Back', 'Weighted Pass'], // From image context
    );

    final wingerLogic = _buildScores(
      mustHave: [
        'Through Passing',
        'One-touch Pass',
        'Long-range Shooting',
        'Long-range Curler',
        'First-time Shot',
        'Super-sub',
      ],
      useful: [
        'Pinpoint Crossing',
        'Outside Curler'
            'Heel Trick',
        'Gamesmanship',
        'Weighted Pass',
        'Chip Shot Control'
      ],
      usefulNotNecessary: ['Fighting Spirit', 'Track Back'],
    );

    final sideMidLogic = _buildScores(
      mustHave: [
        'One-touch Pass',
        'Through Passing',
        'Pinpoint Crossing',
        'Outside Curler',
      ],
      useful: [
        'Heel Trick',
        'Track Back'
            'Interception',
      ],
      usefulNotNecessary: [
        'Gamesmanship',
        'Fighting Spirit',
        'Long-range Shooting',
        'Long-range Curler'
      ],
      doNotGive: ['First-time Shot', 'Weighted Pass'],
    );

    final attDefLogic = _buildScores(
      mustHave: [
        'Interception',
        'One-touch Pass',
        'Pinpoint Crossing',
        'Through Passing',
      ],
      useful: [
        'Blocker'
            'Acrobatic Clearance',
        'Man Marking',
        'Track Back',
        'Sliding Tackle',
        'Fighting Spirit'
      ],
      usefulNotNecessary: [
        'Aerial Superiority',
        'Heading',
        'Weighted Pass',
      ],
      notNecessary: [
        'Fighting Spirit',
      ],
      doNotGive: ['Super-sub'],
    );

    final defDefLogic = _buildScores(
      mustHave: [
        'Interception',
        'Man Marking',
        'Blocker',
        'Aerial Superiority',
        'Acrobatic Clearance',
        'Sliding Tackle',
      ],
      useful: [
        'Heading',
        'One-touch Pass',
        'Through Passing',
        'Weighted Pass',
        'Low Lofted Pass'
      ],
      usefulNotNecessary: [
        'Pinpoint Crossing',
      ],
      notNecessary: ['Fighting Spirit'],
      doNotGive: ['Track Back', 'Super-sub'],
    );

    _positionRequirements = {
      'CF': cfLogic,
      'SS': cfLogic, // SS usually matches CF logic

      'LWF': wingerLogic,
      'RWF': wingerLogic,

      'AMF': _buildScores(
        mustHave: [
          'One-touch Pass',
          'Through Passing',
          'Long-range Shooting',
          'Long-range Curler',
          'Outside Curler',
          'Super-sub'
        ],
        useful: [
          'First-time Shot',
          'Heel Trick',
          'Gamesmanship',
          'Fighting Spirit',
        ],
        usefulNotNecessary: [
          'Pinpoint Crossing',
          'Weighted Pass',
        ],
        notNecessary: ['Track Back', 'Chip Shot Control'],
      ),

      'LMF': sideMidLogic,
      'RMF': sideMidLogic,

      'CMF': _buildScores(
        mustHave: [
          'One-touch Pass',
          'Through Passing',
          'Interception',
        ],
        useful: [
          'Outside Curler',
          'Heel Trick',
          'Long-range Shooting',
          'Long-range Curler',
          'Weighted Pass',
          'Track Back',
        ],
        usefulNotNecessary: [
          'Fighting Spirit',
          'Sliding Tackle',
          'Aerial Superiority',
          'First-time Shot'
        ],
        notNecessary: ['Super-sub'],
      ),

      'DMF': _buildScores(
        mustHave: [
          'Interception',
          'One-touch Pass',
          'Through Passing',
          'Man Marking',
          'Blocker'
        ],
        useful: [
          'Sliding Tackle',
          'Acrobatic Clearance',
          'Aerial Superiority',
          'Weighted Pass',
          'Heading',
        ],
        usefulNotNecessary: [
          'Track Back',
          'Outside Curler'
        ], // Anchor Man note in image
        notNecessary: ['Fighting Spirit'],
        doNotGive: ['Super-sub'],
      ),

      'Attacking RB': attDefLogic,
      'Attacking LB': attDefLogic,
      'Defensive RB': defDefLogic,
      'Defensive LB': defDefLogic,

      'CB': _buildScores(
        mustHave: [
          'Interception',
          'Man Marking',
          'Blocker',
          'Aerial Superiority',
          'Acrobatic Clearance',
          'Sliding Tackle',
          'Heading'
        ],
        useful: [
          'Weighted Pass',
        ],
        usefulNotNecessary: [
          'One-touch Pass',
          'Through Passing',
          'Low Lofted Pass'
        ],
        notNecessary: ['Fighting Spirit'],
        doNotGive: ['Track Back', 'Super-sub'],
      ),

      'GK': _buildScores(
        mustHave: ['GK Low Punt', 'GK Long Throw', 'GK Penalty Saver'],
        useful: ['Weighted Pass', 'GK High Punt', 'One-touch Pass'],
        usefulNotNecessary: ['Through Passing', 'Low Lofted Pass'],
        notNecessary: ['Fighting Spirit'],
        doNotGive: ['Super-sub'],
      ),
    };
  }

  Map<String, int> _buildScores({
    List<String> mustHave = const [],
    List<String> useful = const [],
    List<String> usefulNotNecessary = const [],
    List<String> notNecessary = const [],
    List<String> doNotGive = const [],
  }) {
    final Map<String, int> scores = {};
    for (var s in mustHave) scores[s] = 100;
    for (var s in useful) scores[s] = 80;
    for (var s in usefulNotNecessary) scores[s] = 60;
    for (var s in notNecessary) scores[s] = 20;
    for (var s in doNotGive) scores[s] = 0;
    return scores;
  }

  String? selectedPosition;
  final Set<String> selectedSkills = {};
  String validationMessage = '';

  // Logic to determine compatibility based on image logic
  int getCompatibility(String skill, String position) {
    // 1. Check Explicit Definition in Map
    final posStats = _positionRequirements[position];
    if (posStats != null && posStats.containsKey(skill)) {
      return posStats[skill]!;
    }

    // 2. Check "Do Not Give" (Black) implied or Grey (Not Worth)
    if (_notWorthAdding.contains(skill)) {
      return 10; // Very low score
    }

    // 3. Check Personal Preference (Purple)
    // Useful for CF, SS, Wingers, AMF, LMF, RMF, CMF
    // Not recommended for CB, DMF, GK
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
        return 70; // Personal Preference Score (Good but optional)
      } else {
        return 0; // Don't give flip flap to a CB
      }
    }

    // 4. Fallback
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
            // Position Selector
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
                        // Clear skills if position changes to avoid confusion?
                        // Optional: selectedSkills.clear();
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

            // Skills Selector
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

            // Chips Container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
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

            // Analysis Result
            if (selectedPosition != null && selectedSkills.isNotEmpty)
              _buildAnalysisResult(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisResult() {
    int total = selectedSkills.fold(
        0, (sum, s) => sum + getCompatibility(s, selectedPosition!));
    double avg = total / selectedSkills.length;

    // Determine Color based on score
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
                    Text('${avg.toStringAsFixed(0)}%',
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

                // Individual Skill Breakdown
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
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500)),
                            Row(
                              children: [
                                Text(statusText,
                                    style: TextStyle(
                                        color: barColor.withOpacity(0.8),
                                        fontSize: 10)),
                                const SizedBox(width: 8),
                                Text('$score',
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
