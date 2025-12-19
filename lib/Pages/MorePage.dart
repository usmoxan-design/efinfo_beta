import 'package:efinfo_beta/Others/positionskillchecker.dart';
import 'package:efinfo_beta/Others/teambuilder.dart';
import 'package:efinfo_beta/Pages/CategoryPlayersPage.dart';
import 'package:efinfo_beta/Pages/StandartPlayersPage.dart';
import 'package:efinfo_beta/Player/ElementsPage.dart';
import 'package:efinfo_beta/components/newBadge.dart';
import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:flutter/material.dart';

class Morepage extends StatefulWidget {
  const Morepage({super.key});

  @override
  State<Morepage> createState() => _MorepageState();
}

class _MorepageState extends State<Morepage> {
  @override
  Widget build(BuildContext context) {
    final List<_ListItem> items = [
      _ListItem(
        title: 'Skill moslik Hisoblagich',
        icon: "assets/images/skill_calculator.png",
        color: AppColors.accent,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PositionSkillPage()),
          );
        },
        badgeState: false,
        // onBlock: true, // 🔒 bloklangan
      ),
      _ListItem(
        title: 'SuperSquad XI',
        icon: "assets/images/formations.png",
        color: AppColors.accent,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TeamBuilderScreen()),
          );
        },
        badgeState: false,
        // onBlock: true, // 🔒 bloklangan
      ),
      _ListItem(
        title: 'eFootball Elements',
        icon: "assets/images/elements.png",
        color: Colors.transparent,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ElementsPage()),
          );
        },
        badgeState: true,
      ),
      // _ListItem(
      //   title: 'eFootBox Mock',
      //   icon: "assets/images/details.png",
      //   color: AppColors.accent,
      //   onTap: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (_) => const EfPlayersPage()),
      //     );
      //   },
      // ),
      _ListItem(
        title: 'Players Category',
        icon: "assets/images/category.png", // Using same icon/placeholder
        color: AppColors.accent,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CategoryPlayersPage()),
          );
        },
        badgeState: true,
      ),
      _ListItem(
        title: 'Standart Players', // As requested: StandartPlayersPage
        icon: "assets/images/players.png", // Using same icon/placeholder
        color: AppColors.accent,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    const StandartPlayersPage(title: 'Standard Players')),
          );
        },
        badgeState: true,
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
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Text(
                    "Disclaimer",
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Unofficial fan-made app. Data from public sources like pesdb.net. Not affiliated with Konami.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  final String title;
  final String icon;
  final Color color;
  final VoidCallback? onTap;
  final bool onBlock;
  final bool badgeState;

  const _ListItem({
    required this.title,
    required this.icon,
    required this.color,
    this.onTap,
    this.onBlock = false,
    required this.badgeState,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onBlock ? null : onTap, // 🔒 bosilmaydi
      child: Stack(
        children: [
          // Orqa fon
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: onBlock ? 0.5 : 1.0, // 🔒 blok bo‘lsa hiraroq
            child: NewBadgeWrapper(
              showBadge: badgeState,
              child: Container(
                decoration: BoxDecoration(
                  color:
                      (color == Colors.transparent ? AppColors.accent : color)
                          .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: (color == Colors.transparent
                              ? AppColors.accent
                              : color)
                          .withOpacity(0.3)),
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
                            color: color == Colors.transparent ? null : color,
                          )),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: color == Colors.transparent
                              ? AppColors.accent
                              : color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
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
    );
  }
}
