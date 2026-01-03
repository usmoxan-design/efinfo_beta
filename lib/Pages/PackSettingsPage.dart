import 'package:efinfo_beta/theme/theme_provider.dart';
import 'package:efinfo_beta/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PackSettingsPage extends StatefulWidget {
  final int currentCoins;
  final Function(int) onCoinsUpdated;

  const PackSettingsPage({
    super.key,
    required this.currentCoins,
    required this.onCoinsUpdated,
  });

  @override
  State<PackSettingsPage> createState() => _PackSettingsPageState();
}

class _PackSettingsPageState extends State<PackSettingsPage> {
  late TextEditingController _controller;
  final int minCoins = 0;
  final int maxCoins = 90000;
  late int tempCoins;

  @override
  void initState() {
    super.initState();
    tempCoins = widget.currentCoins;
    _controller = TextEditingController(text: tempCoins.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _update(int val) {
    if (val < minCoins || val > maxCoins) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Tangalar limiti buzildi (0 - 90,000)!"),
            backgroundColor: Colors.redAccent),
      );
      return;
    }
    setState(() {
      tempCoins = val;
      _controller.text = tempCoins.toString();
    });
  }

  void _save() {
    int? val = int.tryParse(_controller.text);
    if (val != null && val >= minCoins && val <= maxCoins) {
      widget.onCoinsUpdated(val);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Tangalar muvaffaqiyatli saqlandi!"),
            backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Noto'g'ri qiymat kiritildi!"),
            backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white54 : Colors.black54;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF001F3F) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text("Tangalar sozlamalari",
            style: GoogleFonts.outfit(
                color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            GlassContainer(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.monetization_on,
                      color: Colors.amber, size: 80),
                  const SizedBox(height: 16),
                  Text(
                    "Tangalarni o'zgartirish",
                    style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    onChanged: (val) {
                      int? v = int.tryParse(val);
                      if (v != null) tempCoins = v;
                    },
                    style: GoogleFonts.outfit(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber),
                    decoration: InputDecoration(
                      hintText: "0 - 90,000",
                      hintStyle: GoogleFonts.outfit(
                          color: subColor.withOpacity(0.3), fontSize: 20),
                      border: InputBorder.none,
                    ),
                  ),
                  Divider(color: textColor.withOpacity(0.1)),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildAdjustBtn(
                          "-100", () => _update(tempCoins - 100), isDark),
                      _buildAdjustBtn(
                          "-1000", () => _update(tempCoins - 1000), isDark),
                      _buildAdjustBtn(
                          "+100", () => _update(tempCoins + 100), isDark),
                      _buildAdjustBtn(
                          "+1000", () => _update(tempCoins + 1000), isDark),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 5,
              ),
              child: Text("Saqlash",
                  style: GoogleFonts.outfit(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const Spacer(),
            Text(
              "Maksimal tangalar: 90,000\nMinimal tangalar: 0",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: subColor),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAdjustBtn(String label, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
        ),
        child: Text(label,
            style: GoogleFonts.outfit(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}
