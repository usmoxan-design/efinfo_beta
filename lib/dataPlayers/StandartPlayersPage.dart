import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:efinfo_beta/widgets/glass_container.dart';
import 'package:efinfo_beta/widgets/pes_player_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/pes_service.dart';
import '../models/pes_models.dart';
import '../widgets/error_display_widget.dart';
import 'player_detail_screen.dart';

class StandartPlayersPage extends StatefulWidget {
  final String? initialUrl;
  final String title;
  final bool showPagination; // Pagination visibility control (Bottom)

  const StandartPlayersPage({
    super.key,
    this.initialUrl,
    this.title = 'eFootball Players',
    this.showPagination = true,
  });

  @override
  State<StandartPlayersPage> createState() => _StandartPlayersPageState();
}

class _StandartPlayersPageState extends State<StandartPlayersPage> {
  final PesService _pesService = PesService();
  List<PesPlayer> _players = [];
  int _currentPage = 1;
  final int _totalPages = 10; // Estimation
  bool _isLoading = false;
  ErrorType? _errorType;
  String? _errorMessage;

  // Filter State
  String _nameFilter = "";
  String _selectedPosition = ""; // "cf", "ss", etc.
  String _sort = "overall_at_max_level";
  String _order = "d"; // d=desc, a=asc
  String _selectedPlayerType = "Standard Players";

  // Featured Dropdown State
  List<PesFeaturedOption> _featuredOptions = [];
  String? _selectedFeaturedId; // Null means "None"

  @override
  void initState() {
    super.initState();
    // Initialize filter state from initialUrl if present
    if (widget.initialUrl != null) {
      try {
        final uri = Uri.parse(widget.initialUrl!);
        final qp = uri.queryParameters;

        if (qp.containsKey('name')) _nameFilter = qp['name']!;
        if (qp.containsKey('pos')) _selectedPosition = qp['pos']!;
        if (qp.containsKey('sort')) _sort = qp['sort']!;
        if (qp.containsKey('order')) _order = qp['order']!;

        // Determine Player Type & Featured
        if (qp.containsKey('featured') && qp['featured'] != '0') {
          _selectedFeaturedId = qp['featured'];
        }

        if (qp['all'] == '1') {
          _selectedPlayerType = "Show All Players";
        } else if (qp['availability'] == '0') {
          _selectedPlayerType = "Unavailable players";
        } else if (qp['featured'] == '0') {
          _selectedPlayerType = "Standard Players";
        } else {
          // Default to Standard if no specific type is found and no featured ID
          if (_selectedFeaturedId == null) {
            _selectedPlayerType = "Standard Players";
          } else {
            // If we have a featured ID, it could be "Show All" or "Standard"
            // Usually, if all=1 is missing, it's not "Show All".
            _selectedPlayerType = "Standard Players";
          }
        }
      } catch (e) {
        print("Error parsing initialUrl: $e");
      }
    }

    // Load Featured Options
    _loadFeaturedOptions();
    _loadPlayers();
  }

  Future<void> _loadFeaturedOptions() async {
    final options = await _pesService.fetchFeaturedOptions();
    if (mounted) {
      setState(() {
        _featuredOptions = options;
      });
    }
  }

