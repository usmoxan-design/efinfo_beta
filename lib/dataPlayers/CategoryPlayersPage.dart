import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:efinfo_beta/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/pes_service.dart';
import '../models/pes_models.dart';
import '../widgets/error_display_widget.dart';
import 'StandartPlayersPage.dart';

class CategoryPlayersPage extends StatefulWidget {
  const CategoryPlayersPage({super.key});

  @override
  State<CategoryPlayersPage> createState() => _CategoryPlayersPageState();
}

class _CategoryPlayersPageState extends State<CategoryPlayersPage> {
  final PesService _pesService = PesService();
  List<PesCategory> _categories = [];
  bool _isLoading = true;
  ErrorType? _errorType;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorType = null;
        _errorMessage = null;
      });
    }
    try {
      final categories = await _pesService.fetchCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          final errorStr = e.toString().toLowerCase();
          if (errorStr.contains('429')) {
            _errorType = ErrorType.serverBusy;
          } else if (errorStr.contains('socketexception') ||
              errorStr.contains('failed host lookup')) {
            _errorType = ErrorType.noInternet;
          } else {
            _errorType = ErrorType.other;
          }
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    Widget content;

    if (_isLoading) {
      content = const Center(
          child: CircularProgressIndicator(color: Color(0xFF06DF5D)));
    } else if (_errorType != null) {
      content = ErrorDisplayWidget(
        errorType: _errorType!,
        errorMessage: _errorMessage,
        onRetry: _loadCategories,
      );
    } else if (_categories.isEmpty) {
      content = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.category_outlined,
                size: 64, color: isDark ? Colors.white24 : Colors.grey),
            const SizedBox(height: 16),
            Text(
              "No categories found",
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white54 : Colors.black54,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    } else {
      /*
      content = GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final accents = [
            const Color(0xFF06DF5D),
            Colors.greenAccent,
            Colors.orangeAccent,
            Colors.blueAccent
          ];
          final color = accents[index % accents.length];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StandartPlayersPage(
                    initialUrl: category.url,
                    title: category.name,
                    showPagination: false,
                  ),
                ),
              );
            },
            child: GlassContainer(
              borderRadius: 20,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.bolt_rounded, color: color, size: 20),
                    ),
                    const Spacer(),
                    Text(
                      category.name,
                      style: GoogleFonts.outfit(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
      */

      content = ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StandartPlayersPage(
                      initialUrl: category.url,
                      title: category.name,
                      showPagination: false,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Preview Players Row
                    SizedBox(
                      height: 80,
                      child: FutureBuilder<List<PesPlayer>>(
                        future: _pesService.fetchPlayers(
                          customUrl: category.url,
                          page: 1, // Get first page
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF06DF5D),
                                ),
                              ),
                            );
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          final previewPlayers =
                              snapshot.data!.take(4).toList();

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: previewPlayers.map((player) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    player.imageUrl,
                                    width: 60,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, o, s) => Container(
                                      width: 60,
                                      height: 80,
                                      color: Colors.grey.withOpacity(0.2),
                                      child: const Icon(Icons.person,
                                          color: Colors.grey),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Category Name
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF06DF5D).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.bolt_rounded,
                            color: Color(0xFF06DF5D),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            category.name,
                            style: GoogleFonts.outfit(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: isDark ? Colors.white24 : Colors.black26,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: themeProvider.getTheme().scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Categories',
            style: GoogleFonts.outfit(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold)),
        backgroundColor: themeProvider.getTheme().scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        actions: [
          IconButton(
            onPressed: _loadCategories,
            icon: Icon(Icons.refresh_rounded,
                color: isDark ? Colors.white54 : Colors.black54),
            tooltip: 'Refresh Categories',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: content,
    );
  }
}
