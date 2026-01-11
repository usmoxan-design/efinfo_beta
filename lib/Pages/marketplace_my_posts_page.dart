import 'package:efinfo_beta/Pages/marketplace_list_page.dart';
import 'package:efinfo_beta/models/account_post.dart';
import 'package:efinfo_beta/services/auth_service.dart';
import 'package:efinfo_beta/services/marketplace_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyMarketplacePostsPage extends StatelessWidget {
  const MyMarketplacePostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final marketplaceService = MarketplaceService();
    final authService = AuthService();
    final currentUser = authService.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("Mening E'lonlarim",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: currentUser == null
          ? const Center(child: Text("Tizimga kirmagansiz"))
          : StreamBuilder<List<AccountPost>>(
              stream: marketplaceService
                  .getPosts(), // We'll filter in the UI or add a specific method
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final posts = snapshot.data
                        ?.where((p) => p.userId == currentUser.uid)
                        .toList() ??
                    [];

                if (posts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 64, color: Colors.grey.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text("Sizda hali e'lonlar yo'q",
                            style: GoogleFonts.outfit(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    return MarketplaceListPage.buildStaticPostCard(
                      context,
                      posts[index],
                      showActions: true,
                    );
                  },
                );
              },
            ),
    );
  }
}
