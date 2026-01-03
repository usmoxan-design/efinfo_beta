import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PlayerSkillsShow extends StatefulWidget {
  const PlayerSkillsShow(
      {super.key,
      required this.text,
      required this.image,
      required this.title});
  final String text;
  final String title;
  final String image;

  @override
  State<PlayerSkillsShow> createState() => _PlayerSkillsShowState();
}

class _PlayerSkillsShowState extends State<PlayerSkillsShow> {
  String content = "";

  @override
  void initState() {
    super.initState();
    loadMarkdown();
  }

  Future<void> loadMarkdown() async {
    final String data = await rootBundle.loadString(widget.text);
    setState(() {
      content = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: themeProvider.getTheme().scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        title: Text(
          widget.title,
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Markdown(
        data: content,
        styleSheet: MarkdownStyleSheet(
          horizontalRuleDecoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.white10 : Colors.black12,
                width: 1.5,
              ),
            ),
          ),
          h1: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black),
          h2: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF06DF5D)),
          h3: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black),
          p: GoogleFonts.outfit(
              fontSize: 16,
              height: 1.6,
              color: isDark ? Colors.white70 : Colors.black87),
          listBullet: GoogleFonts.outfit(
              color: isDark ? Colors.white70 : Colors.black87),
        ),
      ),
    );
  }
}
