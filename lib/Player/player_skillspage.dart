import 'package:efinfo_beta/Player/SkillTabs.dart';
import 'package:efinfo_beta/additional/colors.dart';
import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class PlayerSkillsPage extends StatefulWidget {
  const PlayerSkillsPage({super.key});
  @override
  State<PlayerSkillsPage> createState() => _PlayerSkillsPageState();
}

class _PlayerSkillsPageState extends State<PlayerSkillsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: themeProvider.getTheme().scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Player Skills',
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        bottom: TabBar(
          indicatorColor: const Color(0xFF06DF5D),
          indicatorWeight: 3,
          dividerColor: dividerColor,
          dividerHeight: 0.5,
          labelColor: isDark ? Colors.white : Colors.black,
          unselectedLabelColor: isDark ? Colors.white38 : Colors.black38,
          labelStyle:
              GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
          controller: _tabController,
          tabs: const [
            Tab(text: 'Oddiy skillar'),
            Tab(text: 'Noyob skillar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          TabOne(),
          TabTwo(),
        ],
      ),
    );
  }
}
