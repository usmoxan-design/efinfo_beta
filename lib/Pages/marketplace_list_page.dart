import 'package:efinfo_beta/Pages/image_preview_page.dart';
import 'package:efinfo_beta/Pages/auth_page.dart';
import 'package:efinfo_beta/Pages/marketplace_add_edit_page.dart';
import 'package:efinfo_beta/Pages/marketplace_my_posts_page.dart';
import 'package:efinfo_beta/models/account_post.dart';
import 'package:efinfo_beta/services/auth_service.dart';
import 'package:efinfo_beta/services/marketplace_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class MarketplaceListPage extends StatefulWidget {
  const MarketplaceListPage({super.key});

  static Widget buildStaticPostCard(BuildContext context, AccountPost post,
      {bool showActions = false}) {
    return _MarketplaceListPageState.buildStaticPostCard(context, post,
        showActions: showActions);
  }

  @override
  State<MarketplaceListPage> createState() => _MarketplaceListPageState();
}

class _MarketplaceListPageState extends State<MarketplaceListPage> {
  final MarketplaceService _marketplaceService = MarketplaceService();
  final AuthService _authService = AuthService();

  // Filters
  double? _maxPrice;
  bool _filterGoogle = false;
  bool _filterKonami = false;
  bool _filterGameCenter = false;

  String _sortBy = 'yangi'; // Default sort
  final List<Map<String, String>> _sortingOptions = [
    {'value': 'yangi', 'label': "Eng yangi"},
    {'value': 'ko_p', 'label': "Ko'p ko'rilgan"},
    {'value': 'qimmat', 'label': "Qimmatdan arzonga"},
    {'value': 'arzon', 'label': "Arzondan qimmatga"},
  ];

