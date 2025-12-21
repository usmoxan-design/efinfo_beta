import 'package:efinfo_beta/Player/BoosterRecommendationPage.dart';
import 'package:efinfo_beta/Player/SkillRecommendationPage.dart';
import 'package:efinfo_beta/Player/player_skillspage.dart';
import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:efinfo_beta/Player/playingstylespage.dart';
import 'package:efinfo_beta/Player/positions.dart';
import 'package:efinfo_beta/Player/formations.dart';
import 'package:efinfo_beta/Player/individual.dart';
import 'package:efinfo_beta/manager/plstyles.dart';
import 'package:efinfo_beta/components/newBadge.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Player/playerStat.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.accentPink,
                indicatorWeight: 3,
                labelColor: AppColors.textWhite,
                unselectedLabelColor: AppColors.textDim,
                labelStyle: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold, fontSize: 16),
                tabs: const [
                  Tab(text: "Futbolchilar"),
                  Tab(text: "Menejer"),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPlayerHub(),
                  _buildManagerHub(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerHub() {
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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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
    );
  }

  Widget _buildManagerHub() {
    final List<Map<String, dynamic>> managerData = [
      {
        'title': 'Team Playstyle',
        'subtitle': "Jamoa o'yin stili",
        'icon': "assets/images/team_playstyle.png",
        'accent': AppColors.accentGreen,
        'badge': false,
        'isColoredIcon': false,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ManagerStylesPage())),
      },
      {
        'title': 'Formations',
        'subtitle': 'Taktik sxemalar',
        'icon': "assets/images/formation_change.png",
        'accent': AppColors.accentBlue,
        'badge': false,
        'isColoredIcon': false,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const FormationsListScreen())),
      },
      {
        'title': 'Individual Instructions',
        'subtitle': "Shaxsiy ko'rsatmalar",
        'icon': "assets/images/individual_instruction.png",
        'accent': AppColors.accentPink,
        'badge': false,
        'isColoredIcon': false,
        'onTap': () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const ModernInstructionsListPage())),
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemCount: managerData.length,
          itemBuilder: (context, index) {
            final item = managerData[index];
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
