import 'package:efinfo_beta/Pages/PlayerModelPage.dart';
import 'package:efinfo_beta/Pages/FormationSuggesterPage.dart';
import 'package:efinfo_beta/Others/positionskillchecker.dart';
import 'package:efinfo_beta/Others/teambuilder.dart';
import 'package:efinfo_beta/dataPlayers/CategoryPlayersPage.dart';
import 'package:efinfo_beta/Others/PackTricksPage.dart';
import 'package:efinfo_beta/Pages/PackSimulatorPage.dart';
import 'package:efinfo_beta/dataPlayers/StandartPlayersPage.dart';
import 'package:efinfo_beta/Others/ElementsPage.dart';
import 'package:efinfo_beta/components/newBadge.dart';
import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:efinfo_beta/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> moreData = [
      {
        'title': 'Taktik Sxema tavsiyalar',
        'subtitle': 'Optimal jamoangizni quring',
        'icon': "assets/images/team_playstyle.png",
        'accent': AppColors.accentBlue,
        'badge': true,
        'isColoredIcon': false,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const FormationSuggesterPage())),
      },
      {
        'title': 'Player Model',
        'subtitle': 'eFHUBdagi player model tushuntirish',
        'icon': "assets/images/players.png",
        'accent': Colors.tealAccent,
        'badge': true,
        'isColoredIcon': false,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PlayerModelPage())),
      },
      {
        'title': 'Pack Simulator',
        'subtitle': 'Omadingizni sinab ko\'ring',
        'icon': "assets/images/elements.png",
        'accent': Colors.amber,
        'badge': true,
        'isColoredIcon': false,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PackSimulatorPage())),
      },
      {
        'title': 'Skill Match Calculator',
        'subtitle': 'Skill moslik hisoblagich',
        'icon': "assets/images/skill_calculator.png",
        'accent': AppColors.accentBlue,
        'badge': false,
        'isColoredIcon': false,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PositionSkillPage())),
      },
      {
        'title': 'SuperSquad XI',
        'subtitle': 'Team building',
        'icon': "assets/images/formations.png",
        'accent': const Color(0xFF06DF5D),
        'badge': false,
        'isColoredIcon': false,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const TeamBuilderScreen())),
      },
      {
        'title': 'eFootball Elements',
        'subtitle': 'Game mechanics',
        'icon': "assets/images/elements.png",
        'accent': AppColors.accentGreen,
        'badge': false,
        'isColoredIcon': true,
        'onTap': () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const ElementsPage())),
      },
      {
        'title': 'Players Category',
        'subtitle': 'Browse by type',
        'icon': "assets/images/category.png",
        'accent': AppColors.accentOrange,
        'badge': false,
        'isColoredIcon': false,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CategoryPlayersPage())),
      },
      {
        'title': 'Standard Players',
        'subtitle': 'Full database',
        'icon': "assets/images/players.png",
        'accent': const Color(0xFF06DF5D),
        'badge': false,
        'isColoredIcon': false,
        'onTap': () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    const StandartPlayersPage(title: 'Standard Players'))),
      },
      {
        'title': 'Pack Tricks',
        'subtitle': 'Epik tushurish sirlari',
        'icon': "assets/images/elements.png",
        'accent': Colors.purpleAccent,
        'badge': false,
        'isColoredIcon': false,
        'onTap': () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const PackTricksPage())),
      },
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: [
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.85,
              ),
              itemCount: moreData.length,
              itemBuilder: (context, index) {
                final item = moreData[index];
                return _MoreItem(
                  title: item['title'],
                  subtitle: item['subtitle'],
                  icon: item['icon'],
                  accent: item['accent'],
                  badge: item['badge'],
                  isColoredIcon: item['isColoredIcon'] ?? false,
                  onTap: item['onTap'],
                );
              },
            ),
            const SizedBox(height: 48),
            _buildDisclaimer(context),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimer(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: AppColors.accentOrange, size: 20),
              const SizedBox(width: 8),
              Text(
                "Disclaimer",
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  color: AppColors.accentOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Unofficial fan-made app. Data from public sources like pesdb.net. Not affiliated with Konami. Built for PES community with love.",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: isDark ? Colors.white54 : Colors.black54,
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;
  final Color accent;
  final bool badge;
  final bool isColoredIcon;
  final VoidCallback? onTap;

  const _MoreItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.badge,
    this.isColoredIcon = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return GestureDetector(
      onTap: onTap,
      child: NewBadgeWrapper(
        showBadge: badge,
        child: SizedBox.expand(
          child: GlassContainer(
            borderRadius: 24,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Image.asset(
                          icon,
                          width: 42,
                          height: 42,
                          color: isColoredIcon ? null : accent,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          color: isDark ? Colors.white54 : Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