  void _addNewPost() {
    if (_authService.currentUser == null) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const AuthPage()));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const MarketplaceAddEditPage()));
    }
  }

  void _showFilterSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161618) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Filtrlash",
                  style: GoogleFonts.outfit(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text("Maksimal narx (so'm)",
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
              Slider(
                value: _maxPrice ?? 2000000,
                min: 0,
                max: 2000000,
                divisions: 20,
                label: _maxPrice == null
                    ? "Barchasi"
                    : "${NumberFormat("#,###").format(_maxPrice)}",
                onChanged: (v) {
                  setModalState(() => _maxPrice = v);
                  setState(() => _maxPrice = v);
                },
              ),
              const SizedBox(height: 16),
              Text("Ulanishlar",
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text("Google"),
                    selected: _filterGoogle,
                    onSelected: (v) {
                      setModalState(() => _filterGoogle = v);
                      setState(() => _filterGoogle = v);
                    },
                  ),
                  FilterChip(
                    label: const Text("Konami"),
                    selected: _filterKonami,
                    onSelected: (v) {
                      setModalState(() => _filterKonami = v);
                      setState(() => _filterKonami = v);
                    },
                  ),
                  FilterChip(
                    label: const Text("GameCenter"),
                    selected: _filterGameCenter,
                    onSelected: (v) {
                      setModalState(() => _filterGameCenter = v);
                      setState(() => _filterGameCenter = v);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setModalState(() {
                      _maxPrice = null;
                      _filterGoogle = false;
                      _filterKonami = false;
                      _filterGameCenter = false;
                    });
                    setState(() {
                      _maxPrice = null;
                      _filterGoogle = false;
                      _filterKonami = false;
                      _filterGameCenter = false;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                      elevation: 0),
                  child: const Text("Filtrni tozalash"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            elevation: 0,
            toolbarHeight: 60,
            backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort_rounded),
                onSelected: (val) => setState(() => _sortBy = val),
                itemBuilder: (context) => _sortingOptions
                    .map((opt) => PopupMenuItem(
                          value: opt['value'],
                          child:
                              Text(opt['label']!, style: GoogleFonts.outfit()),
                        ))
                    .toList(),
              ),
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                onPressed: _showFilterSheet,
              ),
              TextButton.icon(
                onPressed: () {
                  if (_authService.currentUser == null) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AuthPage()));
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const MyMarketplacePostsPage()));
                  }
                },
                icon: Icon(Icons.person_outline_rounded,
                    size: 20, color: isDark ? Colors.white70 : Colors.black87),
                label: Text("Mening e'lonlarim",
                    style: GoogleFonts.outfit(
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontSize: 13)),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "Account Savdosi",
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 20,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            ),
          ),
          StreamBuilder<List<AccountPost>>(
            stream: _marketplaceService.getPosts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(
                      child:
                          CircularProgressIndicator(color: Colors.blueAccent)),
                );
              }
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(
                      child: Text("Xatolik yuz berdi: ${snapshot.error}")),
                );
              }

              var posts = snapshot.data ?? [];
              final totalCount = posts.length;

              // Apply Filters
              if (_maxPrice != null) {
                posts = posts.where((p) => p.price <= _maxPrice!).toList();
              }
              if (_filterGoogle)
                posts = posts.where((p) => p.googleAccount).toList();
              if (_filterKonami)
                posts = posts.where((p) => p.konamiId).toList();
              if (_filterGameCenter)
                posts = posts.where((p) => p.gameCenter).toList();

              // Apply Sorting
              switch (_sortBy) {
                case 'ko_p':
                  posts
                      .sort((a, b) => b.views.length.compareTo(a.views.length));
                  break;
                case 'qimmat':
                  posts.sort((a, b) => b.price.compareTo(a.price));
                  break;
                case 'arzon':
                  posts.sort((a, b) => a.price.compareTo(b.price));
                  break;
                case 'yangi':
                default:
                  posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                  break;
              }

              if (posts.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 60, color: Colors.grey.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text("E'lonlar topilmadi",
                            style: GoogleFonts.outfit(
                                color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  ),
                );
              }

              return SliverMainAxisGroup(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Row(
                        children: [
                          Text(
                            "Jami: $totalCount ta e'lon",
                            style: GoogleFonts.outfit(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                                fontSize: 14),
                          ),
                          const Spacer(),
                          if (posts.length != totalCount)
                            Text(
                              "Filtrlangan: ${posts.length} ta",
                              style: GoogleFonts.outfit(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildPostCard(posts[index]),
                        childCount: posts.length,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
            bottom: 70), // Avoid overlap with BottomNavBar
        child: FloatingActionButton.extended(
          onPressed: _addNewPost,
          backgroundColor: Colors.blueAccent,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text(
            "E'lon berish",
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600, color: Colors.white),
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _buildPostCard(AccountPost post) {
    return buildStaticPostCard(context, post);
  }

  static Widget buildStaticPostCard(BuildContext context, AccountPost post,
      {bool showActions = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authService = AuthService();
    final marketplaceService = MarketplaceService();
    final currentUser = authService.currentUser;
    final isOwner = currentUser != null && currentUser.uid == post.userId;

    return GestureDetector(
      onTap: () {
        marketplaceService.incrementView(
            post.id, currentUser?.uid ?? 'anonymous');
        _showPostDetailsStatic(context, post);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161618) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.03),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Hero(
                    tag: 'post-img-${post.id}',
                    child: CachedNetworkImage(
                      imageUrl: post.imageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: isDark
                            ? Colors.white10
                            : Colors.black.withOpacity(0.05),
                        child: const Center(
                            child: SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(
                          "${NumberFormat("#,###").format(post.price)} so'm",
                          style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ),
                  ),
                  if (isOwner)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(10)),
                        child: Text("Mening e'lonim",
                            style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 10)),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text(post.title,
                                style: GoogleFonts.outfit(
                                    fontSize: 17, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis)),
                        Row(children: [
                          const Icon(Icons.remove_red_eye_outlined,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text("${post.views.length}",
                              style: GoogleFonts.outfit(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500))
                        ]),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded,
                            size: 14, color: Colors.blueAccent),
                        const SizedBox(width: 6),
                        Text(post.userName,
                            style: GoogleFonts.outfit(
                                color: Colors.blueAccent,
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                        const Spacer(),
                        Text(
                            DateFormat('dd.MM.yyyy HH:mm')
                                .format(post.createdAt),
                            style: GoogleFonts.outfit(
                                color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(post.description,
                        style: GoogleFonts.outfit(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontSize: 13,
                            height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            if (post.googleAccount)
                              _buildTagStatic(
                                  context, "Google", const Color(0xFFEA4335)),
                            if (post.konamiId)
                              _buildTagStatic(
                                  context, "Konami", const Color(0xFFE10000)),
                            if (post.gameCenter)
                              _buildTagStatic(context, "GameCenter",
                                  const Color(0xFF007AFF)),
                          ],
                        ),
                      ],
                    ),
                    if (showActions && isOwner) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildOwnerActionStatic(
                              icon: Icons.edit_note_rounded,
                              label: "Tahrir",
                              color: Colors.grey,
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            MarketplaceAddEditPage(
                                                post: post)));
                              }),
                          const Spacer(),
                          _buildOwnerActionStatic(
                              icon: Icons.check_circle_outline_rounded,
                              label: "Sotildi",
                              color: Colors.green,
                              onTap: () {
                                _confirmActionStatic(
                                    context, post, "Sotildi", Colors.green,
                                    () async {
                                  await marketplaceService.deletePost(
                                      post.id, post.fileId);
                                });
                              }),
                          const SizedBox(width: 8),
                          _buildOwnerActionStatic(
                              icon: Icons.delete_outline_rounded,
                              label: "O'chirish",
                              color: Colors.redAccent,
                              onTap: () {
                                _confirmActionStatic(context, post, "O'chirish",
                                    Colors.redAccent, () async {
                                  await marketplaceService.deletePost(
                                      post.id, post.fileId);
                                });
                              }),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildTagStatic(
      BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8)),
      child: Text(label,
          style: GoogleFonts.outfit(
              fontSize: 10, color: color, fontWeight: FontWeight.bold)),
    );
  }

  static Widget _buildOwnerActionStatic(
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: GoogleFonts.outfit(
                    color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  static void _showPostDetailsStatic(BuildContext context, AccountPost post) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF121212) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(2))),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => _showImagePreview(
                          context, post.imageUrl, 'post-img-detail-${post.id}'),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Hero(
                          tag: 'post-img-detail-${post.id}',
                          child: CachedNetworkImage(imageUrl: post.imageUrl),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text(post.title,
                                style: GoogleFonts.outfit(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold))),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.blueAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16)),
                          child: Text(
                              "${NumberFormat("#,###").format(post.price)} so'm",
                              style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                            DateFormat('dd.MM.yyyy HH:mm')
                                .format(post.createdAt),
                            style: GoogleFonts.outfit(
                                color: Colors.grey[500], fontSize: 13)),
                        const SizedBox(width: 16),
                        Icon(Icons.remove_red_eye_outlined,
                            size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text("${post.views.length} marta ko'rildi",
                            style: GoogleFonts.outfit(
                                color: Colors.grey[500], fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text("Tavsif",
                        style: GoogleFonts.outfit(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(post.description,
                        style: GoogleFonts.outfit(
                            fontSize: 15,
                            color: isDark ? Colors.white70 : Colors.black87,
                            height: 1.6)),
                    const SizedBox(height: 32),
                    Text("Bog'lanish",
                        style: GoogleFonts.outfit(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildContactCardStatic(context,
                        icon: Icons.telegram_rounded,
                        title: post.telegramUser,
                        subtitle: "Telegram",
                        color: const Color(0xFF0088cc), onTap: () async {
                      final url = Uri.parse(
                          "https://t.me/${post.telegramUser.replaceAll('@', '')}");
                      if (await canLaunchUrl(url)) await launchUrl(url);
                    }),
                    const SizedBox(height: 12),
                    _buildContactCardStatic(context,
                        icon: Icons.phone_forwarded_rounded,
                        title: post.phoneNumber,
                        subtitle: "Qo'ng'iroq",
                        color: Colors.green, onTap: () async {
                      final url = Uri.parse("tel:${post.phoneNumber}");
                      if (await canLaunchUrl(url)) await launchUrl(url);
                    }),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showImagePreview(BuildContext context, String url, String tag) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImagePreviewPage(imageUrl: url, heroTag: tag),
      ),
    );
  }

  static Widget _buildContactCardStatic(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required Color color,
      required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: isDark ? Colors.white10 : Colors.black12)),
        child: Row(
          children: [
            Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 24)),
            const SizedBox(width: 16),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: GoogleFonts.outfit(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style:
                          GoogleFonts.outfit(fontSize: 12, color: Colors.grey))
                ])),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  static void _confirmActionStatic(BuildContext context, AccountPost post,
      String action, Color color, Future<void> Function() onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("$action tasdiqlash",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content:
            Text("Bu e'lonni $action istaysizmi?", style: GoogleFonts.outfit()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  Text("Yo'q", style: GoogleFonts.outfit(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await onConfirm();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            child: Text("Ha",
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
