import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../services/pes_service.dart';
import '../models/pes_models.dart';
import '../widgets/error_display_widget.dart';
import 'StandartPlayersPage.dart'; // Navigate to this

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
    Widget content;

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_errorType != null) {
      content = ErrorDisplayWidget(
        errorType: _errorType!,
        errorMessage: _errorMessage,
        onRetry: _loadCategories,
      );
    } else {
      content = GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StandartPlayersPage(
                    initialUrl: category.url,
                    title: category.name,
                    showPagination: false, // Hide pagination
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardSurface.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Center(
                  child: Text(
                    category.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadCategories,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Categories',
          )
        ],
      ),
      body: content,
    );
  }
}