  Future<void> _loadPlayers({int retryCount = 0}) async {
    if (_isLoading && retryCount == 0) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorType = null;
        _errorMessage = null;
      });
    }

    try {
      // Build filters map
      Map<String, String> filters = {};
      if (_nameFilter.isNotEmpty) filters['name'] = _nameFilter;
      if (_selectedPosition.isNotEmpty) filters['pos'] = _selectedPosition;
      filters['sort'] = _sort;
      filters['order'] = _order;

      // Apply Player Type & Featured Filters
      if (_selectedPlayerType == "Show All Players") {
        filters['all'] = "1";
      } else if (_selectedPlayerType == "Unavailable players") {
        filters['availability'] = "0";
      }

      if (_selectedFeaturedId != null) {
        filters['featured'] = _selectedFeaturedId!;
      } else if (_selectedPlayerType == "Standard Players") {
        filters['featured'] = "0";
      }

      final newPlayers = await _pesService.fetchPlayers(
        page: _currentPage,
        customUrl: widget.initialUrl,
        filters: filters,
      );

      if (mounted) {
        setState(() {
          _players = newPlayers;
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

  void _goToPage(int page) {
    if (page < 1 || page > _totalPages || page == _currentPage) return;
    setState(() {
      _currentPage = page;
    });
    _loadPlayers();
  }

  Future<void> _refresh() async {
    _currentPage = 1;
    await _loadPlayers();
  }

  void _showFilterModal() {
    bool isCategoryView = widget.initialUrl != null;

    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Search Conditions",
                    style: GoogleFonts.outfit(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Player Type Filter - Only show if strict search not active
                  if (!isCategoryView)
                    Row(
                      children: [
                        Text(
                          "Filter: ",
                          style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<String>(
                              value: _selectedPlayerType,
                              dropdownColor: isDark
                                  ? const Color(0xFF1C1C1E)
                                  : Colors.white,
                              isExpanded: true,
                              underline: const SizedBox(),
                              style: GoogleFonts.outfit(
                                  color: isDark ? Colors.white : Colors.black),
                              items: const [
                                DropdownMenuItem(
                                  value: "Standard Players",
                                  child: Text("Standard Players"),
                                ),
                                DropdownMenuItem(
                                  value: "Show All Players",
                                  child: Text("Show All Players"),
                                ),
                                DropdownMenuItem(
                                  value: "Unavailable players",
                                  child: Text("Unavailable players"),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setModalState(
                                      () => _selectedPlayerType = val);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (!isCategoryView) const SizedBox(height: 16),

                  // Featured Players Dropdown - Show IF options exist AND not in restricted category view
                  // Or if user WANTS to see it? The request said: "Featured Player filter ko'rinmayapti".
                  // This means it was hidden or empty.
                  if (!isCategoryView && _featuredOptions.isNotEmpty) ...[
                    Text(
                      "Featured Players:",
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String?>(
                        value: _selectedFeaturedId,
                        dropdownColor:
                            isDark ? const Color(0xFF1C1C1E) : Colors.white,
                        isExpanded: true,
                        underline: const SizedBox(),
                        style: GoogleFonts.outfit(
                            color: isDark ? Colors.white : Colors.black),
                        hint: const Text("None",
                            style: TextStyle(color: Colors.white60)),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text("None"),
                          ),
                          ..._featuredOptions.map((opt) {
                            return DropdownMenuItem<String?>(
                              value: opt.id,
                              child: Text(
                                opt.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }),
                        ],
                        onChanged: (val) {
                          setModalState(() {
                            _selectedFeaturedId = val;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Name Filter
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Player Name",
                      labelStyle: GoogleFonts.outfit(
                          color: isDark ? Colors.white70 : Colors.black54),
                      hintText: "E.g. Messi",
                      hintStyle: GoogleFonts.outfit(
                          color: isDark ? Colors.white30 : Colors.black26),
                      filled: true,
                      fillColor: isDark ? Colors.black12 : Colors.grey[200],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      prefixIcon:
                          const Icon(Icons.search, color: Color(0xFF06DF5D)),
                    ),
                    style: GoogleFonts.outfit(
                        color: isDark ? Colors.white : Colors.black),
                    onChanged: (val) {
                      _nameFilter = val;
                    },
                    controller: TextEditingController(text: _nameFilter),
                  ),
                  const SizedBox(height: 16),

                  // Sort & Order
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Sort",
                                style: GoogleFonts.outfit(
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                    fontSize: 14)),
                            const SizedBox(height: 8),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<String>(
                                value: _sort,
                                dropdownColor: isDark
                                    ? const Color(0xFF1C1C1E)
                                    : Colors.white,
                                isExpanded: true,
                                underline: const SizedBox(),
                                style: GoogleFonts.outfit(
                                    color:
                                        isDark ? Colors.white : Colors.black),
                                items: const [
                                  DropdownMenuItem(
                                      value: "overall_at_max_level",
                                      child: Text("Overall Rating (Max)")),
                                  DropdownMenuItem(
                                      value: "overall_rating",
                                      child: Text("Overall Rating (Lvl 1)")),
                                  DropdownMenuItem(
                                      value: "speed", child: Text("Speed")),
                                  DropdownMenuItem(
                                      value: "acceleration",
                                      child: Text("Acceleration")),
                                  DropdownMenuItem(
                                      value: "price", child: Text("Price")),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setModalState(() => _sort = val);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Order",
                                style: GoogleFonts.outfit(
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                    fontSize: 14)),
                            const SizedBox(height: 8),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<String>(
                                value: _order,
                                dropdownColor: isDark
                                    ? const Color(0xFF1C1C1E)
                                    : Colors.white,
                                isExpanded: true,
                                underline: const SizedBox(),
                                style: GoogleFonts.outfit(
                                    color:
                                        isDark ? Colors.white : Colors.black),
                                items: const [
                                  DropdownMenuItem(
                                      value: "d", child: Text("Descending")),
                                  DropdownMenuItem(
                                      value: "a", child: Text("Ascending")),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setModalState(() => _order = val);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              _nameFilter = "";
                              // Only clear context-aware filters if allowed
                              if (!isCategoryView) {
                                _selectedPosition = "";
                                _selectedPlayerType = "Standard Players";
                                _selectedFeaturedId = null;
                              }
                              _sort = "overall_at_max_level";
                              _order = "d";
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                isDark ? Colors.white : Colors.black,
                            side: BorderSide(
                                color:
                                    isDark ? Colors.white30 : Colors.black26),
                          ),
                          child: Text("Clear All", style: GoogleFonts.outfit()),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _performSearch();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF06DF5D),
                            foregroundColor: Colors.white,
                          ),
                          child: Text("Search",
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _performSearch() {
    String baseUrl = "https://pesdb.net/efootball/";
    List<String> queryParams = [];

    if (_nameFilter.isNotEmpty) {
      queryParams.add("name=${Uri.encodeComponent(_nameFilter)}");
    }
    if (_selectedPosition.isNotEmpty) {
      queryParams.add("pos=${Uri.encodeComponent(_selectedPosition)}");
    }

    // Player Type / Featured construction
    if (_selectedPlayerType == "Show All Players") {
      queryParams.add("all=1");
    } else if (_selectedPlayerType == "Unavailable players") {
      queryParams.add("availability=0");
    }

    if (_selectedFeaturedId != null) {
      queryParams.add("featured=${Uri.encodeComponent(_selectedFeaturedId!)}");
    } else if (_selectedPlayerType == "Standard Players") {
      queryParams.add("featured=0");
    }

    // Sort/Order
    queryParams.add("sort=${Uri.encodeComponent(_sort)}");
    queryParams.add("order=${Uri.encodeComponent(_order)}");

    String finalUrl = baseUrl;
    if (queryParams.isNotEmpty) {
      finalUrl += "?${queryParams.join('&')}";
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StandartPlayersPage(
          initialUrl: finalUrl,
          title: "Search Results",
        ),
      ),
    );
  }

  Widget _buildPositionChip(
      String label, String value, StateSetter setStateFunc, bool isDark) {
    bool isSelected = _selectedPosition == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          setStateFunc(() {
            _selectedPosition = selected ? value : "";
          });
        },
        backgroundColor: isDark ? Colors.black12 : Colors.grey[200],
        selectedColor: const Color(0xFF06DF5D).withOpacity(0.3),
        checkmarkColor: const Color(0xFF06DF5D),
        labelStyle: TextStyle(
            color: isSelected
                ? const Color(0xFF06DF5D)
                : (isDark ? Colors.white70 : Colors.black54)),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
                color: isSelected
                    ? const Color(0xFF06DF5D)
                    : (isDark ? Colors.white10 : Colors.black12))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: themeProvider.getTheme().scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: themeProvider.getTheme().scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: GoogleFonts.outfit(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                if (!_isLoading)
                  Text(
                    "Bu sahifada ${_players.length} ta o'yinchi topildi",
                    style: GoogleFonts.outfit(
                      color: isDark ? Colors.white54 : Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: _showFilterModal,
                icon: const Icon(Icons.tune_rounded, color: Color(0xFF06DF5D)),
                tooltip: 'Filter',
              ),
              IconButton(
                onPressed: _refresh,
                icon: Icon(Icons.refresh_rounded,
                    color: isDark ? Colors.white54 : Colors.grey),
                tooltip: 'Refresh',
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Sticky Pagination Header (Visible at Top)
          SliverPersistentHeader(
            delegate: _PaginationHeaderDelegate(
                page: _currentPage,
                totalPages: _totalPages,
                onNext: () => _goToPage(_currentPage + 1),
                onPrev: () => _goToPage(_currentPage - 1),
                isLoading: _isLoading,
                themeProvider: themeProvider),
            pinned: true,
          ),

          // Loading or Content
          _isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : (_errorType != null)
                  ? SliverFillRemaining(
                      child: ErrorDisplayWidget(
                        errorType: _errorType!,
                        errorMessage: _errorMessage,
                        onRetry: _loadPlayers,
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final player = _players[index];
                          return _buildModernPlayerCard(player, isDark);
                        }, childCount: _players.length),
                      ),
                    ),

          // Bottom spacing for comfortable scrolling
          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
      // Floating Pagination (Optional Alternative if Sticky Header isn't enough)
      // Can add a floating action button for quick "Next Page" for convenience
      floatingActionButton: _players.isNotEmpty && !_isLoading
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_currentPage > 1)
                  FloatingActionButton.small(
                    heroTag: "prev",
                    onPressed: () => _goToPage(_currentPage - 1),
                    backgroundColor:
                        isDark ? const Color(0xFF1C1C1E) : Colors.white,
                    child: Icon(Icons.chevron_left,
                        color: isDark ? Colors.white : Colors.black),
                  ),
                const SizedBox(width: 10),
                FloatingActionButton.small(
                  heroTag: "next",
                  onPressed: () => _goToPage(_currentPage + 1),
                  backgroundColor: const Color(0xFF06DF5D),
                  child: const Icon(Icons.chevron_right, color: Colors.white),
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildModernPlayerCard(PesPlayer player, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PesPlayerDetailScreen(player: player),
          ),
        );
      },
      child: GlassContainer(
        borderRadius: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PesPlayerCardWidget(player: player),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    player.name,
                    style: GoogleFonts.outfit(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    player.club,
                    style: GoogleFonts.outfit(
                      color: isDark ? Colors.white54 : Colors.black54,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaginationHeaderDelegate extends SliverPersistentHeaderDelegate {
  final int page;
  final int totalPages;
  final VoidCallback onNext;
  final VoidCallback onPrev;
  final bool isLoading;
  final ThemeProvider themeProvider;

  _PaginationHeaderDelegate(
      {required this.page,
      required this.totalPages,
      required this.onNext,
      required this.onPrev,
      required this.isLoading,
      required this.themeProvider});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isDark = themeProvider.isDarkMode;
    return SizedBox.expand(
      child: GlassContainer(
        borderRadius: 0,
        blur: 10,
        opacity: isDark ? 0.05 : 0.1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous
              TextButton.icon(
                onPressed: (page > 1 && !isLoading) ? onPrev : null,
                icon: const Icon(Icons.chevron_left),
                label: Text("Oldingi", style: GoogleFonts.outfit()),
                style: TextButton.styleFrom(
                    foregroundColor: isDark ? Colors.white : Colors.black,
                    disabledForegroundColor:
                        isDark ? Colors.white24 : Colors.black26),
              ),

              // Info
              Text(
                "Sahifa: $page",
                style: GoogleFonts.outfit(
                    color: const Color(0xFF06DF5D),
                    fontWeight: FontWeight.bold),
              ),

              // Next
              TextButton.icon(
                onPressed: (!isLoading && page < totalPages) ? onNext : null,
                icon: const Icon(Icons.chevron_right),
                label: Text("Keyingi", style: GoogleFonts.outfit()),
                style: TextButton.styleFrom(
                    iconAlignment: IconAlignment.end,
                    foregroundColor: isDark ? Colors.white : Colors.black,
                    disabledForegroundColor:
                        isDark ? Colors.white24 : Colors.black26),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 50.0;

  @override
  double get minExtent => 50.0;

  @override
  bool shouldRebuild(covariant _PaginationHeaderDelegate oldDelegate) {
    return oldDelegate.page != page || oldDelegate.isLoading != isLoading;
  }
}
