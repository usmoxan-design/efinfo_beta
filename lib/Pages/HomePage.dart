import 'package:efinfo_beta/Player/BoosterRecommendationPage.dart';
import 'package:efinfo_beta/Player/SkillRecommendationPage.dart';
import 'package:efinfo_beta/Player/player_skillspage.dart';
import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:efinfo_beta/Player/playingstylespage.dart';
import 'package:efinfo_beta/Player/positions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Player/playerStat.dart';
import '../components/newBadge.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> gridData = [
      {
        'title': 'Playing Styles',
        'subtitle': "O'yin stili",
        'icon': "assets/images/playing_styles.png",
        'accent': AppColors.accentPink,
        'badge': false,
        'isColoredIcon': false,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PlayingStylePage())),
      },
      {
        'title': 'Player Skills',
        'subtitle': 'Futbolchi skillari',
        'icon': "assets/images/soccer_shoe.png",
        'accent': AppColors.accentGreen,
        'badge': false,
        'isColoredIcon': false,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PlayerSkillsPage())),
      },
      {
        'title': 'Positions',
        'subtitle': 'Pozitsiyalar',
        'icon': "assets/images/positions.png",
        'accent': AppColors.accentOrange,
        'badge': false,
        'isColoredIcon': false,
        'onTap': () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const PositionsPage())),
      },
      {
        'title': 'Player Stats',
        'subtitle': "O'yinchi statistikasi",
        'icon': "assets/images/details.png",
        'accent': AppColors.accentBlue,
        'badge': false,
        'isColoredIcon': false,
        'onTap': () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const PlayerStatPage())),
      },
      {
        'title': "Booster Recommendations",
        'subtitle': "Booster tavsiyalar",
        'icon': "assets/images/booster.png",
        'accent': AppColors.accentGreen,
        'badge': true,
        'isColoredIcon': true,
        'onTap': () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const BoosterRecommendationPage())),
      },
      {
        'title': "Skill Recommendations",
        'subtitle': "Skill tavsiyalar",
        'icon': "assets/images/skill.png",
        'accent': AppColors.accentOrange,
        'badge': true,
        'isColoredIcon': true,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SkillRecommendationPage())),
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemCount: gridData.length,
              itemBuilder: (context, index) {
                final item = gridData[index];
                return _GridItem(
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
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hush kelibsiz,",
          style: GoogleFonts.outfit(
            fontSize: 16,
            color: AppColors.textDim,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "EFINFO HUB",
          style: GoogleFonts.outfit(
            fontSize: 28,
            color: AppColors.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _GridItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;
  final Color accent;
  final bool badge;
  final bool isColoredIcon;
  final VoidCallback? onTap;

  const _GridItem({
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
    return GestureDetector(
      onTap: onTap,
      child: NewBadgeWrapper(
        showBadge: badge,
        child: SizedBox.expand(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
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
                          width: 48,
                          height: 48,
                          color: isColoredIcon ? null : accent,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: AppColors.textDim,
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
