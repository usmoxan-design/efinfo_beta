import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:efinfo_beta/widgets/glass_container.dart';
import 'package:icons_plus/icons_plus.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Sozlamalar",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: themeProvider.isDarkMode
                ? [const Color(0xFF0A0A0A), const Color(0xFF1A1A1A)]
                : [const Color(0xFFF5F5F7), Colors.white],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildSectionTitle("Ko'rinish"),
              const SizedBox(height: 15),
              _buildSettingTile(
                context,
                icon: themeProvider.isDarkMode ? IonIcons.moon : IonIcons.sunny,
                title: "Qorong'u rejim",
                subtitle: "Ilovani tungi rejimga o'tkazish",
                trailing: Switch.adaptive(
                  value: themeProvider.isDarkMode,
                  activeColor: const Color(0xFF06DF5D),
                  onChanged: (value) => themeProvider.toggleTheme(),
                ),
              ),
              // const SizedBox(height: 15),
              // _buildSettingTile(
              //   context,
              //   icon: IonIcons.color_palette,
              //   title: "Glassmorphism UI",
              //   subtitle: "Shisha effektini yoqish/o'chirish",
              //   trailing: Switch.adaptive(
              //     value: themeProvider.isGlassMode,
              //     activeColor: const Color(0xFF06DF5D),
              //     onChanged: (value) => themeProvider.toggleGlassMode(),
              //   ),
              // ),
              const SizedBox(height: 30),
              _buildSectionTitle("Ilova haqida"),
              const SizedBox(height: 15),
              _buildSettingTile(
                context,
                icon: IonIcons.information_circle,
                title: "Versiya",
                subtitle: "1.0.10",
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              ),
              const SizedBox(height: 15),
              _buildSettingTile(
                context,
                icon: IonIcons.paper_plane,
                title: "Telegram kanalimiz",
                subtitle: "@eFootball_Info_Hub",
                trailing:
                    const Icon(Icons.open_in_new, size: 20, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF06DF5D),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF06DF5D).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF06DF5D), size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
