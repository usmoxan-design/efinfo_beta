import 'dart:convert';
import 'dart:io';
import 'package:any_image_view/any_image_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:efinfo_beta/manager/manager_detail_page.dart';
import 'package:efinfo_beta/models/manager_model.dart';
import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:efinfo_beta/widgets/glass_container.dart';
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
        final response = await http.get(Uri.parse('https://raw.githubusercontent.com/username/repo/main/managers.json'));
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
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: managers.length,
                  itemBuilder: (context, index) {
                    final manager = managers[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ManagerDetailPage(manager: manager),
                          ),
                        );
                      },
                      child: GlassContainer(
                        padding: const EdgeInsets.all(12),
                        borderRadius: 20,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: const Color(0xFF06DF5D)
                                        .withOpacity(0.5),
                                    width: 1),
                              ),
                              child: CircleAvatar(
                                radius: 35,
                                backgroundColor: isDark
                                    ? Colors.grey[900]
                                    : Colors.grey[200],
                                child: ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: manager.imageUrl,
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Color(0xFF06DF5D)),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.person, size: 30),
                                    fit: BoxFit.cover,
                                    width: 70,
                                    height: 70,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              manager.name,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              manager.nationality,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
