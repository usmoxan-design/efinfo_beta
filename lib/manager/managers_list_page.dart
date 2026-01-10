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
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ManagersListPage extends StatefulWidget {
  const ManagersListPage({super.key});

  @override
  State<ManagersListPage> createState() => _ManagersListPageState();
}

class _ManagersListPageState extends State<ManagersListPage> {
  List<Manager> managers = [];
  bool isLoading = true;

  // Search and Filter State
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String? _selectedPlayStyle;
  String? _selectedFormation;

  // View State
  bool _areItemsExpanded = true;

  @override
  void initState() {
    super.initState();
    loadManagers();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadManagers() async {
    setState(() => isLoading = true);
    try {
      if (await hasInternet()) {
        final response = await http.get(Uri.parse(
            'https://raw.githubusercontent.com/usmoxan-design/efinfo_data/refs/heads/main/managers.json'));
        if (response.statusCode == 200) {
          final List<dynamic> remoteData = json.decode(response.body);
          if (mounted) {
            setState(() {
              managers =
                  remoteData.map((json) => Manager.fromJson(json)).toList();
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading remote managers: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<bool> hasInternet() async {
    if (kIsWeb) return true;
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  List<Manager> get _filteredManagers {
    return managers.where((m) {
      // Search Logic
      final q = _searchQuery.toLowerCase();
      final matchesSearch = m.name.toLowerCase().contains(q) ||
          m.team.toLowerCase().contains(q) ||
          m.fullName.toLowerCase().contains(q);

      if (!matchesSearch) return false;

      // Filter by Play Style
      if (_selectedPlayStyle != null) {
        final rating = m.teamPlaystyle[_selectedPlayStyle] ?? 0;
        // Assume users want managers proficient in this style (e.g., >= 70)
        if (rating < 70) return false;
      }

      // Filter by Formation (Type)
      if (_selectedFormation != null && _selectedFormation!.isNotEmpty) {
        if (m.type != _selectedFormation) return false;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        // Sort logic: If playstyle is selected, sort by that rating descending.
        // Otherwise, maybe sort by name? Or just keep original order.
        if (_selectedPlayStyle != null) {
          final valA = a.teamPlaystyle[_selectedPlayStyle] ?? 0;
          final valB = b.teamPlaystyle[_selectedPlayStyle] ?? 0;
          return valB.compareTo(valA); // highest first
        }
        return 0;
      });
  }

  void _showFilterSheet(bool isDark) {
    // Collect unique formations
    final formations = managers.map((m) => m.type).toSet().toList()..sort();

    // Collect unique playstyles (from all managers)
    final Set<String> allPlayStyles = {};
    for (var m in managers) {
      allPlayStyles.addAll(m.teamPlaystyle.keys);
    }
    final playStylesList = allPlayStyles.toList()..sort();

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Filtrlash",
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Clear filters
                          setState(() {
                            // Updates _ManagersListPageState
                            _selectedPlayStyle = null;
                            _selectedFormation = null;
                          });
                          // Also update modal state to reflect changes visually immediately if needed
                          setModalState(() {
                            // This is just to satisfy the pattern, though the main values are in parent state.
                            // But since chips read from parent state, we need to make sure parent state update triggers rebuild here?
                            // No, setState updates parent. But the modal content is inside StatefulBuilder.
                            // We should update the values (parent state) and then call setModalState to rebuild the sheet.
                          });
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Tozalash",
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF06DF5D),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Play Style Filter
                  Text(
                    "O'yin uslubi (Play Style)",
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: playStylesList.map((style) {
                      final isSelected = _selectedPlayStyle == style;
                      return ChoiceChip(
                        label: Text(style),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            // Update parent state directly (since _ManagersListPageState vars are accessible)
                            _selectedPlayStyle = selected ? style : null;
                          });
                          // We also strictly need to call setState on the parent if we want the background list to update live?
                          // The user probably expects to click "Apply".
                          // So we just update the variables. But wait, variables are in _ManagersListPageState.
                          // Yes, this closure captures the parent instance.
                        },
                        backgroundColor:
                            isDark ? Colors.black26 : Colors.grey[100],
                        selectedColor: const Color(0xFF06DF5D).withOpacity(0.2),
                        labelStyle: GoogleFonts.outfit(
                          color: isSelected
                              ? const Color(0xFF06DF5D)
                              : (isDark ? Colors.white : Colors.black),
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF06DF5D)
                              : Colors.transparent,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Formation Filter
                  Text(
                    "Taktika (Formation)",
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 150),
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: formations.map((fmt) {
                          final isSelected = _selectedFormation == fmt;
                          return ChoiceChip(
                            label: Text(fmt),
                            selected: isSelected,
                            onSelected: (selected) {
                              setModalState(() {
                                _selectedFormation = selected ? fmt : null;
                              });
                            },
                            backgroundColor:
                                isDark ? Colors.black26 : Colors.grey[100],
                            selectedColor:
                                const Color(0xFF06DF5D).withOpacity(0.2),
                            labelStyle: GoogleFonts.outfit(
                              color: isSelected
                                  ? const Color(0xFF06DF5D)
                                  : (isDark ? Colors.white : Colors.black),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFF06DF5D)
                                  : Colors.transparent,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Apply filter
                        setState(() {}); // Rebuild main page
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF06DF5D),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        "Qo'llash (Apply)",
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final filteredList = _filteredManagers;

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
      body: Column(
        children: [
          // Search and Filter Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.black12,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: GoogleFonts.outfit(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: "Menejer ismini qidirish...",
                        hintStyle: GoogleFonts.outfit(
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Toggle Collapse/Expand Button
                InkWell(
                  onTap: () {
                    setState(() {
                      _areItemsExpanded = !_areItemsExpanded;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.black12,
                      ),
                    ),
                    child: Icon(
                      _areItemsExpanded ? Icons.unfold_less : Icons.unfold_more,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Filter Button
                InkWell(
                  onTap: () => _showFilterSheet(isDark),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: (_selectedPlayStyle != null ||
                              _selectedFormation != null)
                          ? const Color(0xFF06DF5D).withOpacity(0.2)
                          : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: (_selectedPlayStyle != null ||
                                _selectedFormation != null)
                            ? const Color(0xFF06DF5D)
                            : (isDark ? Colors.white12 : Colors.black12),
                      ),
                    ),
                    child: Icon(
                      Icons.tune,
                      color: (_selectedPlayStyle != null ||
                              _selectedFormation != null)
                          ? const Color(0xFF06DF5D)
                          : (isDark ? Colors.white : Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF06DF5D)))
                : filteredList.isEmpty
                    ? Center(
                        child: Text("Menejer topilmadi",
                            style: GoogleFonts.outfit(
                                color: isDark ? Colors.white : Colors.black)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: filteredList.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.05)
                                      : Colors.black.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: isDark
                                          ? Colors.white10
                                          : Colors.black12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline_rounded,
                                        color: isDark
                                            ? Colors.white54
                                            : Colors.black54,
                                        size: 18),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "Menejerlar bazasida ma'lumotlarda xatoliklar yoki kamchiliklar bo'lishi mumkin. Agar xatolik topsangiz, iltimos Telegram orqali @efootball_info_ceo ga xabar bering.",
                                        style: GoogleFonts.outfit(
                                          color: isDark
                                              ? Colors.white54
                                              : Colors.black54,
                                          fontSize: 11,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          final manager = filteredList[index - 1];
                          return _buildManagerCard(context, manager, isDark);
                        },
                      ),
          ),
        ],
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
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          color: Colors.grey,
                          child: CachedNetworkImage(
                            imageUrl: manager.imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color:
                                  isDark ? Colors.grey[900] : Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF06DF5D),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color:
                                  isDark ? Colors.grey[900] : Colors.grey[200],
                              child: const Icon(Icons.person, size: 40),
                            ),
                          ),
                        ),
                      ),
                      if (manager.boosters != null &&
                          manager.boosters!.isNotEmpty)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 24, // Height for the fade/overlay area
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(16)),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: manager.boosters!.take(2).map((_) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 1),
                                  child: Image.asset(
                                    'assets/images/elements/booster_slot.png',
                                    width: 18,
                                    height: 18,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                    ],
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
              if (_areItemsExpanded) ...[
                const SizedBox(height: 16),
                // Playstyles
                ...manager.teamPlaystyle.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        _buildRatingBox(entry.value),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: isDark ? Colors.white : Colors.black,
                              fontWeight: _selectedPlayStyle == entry.key
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (_selectedPlayStyle == entry.key)
                          const Icon(Icons.check_circle,
                              color: Color(0xFF06DF5D), size: 16),
                      ],
                    ),
                  );
                }),
              ],
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
