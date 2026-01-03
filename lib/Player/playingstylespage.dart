import 'dart:convert';

import 'package:efinfo_beta/Others/markdown_page.dart';
import 'package:efinfo_beta/models/playing_styles.dart';
import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:efinfo_beta/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class PlayingStylePage extends StatefulWidget {
  const PlayingStylePage({super.key});

  @override
  State<PlayingStylePage> createState() => _PlayingStylePageState();
}

class _PlayingStylePageState extends State<PlayingStylePage> {
  List<PlayingStyle> playingStyles = [];
  List<PlayingStyle> filteredStyles = [];
  final TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    loadPlayingStyles();
  }

  Future<void> loadPlayingStyles() async {
    final String response =
        await rootBundle.loadString('assets/data/playing_styles.json');
    final data = json.decode(response) as List;
    setState(() {
      playingStyles = data.map((item) => PlayingStyle.fromJson(item)).toList();
      filteredStyles = playingStyles;
    });
  }

  void filterSearch(String query) {
    final results = playingStyles.where((style) {
      final titleLower = style.title.toLowerCase();
      final queryLower = query.toLowerCase();
      return titleLower.contains(queryLower);
    }).toList();

    setState(() {
      filteredStyles = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: themeProvider.getTheme().scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Playing Styles",
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: playingStyles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/pl_stylepic.jpg',
                      ),
                    ),
                  ),
                  // 🔹 Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
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
                            color: isDark ? Colors.white54 : Colors.black54),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.05),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredStyles.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final style = filteredStyles[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: GlassContainer(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                style.title,
                                style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color:
                                        isDark ? Colors.white : Colors.black),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                style.description,
                                style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black87),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Mos pozitsiyalar: ",
                                style: GoogleFonts.outfit(
                                    color: const Color(0xFF06DF5D),
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color:
                                      const Color(0xFF06DF5D).withOpacity(0.1),
                                  border: Border.all(
                                      color: const Color(0xFF06DF5D)
                                          .withOpacity(0.3)),
                                ),
                                child: Text(
                                  style.compatiblePositions,
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF06DF5D),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF06DF5D),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MarkdownPage(
                                          title: style.title,
                                          markdownPath: style.data,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text("Ko'proq o'qish",
                                      style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
