import 'dart:convert';
import 'package:efinfo_beta/Others/markdown_page.dart';
import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:efinfo_beta/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/mngr_plStyle.dart';

class ManagerStylesPage extends StatefulWidget {
  const ManagerStylesPage({super.key});

  @override
  State<ManagerStylesPage> createState() => _ManagerStylesPageState();
}

class _ManagerStylesPageState extends State<ManagerStylesPage> {
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
        await rootBundle.loadString('assets/data/mngr_pl_styles.json');
    final data = json.decode(response) as List;
    setState(() {
      playingStyles = data.map((item) => PlayingStyle.fromJson(item)).toList();
      filteredStyles = playingStyles;
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
          "Manager Playing Styles",
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
                        'assets/images/manager_pl_styles.jpg',
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
