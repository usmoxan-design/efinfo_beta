import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          widget.title,
        ),
      ),
      body: Markdown(
        data: content,
        // selectable: true,
        styleSheet: MarkdownStyleSheet(
          horizontalRuleDecoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFD7D7D7),
                width: 1.5,
              ),
            ),
          ),
          h1: const TextStyle(
              wordSpacing: 5,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C2C2C)),
          h2: const TextStyle(
              wordSpacing: 5,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF117340)),
          h3: const TextStyle(
              wordSpacing: 5,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C2C2C)),
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
