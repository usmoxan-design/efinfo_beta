import 'package:efinfo_beta/Player/formations.dart';
import 'package:efinfo_beta/Player/individual.dart';
import 'package:efinfo_beta/components/newBadge.dart';
import 'package:efinfo_beta/manager/plstyles.dart';
import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ManagerPage extends StatefulWidget {
  const ManagerPage({super.key});

  @override
  State<ManagerPage> createState() => _ManagerPageState();
}

class _ManagerPageState extends State<ManagerPage> {
  @override
  Widget build(BuildContext context) {
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
              itemCount: managerData.length,
              itemBuilder: (context, index) {
                final item = managerData[index];
                return _ManagerItem(
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
          "Manager Hub,",
          style: GoogleFonts.outfit(
            fontSize: 16,
            color: AppColors.textDim,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Strategy Center",
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

class _ManagerItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;
  final Color accent;
  final bool badge;
  final bool isColoredIcon;
  final VoidCallback? onTap;

  const _ManagerItem({
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
