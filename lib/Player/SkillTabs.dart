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
                              width: 100,
                              height: 100,
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
                                      fontSize: 18,
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
                                      fontSize: 14,
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
                              width: 100,
                              height: 100,
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
                                      fontSize: 18,
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
                                      fontSize: 14,
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
