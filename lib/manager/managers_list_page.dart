import 'dart:convert';
import 'dart:io';
import 'package:any_image_view/any_image_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:efinfo_beta/manager/manager_detail_page.dart';
import 'package:efinfo_beta/models/manager_model.dart';
import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http; // Use for remote fetching

class ManagersListPage extends StatefulWidget {
  const ManagersListPage({super.key});

  @override
  State<ManagersListPage> createState() => _ManagersListPageState();
}

class _ManagersListPageState extends State<ManagersListPage> {
  List<Manager> managers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadManagers();
  }

  Future<void> loadManagers() async {
    setState(() => isLoading = true);
    try {
      // Offline mode: Load from assets
      final String response =
          await rootBundle.loadString('assets/data/managers.json');
      final List<dynamic> data = json.decode(response);
      setState(() {
        managers = data.map((json) => Manager.fromJson(json)).toList();
        isLoading = false;
      });

      /*
      // Online mode: Load from GitHub (Commented as requested)
      if (await hasInternet()) {
        final response = await http.get(Uri.parse('https://raw.githubusercontent.com/usmoxan-design/efinfo_data/refs/heads/main/managers.json'));
        if (response.statusCode == 200) {
          final List<dynamic> remoteData = json.decode(response.body);
          setState(() {
            managers = remoteData.map((json) => Manager.fromJson(json)).toList();
          });
        }
      }
      */
    } catch (e) {
      debugPrint("Error loading managers: $e");
      setState(() => isLoading = false);
    }
  }

  // Internet connectivity check function
  Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text("Menejerlar",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF06DF5D)))
          : managers.isEmpty
              ? Center(
                  child: Text("Menejerlar topilmadi",
                      style: GoogleFonts.outfit(
                          color: isDark ? Colors.white : Colors.black)))
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: managers.length,
                  itemBuilder: (context, index) {
                    final manager = managers[index];
                    return _buildManagerCard(context, manager, isDark);
                  },
                ),
    );
  }

  Widget _buildManagerCard(BuildContext context, Manager manager, bool isDark) {
    // Find the highest rating for the overall rating display
    int maxRating = 0;
    if (manager.teamPlaystyle.isNotEmpty) {
      maxRating = manager.teamPlaystyle.values
          .reduce((curr, next) => curr > next ? curr : next);
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ManagerDetailPage(manager: manager),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.black12,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Manager Image with 16px border radius
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: manager.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: isDark ? Colors.grey[900] : Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF06DF5D),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: isDark ? Colors.grey[900] : Colors.grey[200],
                        child: const Icon(Icons.person, size: 40),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildRatingBox(maxRating),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                manager.name,
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          manager.team.isNotEmpty ? manager.team : "Free agent",
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                            children: [
                              const TextSpan(text: "Coaching Affinity: "),
                              TextSpan(
                                text: manager.coachingAffinity.isNotEmpty
                                    ? manager.coachingAffinity
                                    : "None",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Playstyles
              ...manager.teamPlaystyle.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      _buildRatingBox(entry.value),
                      const SizedBox(width: 12),
                      Text(
                        entry.key,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingBox(int rating) {
    Color color;
    if (rating >= 85) {
      color = const Color(0xFF9AFF00); // Vibrant Green
    } else if (rating >= 75) {
      color = const Color(0xFFFFFF00); // Yellow
    } else if (rating >= 70) {
      color = const Color(0xFFFFCC00); // Orange
    } else {
      color = const Color(0xFFFF3B30); // Red
    }

    return Container(
      width: 32,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        rating.toString(),
        style: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}
