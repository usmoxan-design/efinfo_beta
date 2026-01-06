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

    List<PlayingStyle> attack = filteredStyles
        .where((s) =>
            s.compatiblePositions.contains('CF') ||
            s.compatiblePositions.contains('SS') ||
            s.compatiblePositions.contains('WF'))
        .toList();
    List<PlayingStyle> midfield = filteredStyles
        .where((s) =>
            s.compatiblePositions.contains('AMF') ||
            s.compatiblePositions.contains('MF'))
        .toList();
    List<PlayingStyle> defense = filteredStyles
        .where((s) =>
            s.compatiblePositions.contains('CB') ||
            s.compatiblePositions.contains('LB') ||
            s.compatiblePositions.contains('RB'))
        .toList();
    List<PlayingStyle> goalkeeper = filteredStyles
        .where((s) => s.compatiblePositions.contains('GK'))
        .toList();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: themeProvider.getTheme().scaffoldBackgroundColor,
        body: playingStyles.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      expandedHeight: 200,
                      pinned: true,
                      elevation: 0,
                      stretch: true,
                      backgroundColor:
                          themeProvider.getTheme().scaffoldBackgroundColor,
                      iconTheme: IconThemeData(
                          color: isDark ? Colors.white : Colors.black),
                      flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,
                        title: Text(
                          "Playing Styles",
                          style: GoogleFonts.outfit(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              'assets/images/pl_stylepic.jpg',
                              fit: BoxFit.cover,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.3),
                                    themeProvider
                                        .getTheme()
                                        .scaffoldBackgroundColor
                                        .withOpacity(0.8),
                                    themeProvider
                                        .getTheme()
                                        .scaffoldBackgroundColor,
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                                  color:
                                      isDark ? Colors.white38 : Colors.black38),
                              prefixIcon: Icon(Icons.search,
                                  color:
                                      isDark ? Colors.white38 : Colors.black38),
                              filled: false,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 16),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverAppBarDelegate(
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          color:
                              themeProvider.getTheme().scaffoldBackgroundColor,
                          child: TabBar(
                            isScrollable: true,
                            indicatorColor: const Color(0xFF06DF5D),
                            labelColor: isDark ? Colors.white : Colors.black,
                            indicatorWeight: 3,
                            unselectedLabelColor: Colors.grey,
                            labelStyle: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold, fontSize: 13),
                            tabs: const [
                              Tab(text: "Hujum"),
                              Tab(text: "Yarim himoya"),
                              Tab(text: "Himoya"),
                              Tab(text: "Darvozabon"),
                            ],
                          ),
                        ),
                        50,
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  children: [
                    _buildStyleList(attack, isDark),
                    _buildStyleList(midfield, isDark),
                    _buildStyleList(defense, isDark),
                    _buildStyleList(goalkeeper, isDark),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStyleList(List<PlayingStyle> styles, bool isDark) {
    if (styles.isEmpty) {
      return Center(
        child: Text("Ma'lumot topilmadi",
            style: GoogleFonts.outfit(color: Colors.grey)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      itemCount: styles.length,
      itemBuilder: (context, index) {
        final style = styles[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      color: isDark ? Colors.white : Colors.black),
                ),
                const SizedBox(height: 8),
                Text(
                  style.description,
                  style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black87),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFF06DF5D).withOpacity(0.1),
                    border: Border.all(
                        color: const Color(0xFF06DF5D).withOpacity(0.3)),
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._child, this.height);

  final Widget _child;
  final double height;

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return _child;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
