import 'package:efinfo_beta/Others/positionskillchecker.dart';
import 'package:efinfo_beta/Others/teambuilder.dart';
import 'package:efinfo_beta/Pages/CategoryPlayersPage.dart';
import 'package:efinfo_beta/Pages/StandartPlayersPage.dart';
import 'package:efinfo_beta/Player/ElementsPage.dart';
import 'package:efinfo_beta/components/newBadge.dart';
import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
        'title': 'eFootball Elements',
        'subtitle': 'Game mechanics',
        'icon': "assets/images/elements.png",
        'accent': AppColors.accentGreen,
        'badge': true,
        'isColoredIcon': true,
        'onTap': () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const ElementsPage())),
      },
      {
        'title': 'Players Category',
        'subtitle': 'Browse by type',
        'icon': "assets/images/category.png",
        'accent': AppColors.accentOrange,
        'badge': true,
        'isColoredIcon': false,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CategoryPlayersPage())),
      },
      {
        'title': 'Standard Players',
        'subtitle': 'Full database',
        'icon': "assets/images/players.png",
        'accent': AppColors.accentPink,
        'badge': true,
        'isColoredIcon': false,
        'onTap': () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    const StandartPlayersPage(title: 'Standard Players'))),
      },
      {
        'title': 'SuperSquad XI',
        'subtitle': 'Team building',
        'icon': "assets/images/formations.png",
        'accent': AppColors.accentPink,
        'badge': false,
        'isColoredIcon': false,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const TeamBuilderScreen())),
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
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
            _buildDisclaimer(),
            const SizedBox(height: 40),
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
          "More Tools,",
          style: GoogleFonts.outfit(
            fontSize: 16,
            color: AppColors.textDim,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Explore Extra",
          style: GoogleFonts.outfit(
            fontSize: 28,
            color: AppColors.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1),
      ),
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
              color: AppColors.textDim,
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
