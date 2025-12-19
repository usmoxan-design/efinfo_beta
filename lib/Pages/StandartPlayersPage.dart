import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:efinfo_beta/widgets/pes_player_card_widget.dart';
import 'package:flutter/material.dart';
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
      // 429 Retry Logic
      if (e.toString().contains('429') && retryCount < 3) {
        int delayInSeconds = 2 * (retryCount + 1);
        await Future.delayed(Duration(seconds: delayInSeconds));
        return _loadPlayers(retryCount: retryCount + 1);
      }

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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardSurface,
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
                  const Text(
                    "Search Conditions",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Player Type Filter - Only show if strict search not active
                  if (!isCategoryView)
                    Row(
                      children: [
                        const Text(
                          "Filter: ",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
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
                              dropdownColor: AppColors.cardSurface,
                              isExpanded: true,
                              underline: const SizedBox(),
                              style: const TextStyle(color: Colors.white),
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
                    const Text(
                      "Featured Players:",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
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
                        dropdownColor: AppColors.cardSurface,
                        isExpanded: true,
                        underline: const SizedBox(),
                        style: const TextStyle(color: Colors.white),
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
                      labelStyle: const TextStyle(color: Colors.white70),
                      hintText: "E.g. Messi",
                      hintStyle: const TextStyle(color: Colors.white30),
                      filled: true,
                      fillColor: Colors.black12,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.white70),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (val) {
                      _nameFilter = val;
                    },
                    controller: TextEditingController(text: _nameFilter),
                  ),
                  const SizedBox(height: 16),

                  // Position Filter - Hide if in category view
                  if (!isCategoryView) ...[
                    const Text("Position",
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildPositionChip("All", "", setModalState),
                          _buildPositionChip("CF", "cf", setModalState),
                          _buildPositionChip("SS", "ss", setModalState),
                          _buildPositionChip("LWF", "lwf", setModalState),
                          _buildPositionChip("RWF", "rwf", setModalState),
                          _buildPositionChip("AMF", "amf", setModalState),
                          _buildPositionChip("CMF", "cmf", setModalState),
                          _buildPositionChip("DMF", "dmf", setModalState),
                          _buildPositionChip("LMF", "lmf", setModalState),
                          _buildPositionChip("RMF", "rmf", setModalState),
                          _buildPositionChip("LB", "lb", setModalState),
                          _buildPositionChip("RB", "rb", setModalState),
                          _buildPositionChip("CB", "cb", setModalState),
                          _buildPositionChip("GK", "gk", setModalState),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Sort & Order
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Sort",
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 14)),
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
                                dropdownColor: AppColors.cardSurface,
                                isExpanded: true,
                                underline: const SizedBox(),
                                style: const TextStyle(color: Colors.white),
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
                            const Text("Order",
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 14)),
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
                                dropdownColor: AppColors.cardSurface,
                                isExpanded: true,
                                underline: const SizedBox(),
                                style: const TextStyle(color: Colors.white),
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
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white30),
                          ),
                          child: const Text("Clear All"),
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
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Search"),
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
      String label, String value, StateSetter setStateFunc) {
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
        backgroundColor: Colors.black12,
        selectedColor: AppColors.accent.withOpacity(0.3),
        checkmarkColor: AppColors.accent,
        labelStyle:
            TextStyle(color: isSelected ? AppColors.accent : Colors.white70),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
                color: isSelected ? AppColors.accent : Colors.white10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                if (!_isLoading)
                  Text(
                    "Bu sahifada ${_players.length} ta o'yinchi topildi",
                    style: const TextStyle(
                      color: AppColors.textDim,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: _showFilterModal,
                icon: const Icon(Icons.tune_rounded, color: AppColors.accent),
                tooltip: 'Filter',
              ),
              IconButton(
                onPressed: _refresh,
                icon: const Icon(Icons.refresh_rounded,
                    color: AppColors.textGrey),
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
                isLoading: _isLoading),
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
                          return _buildModernPlayerCard(player);
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
                    backgroundColor: AppColors.cardSurface,
                    child: const Icon(Icons.chevron_left, color: Colors.white),
                  ),
                const SizedBox(width: 10),
                FloatingActionButton.small(
                  heroTag: "next",
                  onPressed: () => _goToPage(_currentPage + 1),
                  backgroundColor: AppColors.accent,
                  child: const Icon(Icons.chevron_right, color: Colors.white),
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildModernPlayerCard(PesPlayer player) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PesPlayerDetailScreen(player: player),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
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
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      player.name,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      player.club,
                      style: const TextStyle(
                        color: AppColors.textDim,
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

  _PaginationHeaderDelegate(
      {required this.page,
      required this.totalPages,
      required this.onNext,
      required this.onPrev,
      required this.isLoading});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(
      child: Container(
        color: AppColors.background.withOpacity(0.95),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Previous
            TextButton.icon(
              onPressed: (page > 1 && !isLoading) ? onPrev : null,
              icon: const Icon(Icons.chevron_left),
              label: const Text("Oldingi"),
              style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white24),
            ),

            // Info
            Text(
              "Sahifa: $page",
              style: const TextStyle(
                  color: AppColors.accent, fontWeight: FontWeight.bold),
            ),

            // Next
            TextButton.icon(
              onPressed: (!isLoading && page < totalPages)
                  ? onNext
                  : null, // Assuming standard max
              icon: const Icon(Icons.chevron_right),
              label: const Text("Keyingi"),
              style: TextButton.styleFrom(
                  iconAlignment: IconAlignment.end,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white24),
            ),
          ],
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
