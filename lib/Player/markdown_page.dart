import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

class MarkdownPage extends StatefulWidget {
  final String title;
  final String markdownPath;

  const MarkdownPage({
    super.key,
    required this.title,
    required this.markdownPath,
  });

  @override
  State<MarkdownPage> createState() => _MarkdownPageState();
}

class _MarkdownPageState extends State<MarkdownPage> {
  String content = "";

  @override
  void initState() {
    super.initState();
    loadMarkdown();
  }

  Future<void> loadMarkdown() async {
    final String data = await rootBundle.loadString(widget.markdownPath);
    setState(() {
      content = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        // backgroundColor: Colors.deepPurple,
      ),
      body: content.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Markdown(
              data: content,
              shrinkWrap: true,
              styleSheet: MarkdownStyleSheet(
                horizontalRuleDecoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFD7D7D7), // Rang
                      width: 1.5, // Qalinlik
                    ),
                  ),
                ),
                h1: const TextStyle(
                    wordSpacing: 5,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C2C)),
                h3: const TextStyle(
                    wordSpacing: 5,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C2C)),
                h2: const TextStyle(
                    wordSpacing: 5,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF117340)),
                p: GoogleFonts.notoColorEmoji(
                    letterSpacing: 0,
                    wordSpacing: 0,
                    fontSize: 16,
                    height: 1.5,
                    color: const Color(0xFF6E6E6E)),
              ),
            ),
    );
  }
}
