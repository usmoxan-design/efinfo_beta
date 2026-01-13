import 'dart:io';
import 'package:efinfo_beta/models/account_post.dart';
import 'package:efinfo_beta/services/auth_service.dart';
import 'package:efinfo_beta/services/marketplace_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class MarketplaceAddEditPage extends StatefulWidget {
  final AccountPost? post;
  const MarketplaceAddEditPage({super.key, this.post});

  @override
  State<MarketplaceAddEditPage> createState() => _MarketplaceAddEditPageState();
}

class _MarketplaceAddEditPageState extends State<MarketplaceAddEditPage> {
  final MarketplaceService _marketplaceService = MarketplaceService();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _telegramController;
  late TextEditingController _phoneController;

  bool _googleAccount = false;
  bool _konamiId = false;
  bool _gameCenter = false;
  bool _isExchange = false;

  List<File> _imageFiles = [];
  List<String> _existingImageUrls = [];
  List<String> _existingFileIds = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post?.title ?? '');
    _descController =
        TextEditingController(text: widget.post?.description ?? '');
    _priceController = TextEditingController(
        text: widget.post?.price.toInt().toString() ?? '');
    _telegramController =
        TextEditingController(text: widget.post?.telegramUser ?? '');
    _phoneController =
        TextEditingController(text: widget.post?.phoneNumber ?? '+998');

    _googleAccount = widget.post?.googleAccount ?? false;
    _konamiId = widget.post?.konamiId ?? false;
    _gameCenter = widget.post?.gameCenter ?? false;
    _isExchange = widget.post?.isExchange ?? false;

    if (widget.post != null) {
      _existingImageUrls = List.from(widget.post!.imageUrls);
      _existingFileIds = List.from(widget.post!.fileIds);
    }
  }

  Future<void> _pickImages() async {
    if (_imageFiles.length + _existingImageUrls.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Maksimal 3 ta rasm yuklash mumkin")));
      return;
    }

    final picked = await ImagePicker().pickMultiImage(imageQuality: 70);

    if (picked.isNotEmpty) {
      setState(() {
        _imageFiles.addAll(picked
            .take(3 - (_imageFiles.length + _existingImageUrls.length))
            .map((e) => File(e.path)));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageFiles.removeAt(index);
    });
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImageUrls.removeAt(index);
      _existingFileIds.removeAt(index);
    });
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validation: 1-3 images
    bool hasImages = _imageFiles.isNotEmpty || _existingImageUrls.isNotEmpty;
    if (!hasImages) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Kamida 1 ta rasm yuklang")));
      return;
    }

    if (_imageFiles.length + _existingImageUrls.length > 3) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Maksimal 3 ta rasm yuklash mumkin")));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: const Center(
            child: CircularProgressIndicator(color: Color(0xFF06DF5D))),
      ),
    );

    try {
      final user = _authService.currentUser;
      if (user == null) throw "Tizimga kirmagansiz";

      // Charge 100 coins for NEW posts
      if (widget.post == null) {
        final coins = await _authService.getCurrentUserCoins();
        if (coins < 100) {
          throw "E'lon berish uchun 100 Coin kerak. Sizda: $coins";
        }
        await _authService.updateUserCoins(user.uid, -100);
      }

      final post = AccountPost(
        id: widget.post?.id ?? '',
        userId: widget.post?.userId ?? user.uid,
        userName:
            widget.post?.userName ?? (user.displayName ?? 'Foydalanuvchi'),
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        price: double.parse(_priceController.text.trim().isEmpty
            ? "0"
            : _priceController.text.trim()),
        imageUrls: _existingImageUrls,
        fileIds: _existingFileIds,
        googleAccount: _googleAccount,
        konamiId: _konamiId,
        gameCenter: _gameCenter,
        telegramUser: _telegramController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        views: widget.post?.views ?? [],
        createdAt: widget.post?.createdAt ?? DateTime.now(),
        isAuthorAdmin: widget.post?.isAuthorAdmin ?? false,
        isExchange: _isExchange,
      );

      final double price = _isExchange
          ? 0
          : (double.tryParse(_priceController.text.trim()) ?? 0);
      final updatedPost = AccountPost(
        id: post.id,
        userId: post.userId,
        userName: post.userName,
        title: post.title,
        description: post.description,
        price: price,
        imageUrls: post.imageUrls,
        fileIds: post.fileIds,
        googleAccount: post.googleAccount,
        konamiId: post.konamiId,
        gameCenter: post.gameCenter,
        telegramUser: post.telegramUser,
        phoneNumber: post.phoneNumber,
        views: post.views,
        createdAt: post.createdAt,
        isAuthorAdmin: post.isAuthorAdmin,
        isExchange: post.isExchange,
      );

      if (widget.post == null) {
        await _marketplaceService.addPost(updatedPost, _imageFiles);
      } else {
        await _marketplaceService.updatePost(updatedPost, _imageFiles,
            deletedFileIds: widget.post!.fileIds
                .where((id) => !_existingFileIds.contains(id))
                .toList());
      }

      if (mounted) {
        if (widget.post == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("E'lon muvaffaqiyatli saqlandi! (-100 Coin)")));
        }
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context); // Close loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      }
    }
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
            pinned: true,
            title: Text(widget.post == null ? "Yangi e'lon" : "Tahrirlash",
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
            elevation: 0,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image Picker Section
                    _buildSectionTitle(
                        "Rasmlar (${_imageFiles.length + (widget.post?.imageUrls.length ?? 0)}/3)"),
                    SizedBox(
                      height: 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          // Existing images (if editing)
                          ..._existingImageUrls.asMap().entries.map((entry) =>
                              Stack(
                                children: [
                                  Container(
                                    width: 120,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      image: DecorationImage(
                                          image: NetworkImage(entry.value),
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  Positioned(
                                    right: 16,
                                    top: 4,
                                    child: GestureDetector(
                                      onTap: () =>
                                          _removeExistingImage(entry.key),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle),
                                        child: const Icon(Icons.close,
                                            size: 14, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                          // New local images
                          ..._imageFiles.asMap().entries.map((entry) => Stack(
                                children: [
                                  Container(
                                    width: 120,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      image: DecorationImage(
                                          image: FileImage(entry.value),
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  Positioned(
                                    right: 16,
                                    top: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(entry.key),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle),
                                        child: const Icon(Icons.close,
                                            size: 14, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                          // Add button
                          if (_imageFiles.length +
                                  (widget.post?.imageUrls.length ?? 0) <
                              3)
                            GestureDetector(
                              onTap: _pickImages,
                              child: Container(
                                width: 120,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.03)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color:
                                          Colors.blueAccent.withOpacity(0.2)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate_rounded,
                                        size: 32,
                                        color:
                                            Colors.blueAccent.withOpacity(0.5)),
                                    const SizedBox(height: 4),
                                    Text("Rasm qo'shish",
                                        style: GoogleFonts.outfit(
                                            fontSize: 10,
                                            color: Colors.blueAccent,
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildSectionTitle("Umumiy ma'lumot"),
                    _buildCard([
                      TextFormField(
                        controller: _titleController,
                        style: GoogleFonts.outfit(),
                        maxLength: 50,
                        decoration:
                            _inputDecoration("Sarlavha", Icons.title_rounded),
                        validator: (v) {
                          if (v!.isEmpty) return "Sarlavha majburiy";
                          if (v.length < 5) return "Kamida 5 ta belgi kiriting";
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descController,
                        style: GoogleFonts.outfit(),
                        decoration:
                            _inputDecoration("Tavsif", Icons.notes_rounded),
                        maxLines: 4,
                        maxLength: 500,
                        validator: (v) {
                          if (v!.isEmpty) return "Tavsif majburiy";
                          final words = v.trim().split(RegExp(r'\s+'));
                          if (words.length < 5)
                            return "Kamida 5 ta so'z yozing";
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      if (!_isExchange)
                        TextFormField(
                          controller: _priceController,
                          style: GoogleFonts.outfit(),
                          decoration: _inputDecoration(
                              "Narxi (so'm)", Icons.payments_rounded),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (_isExchange) return null;
                            if (v!.isEmpty) return "Majburiy";
                            final val = double.tryParse(v);
                            if (val == null) return "To'g'ri raqam kiriting";
                            return null;
                          },
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.swap_horiz_rounded,
                                  color: Colors.blueAccent),
                              const SizedBox(width: 12),
                              Text("Obmen (Narx shart emas)",
                                  style: GoogleFonts.outfit(
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                    ], isDark),
                    const SizedBox(height: 24),

                    _buildSectionTitle("Ulanishlar & Obmen"),
                    _buildCard([
                      _buildSwitchTile("Google Account", _googleAccount,
                          (v) => setState(() => _googleAccount = v)),
                      _buildSwitchTile("Konami ID", _konamiId,
                          (v) => setState(() => _konamiId = v)),
                      _buildSwitchTile("GameCenter", _gameCenter,
                          (v) => setState(() => _gameCenter = v)),
                      const Divider(),
                      _buildSwitchTile("To'liq Obmen (Faqat almashish)",
                          _isExchange, (v) => setState(() => _isExchange = v)),
                    ], isDark),
                    const SizedBox(height: 24),

                    _buildSectionTitle("Bog'lanish"),
                    _buildCard([
                      TextFormField(
                        controller: _telegramController,
                        style: GoogleFonts.outfit(),
                        decoration: _inputDecoration(
                            "Telegram (@username)", Icons.send_rounded),
                        validator: (v) => v!.isEmpty ? "Majburiy" : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        style: GoogleFonts.outfit(),
                        decoration: _inputDecoration(
                            "Telefon raqami (ixtiyoriy)", Icons.phone_rounded),
                        keyboardType: TextInputType.phone,
                      ),
                    ], isDark),
                    const SizedBox(height: 40),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text(
                              widget.post == null
                                  ? "E'lonni joylash (100 Coin)"
                                  : "Yangilash",
                              style: GoogleFonts.outfit(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title,
          style: GoogleFonts.outfit(
              fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
    );
  }

  Widget _buildCard(List<Widget> children, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161618) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.03)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile.adaptive(
      title: Text(title, style: GoogleFonts.outfit(fontSize: 15)),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      activeColor: Colors.blueAccent,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.outfit(fontSize: 14, color: Colors.grey),
      prefixIcon: Icon(icon, color: Colors.blueAccent, size: 20),
      filled: true,
      fillColor: isDark
          ? Colors.black.withOpacity(0.2)
          : Colors.grey.withOpacity(0.05),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
