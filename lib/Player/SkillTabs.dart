import 'dart:convert';
import 'package:efinfo_beta/Player/playerskills_show.dart';
import 'package:efinfo_beta/models/player_skills.dart';
import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:efinfo_beta/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class TabOne extends StatefulWidget {
  const TabOne({super.key});

  @override
  State<TabOne> createState() => _TabOneState();
}

class _TabOneState extends State<TabOne> {
  List<PlayerSkills> playerSkills = [];
  List<PlayerSkills> filteredSkills = [];
  final TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    loadPlayingStyles();
  }

  Future<void> loadPlayingStyles() async {
    final String response =
        await rootBundle.loadString('assets/data/player_skills.json');
    final data = json.decode(response) as List;
    setState(() {
      playerSkills = data.map((item) => PlayerSkills.fromJson(item)).toList();
      filteredSkills = playerSkills;
    });
  }

  void filterSearch(String query) {
    final results = playerSkills.where((style) {
      final titleLower = style.title.toLowerCase();
      final queryLower = query.toLowerCase();
      return titleLower.contains(queryLower);
    }).toList();

    setState(() {
      filteredSkills = results;
    });
  }

  Map<String, List<PlayerSkills>> _groupSkills(List<PlayerSkills> skills) {
    final shooting = [
      'Heading',
      'Long-range Curler',
      'Chip Shot Control',
      'Knuckle Shot',
      'Dipping Shot',
      'Rising Shot',
      'Long-range Shooting',
      'Acrobatic Finishing',
      'First-time Shot',
      'Penalty Specialist'
    ];
    final passing = [
      'One-touch Pass',
      'Through Passing',
      'Weighted Pass',
      'Pinpoint Crossing',
      'Outside Curler',
      'No Look Pass',
      'Low Lofted Pass',
      'Heel Trick'
    ];
    final dribbling = [
      'Scissors Feint',
      'Double Touch',
      'Flip Flap',
      'Marseille Turn',
      'Sombrero',
      'Chop Turn',
      'Cut Behind & Turn',
      'Scotch Move',
      'Sole Control',
      'Rabona'
    ];
    final defending = [
      'Man Marking',
      'Track Back',
      'Interception',
      'Blocker',
      'Aerial Superiority',
      'Sliding Tackle',
      'Acrobatic Clearance'
    ];

    Map<String, List<PlayerSkills>> groups = {
      'Shooting': [],
      'Passing': [],
      'Dribbling': [],
      'Defending': [],
      'Other': [],
    };

    for (var skill in skills) {
      if (shooting.contains(skill.title)) {
        groups['Shooting']!.add(skill);
      } else if (passing.contains(skill.title)) {
        groups['Passing']!.add(skill);
      } else if (dribbling.contains(skill.title)) {
        groups['Dribbling']!.add(skill);
      } else if (defending.contains(skill.title)) {
        groups['Defending']!.add(skill);
      } else {
        groups['Other']!.add(skill);
      }
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final groupedSkills = _groupSkills(filteredSkills);

    return playerSkills.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GlassContainer(
                  padding: EdgeInsets.zero,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/images/pl_skillspic.jpg',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // 🔹 Search bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: GlassContainer(
                  padding: EdgeInsets.zero,
                  child: TextField(
                    controller: searchController,
                    onChanged: filterSearch,
                    style: GoogleFonts.outfit(
                        color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Qidirish...',
                      hintStyle: GoogleFonts.outfit(
                          color: isDark ? Colors.white38 : Colors.black38),
                      prefixIcon: Icon(Icons.search,
                          color: isDark ? Colors.white38 : Colors.black38),
                      filled: false,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              ...groupedSkills.entries
                  .where((e) => e.value.isNotEmpty)
                  .map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 16, 8),
                      child: Text(
                        entry.key,
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF06DF5D),
                        ),
                      ),
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: entry.value.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final style = entry.value[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: GlassContainer(
                            padding: const EdgeInsets.all(12),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlayerSkillsShow(
                                      text: style.full_description,
                                      image: style.image,
                                      title: style.title,
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color:
                                          (isDark ? Colors.white : Colors.black)
                                              .withOpacity(0.05),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: Image.asset(
                                      style.image,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          style.title,
                                          style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          style.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.outfit(
                                            fontSize: 13,
                                            color: isDark
                                                ? Colors.white70
                                                : Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              }).toList(),
              const SizedBox(height: 100),
            ],
          );
  }
}

class TabTwo extends StatefulWidget {
  const TabTwo({super.key});

  @override
  State<TabTwo> createState() => _TabTwoState();
}

class _TabTwoState extends State<TabTwo> {
  List<PlayerSkills> playerSkills = [];
  List<PlayerSkills> filteredSkills = [];
  final TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    loadPlayingStyles();
  }

  Future<void> loadPlayingStyles() async {
    final String response =
        await rootBundle.loadString('assets/data/unical_skills.json');
    final data = json.decode(response) as List;
    setState(() {
      playerSkills = data.map((item) => PlayerSkills.fromJson(item)).toList();
      filteredSkills = playerSkills;
    });
  }

  void filterSearch(String query) {
    final results = playerSkills.where((style) {
      final titleLower = style.title.toLowerCase();
      final queryLower = query.toLowerCase();
      return titleLower.contains(queryLower);
    }).toList();

    setState(() {
      filteredSkills = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return playerSkills.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GlassContainer(
                  padding: EdgeInsets.zero,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/images/unical_skills.jpg',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // 🔹 Search bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: GlassContainer(
                  padding: EdgeInsets.zero,
                  child: TextField(
                    controller: searchController,
                    onChanged: filterSearch,
                    style: GoogleFonts.outfit(
                        color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Qidirish...',
                      hintStyle: GoogleFonts.outfit(
                          color: isDark ? Colors.white38 : Colors.black38),
                      prefixIcon: Icon(Icons.search,
                          color: isDark ? Colors.white38 : Colors.black38),
                      filled: false,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              if (filteredSkills.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      "Ko'nikmalar topilmadi",
                      style: GoogleFonts.outfit(color: Colors.grey),
                    ),
                  ),
                ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredSkills.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final style = filteredSkills[index];

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: GlassContainer(
                      padding: const EdgeInsets.all(12),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlayerSkillsShow(
                                text: style.full_description,
                                image: style.image,
                                title: style.title,
                              ),
                            ),
                          );
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: (isDark ? Colors.white : Colors.black)
                                    .withOpacity(0.05),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Image.asset(
                                style.image,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    style.title,
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color:
                                          isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    style.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 100),
            ],
          );
  }
}
