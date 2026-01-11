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

  File? _imageFile;
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
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null && widget.post == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Rasm tanlang")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _authService.currentUser;
      if (user == null) throw "Tizimga kirmagansiz";

      if (widget.post == null) {
        int count = await _marketplaceService.getUserPostCount(user.uid);
        if (count >= 2) throw "Maksimal 2 ta e'lon qo'ya olasiz!";
      }

      final post = AccountPost(
        id: widget.post?.id ?? '',
        userId: user.uid,
        userName: user.displayName ?? 'Foydalanuvchi',
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        imageUrl: widget.post?.imageUrl ?? '',
        fileId: widget.post?.fileId ?? '',
        googleAccount: _googleAccount,
        konamiId: _konamiId,
        gameCenter: _gameCenter,
        telegramUser: _telegramController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        views: widget.post?.views ?? [],
        createdAt: widget.post?.createdAt ?? DateTime.now(),
      );

      if (widget.post == null) {
        await _marketplaceService.addPost(post, _imageFile!);
      } else {
        await _marketplaceService.updatePost(post, _imageFile);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                    _buildSectionTitle("Rasm"),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 220,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.03)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: Colors.blueAccent.withOpacity(0.2)),
                          image: (_imageFile != null)
                              ? DecorationImage(
                                  image: FileImage(_imageFile!),
                                  fit: BoxFit.cover)
                              : (widget.post != null)
                                  ? DecorationImage(
                                      image:
                                          NetworkImage(widget.post!.imageUrl),
                                      fit: BoxFit.cover)
                                  : null,
                        ),
                        child: (_imageFile == null && widget.post == null)
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_rounded,
                                      size: 48,
                                      color:
                                          Colors.blueAccent.withOpacity(0.5)),
                                  const SizedBox(height: 12),
                                  Text("Skrenshot yuklash",
                                      style: GoogleFonts.outfit(
                                          color: Colors.blueAccent,
                                          fontWeight: FontWeight.w500)),
                                ],
                              )
                            : Container(
                                alignment: Alignment.bottomRight,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.4)
                                      ]),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.edit_rounded,
                                      size: 18, color: Colors.blueAccent),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildSectionTitle("Umumiy ma'lumot"),
                    _buildCard([
                      TextFormField(
                        controller: _titleController,
                        style: GoogleFonts.outfit(),
                        decoration:
                            _inputDecoration("Sarlavha", Icons.title_rounded),
                        validator: (v) => v!.isEmpty ? "Majburiy" : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descController,
                        style: GoogleFonts.outfit(),
                        decoration:
                            _inputDecoration("Tavsif", Icons.notes_rounded),
                        maxLines: 4,
                        validator: (v) => v!.isEmpty ? "Majburiy" : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _priceController,
                        style: GoogleFonts.outfit(),
                        decoration: _inputDecoration(
                            "Narxi (so'm)", Icons.payments_rounded),
                        keyboardType: TextInputType.number,
                        validator: (v) => double.tryParse(v!) == null
                            ? "To'g'ri raqam kiriting"
                            : null,
                      ),
                    ], isDark),
                    const SizedBox(height: 24),

                    _buildSectionTitle("Ulanishlar (Linked Accounts)"),
                    _buildCard([
                      _buildSwitchTile("Google Account", _googleAccount,
                          (v) => setState(() => _googleAccount = v)),
                      _buildSwitchTile("Konami ID", _konamiId,
                          (v) => setState(() => _konamiId = v)),
                      _buildSwitchTile("GameCenter", _gameCenter,
                          (v) => setState(() => _gameCenter = v)),
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
                            "Telefon raqami", Icons.phone_rounded),
                        keyboardType: TextInputType.phone,
                        validator: (v) => v!.isEmpty ? "Majburiy" : null,
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
                                  ? "E'lonni joylash"
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
