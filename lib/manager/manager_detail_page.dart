import 'package:any_image_view/any_image_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:efinfo_beta/models/manager_model.dart';
import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:efinfo_beta/widgets/glass_container.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ManagerDetailPage extends StatelessWidget {
  final Manager manager;

  const ManagerDetailPage({super.key, required this.manager});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          manager.name,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Manager Image Header
            Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.accent, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: manager.imageUrl,
                    placeholder: (context, url) => const Center(
                        child:
                            CircularProgressIndicator(color: AppColors.accent)),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.person, size: 80),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Info Table
            GlassContainer(
              padding: const EdgeInsets.symmetric(vertical: 8),
              borderRadius: 16,
              child: Column(
                children: [
                  _buildTableTile("Name", manager.name, isDark),
                  _buildDivider(isDark),
                  _buildTableTile("Full Name", manager.fullName, isDark),
                  _buildDivider(isDark),
                  _buildTableTile("Team", manager.team, isDark),
                  _buildDivider(isDark),
                  _buildTableTile("Nationality", manager.nationality, isDark),
                  _buildDivider(isDark),
                  _buildTableTile("Type", manager.type, isDark),
                  _buildDivider(isDark),
                  _buildTableTile("Age", manager.age.toString(), isDark,
                      isLast: true),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Coaching Affinity
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                "Coaching Affinity: ${manager.coachingAffinity}",
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Team Playstyle Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                "Team Playstyle",
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Playstyle List
            ...manager.teamPlaystyle.entries.map((entry) {
              return _buildPlaystyleRow(entry.key, entry.value, isDark);
            }),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTableTile(String label, String value, bool isDark,
      {bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 16,
      endIndent: 16,
      color: isDark ? Colors.white12 : Colors.black12,
    );
  }

  Widget _buildPlaystyleRow(String title, int value, bool isDark) {
    Color bg;
    if (value >= 80) {
      bg = const Color(0xFF94FF2B); // Vibrant Green
    } else if (value >= 70) {
      bg = const Color(0xFFFFC107); // Amber/Yellow
    } else {
      bg = const Color(0xFFFF4B4B); // Red
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              value.toString(),
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black, // Numbers always black in the boxes
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
