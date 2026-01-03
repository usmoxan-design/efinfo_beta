import 'dart:convert';
import 'package:efinfo_beta/models/positionsmodel.dart';
import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:efinfo_beta/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class PositionsPage extends StatefulWidget {
  const PositionsPage({super.key});

  @override
  State<PositionsPage> createState() => _PositionsPageState();
}

class _PositionsPageState extends State<PositionsPage> {
  List<PositionsModel> playerPositions = [];
  List<PositionsModel> filteredPositions = [];
  @override
  void initState() {
    super.initState();
    loadPlayerPositions();
    print(filteredPositions.length);
  }

  Future<void> loadPlayerPositions() async {
    final String response =
        await rootBundle.loadString('assets/data/positions_list.json');
    final data = json.decode(response) as List;
    setState(() {
      playerPositions =
          data.map((item) => PositionsModel.fromJson(item)).toList();
      filteredPositions = playerPositions;
    });
  }

  void filterSearch(String query) {
    final results = playerPositions.where((style) {
      final titleLower = style.title.toLowerCase();
      final queryLower = query.toLowerCase();
      return titleLower.contains(queryLower);
    }).toList();

    setState(() {
      filteredPositions = results;
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
            "Pozitsiyalar",
            style: GoogleFonts.outfit(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        ),
        body: playerPositions.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/images/pl_positionpic.jpg',
                        ),
                      ),
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredPositions.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final style = filteredPositions[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: GlassContainer(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
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
                                          fontSize: 18,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        style.description,
                                        softWrap: true,
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
                        );
                      },
                    ),
                  ],
                ),
              ));
  }
}
