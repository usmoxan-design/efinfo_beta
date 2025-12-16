import 'package:efinfo_beta/Player/formations.dart';
import 'package:efinfo_beta/Player/individual.dart';
import 'package:efinfo_beta/components/newBadge.dart';
import 'package:efinfo_beta/manager/plstyles.dart';
import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ManagerPage extends StatefulWidget {
  const ManagerPage({super.key});

  @override
  State<ManagerPage> createState() => _ManagerPageState();
}

class _ManagerPageState extends State<ManagerPage> {
  @override
  Widget build(BuildContext context) {
    final List<_ListItem> items = [
      _ListItem(
        badge: false,

        title: 'Team Playstyle',
        subtitle: 'Jamoa o\'yin stili',
        icon: "assets/images/team_playstyle.png",
        color: AppColors.accent,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ManagerStylesPage()),
          );
        },
        // onBlock: true, // 🔒 bloklangan
      ),
      _ListItem(
        badge: false,
        title: 'Formations',
        subtitle: 'Taktik sxemalar',
        icon: "assets/images/formation_change.png",
        color: AppColors.accent,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormationsListScreen()),
          );
        },
        // onBlock: true, // 🔒 bloklangan
      ),
      _ListItem(
        badge: false,
        title: 'Individual Instructions',
        subtitle: "Shaxsiy ko'rsatmalar",
        icon: "assets/images/individual_instruction.png",
        color: AppColors.accent,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const ModernInstructionsListPage()),
          );
        },
        // onBlock: true, // 🔒 bloklangan
      ),
    ];
    return Scaffold(
      backgroundColor: AppColors.background, //0xFF06DF5D
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 1,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) => items[index],
            ),
          ],
        ),
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;
  final Color color;
  final VoidCallback? onTap;
  final bool onBlock;
  final bool badge;

  const _ListItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
    this.onBlock = false,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onBlock ? null : onTap, // 🔒 bosilmaydi
      child: NewBadgeWrapper(
        showBadge: badge,
        child: Stack(
          children: [
            // Orqa fon
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: onBlock ? 0.5 : 1.0, // 🔒 blok bo‘lsa hiraroq
              child: Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: 60,
                          child: Image.asset(
                            icon.toString(),
                            color: AppColors.accent,
                          )),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Opacity(
                        opacity: .7,
                        child: Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 🔒 Agar block bo‘lsa lock icon
            if (onBlock)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: const Color.fromARGB(45, 0, 0, 0)),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock, color: Colors.white60, size: 40),
                      Text(
                        "Tez kunda...",
                        style: TextStyle(color: Colors.white60, fontSize: 16),
                      )
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
