import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:efinfo_beta/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    if (kIsWeb) {
      final web = await deviceInfo.webBrowserInfo;
      return {
        'browser': web.browserName.name,
        'platform': web.platform,
        'userAgent': web.userAgent,
      };
    }

    if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      return {
        'model': android.model,
        'brand': android.brand,
        'version': android.version.release,
        'sdk': android.version.sdkInt,
        'manufacturer': android.manufacturer,
      };
    } else if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      return {
        'model': ios.model,
        'name': ios.name,
        'systemVersion': ios.systemVersion,
        'identifierForVendor': ios.identifierForVendor,
      };
    }
    return {'platform': Platform.operatingSystem};
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await _authService.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        if (_passwordController.text != _confirmPasswordController.text) {
          throw "Parollar mos kelmadi!";
        }

        String email = _emailController.text.trim();
        if (!email.toLowerCase().endsWith("@efhub.uz")) {
          // If the user didn't type @efhub.uz, append it or throw error?
          // User asked: "doim @efhub.uz bo'lishi majbur bo'lsin"
          // I'll make the field just for the name part and append @efhub.uz behind the scenes
          // or validate it. I'll validate it.
          throw "Email @efhub.uz bilan tugashi kerak!";
        }

        final deviceData = await _getDeviceInfo();

        await _authService.signUp(
          email,
          _passwordController.text.trim(),
          _nameController.text.trim(),
          deviceInfo: deviceData,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Xatolik: ${e.toString()}"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded,
              color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isLogin ? "Kirish" : "Ro'yxatdan o'tish",
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _isLogin
                      ? "Hisobingizga kiring va davom eting."
                      : "Yangi hisob yarating va imkoniyatlardan foydalaning.",
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 48),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (!_isLogin) ...[
                        _buildField(
                          label: "Ismingiz",
                          controller: _nameController,
                          validator: (val) =>
                              val!.isEmpty ? "Ismni kiriting" : null,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 20),
                      ],
                      _buildField(
                        label: _isLogin ? "Email" : "Email uchun nom kiriting",
                        controller: _emailController,
                        hint: _isLogin ? "example@efhub.uz" : "namuna@efhub.uz",
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                          if (val!.isEmpty) return "Emailni kiriting";
                          if (!_isLogin &&
                              !val.toLowerCase().endsWith("@efhub.uz")) {
                            return "Doim oxirida @efhub.uz bo'lishi shart!";
                          }
                          if (!val.contains("@"))
                            return "To'g'ri email kiriting";
                          return null;
                        },
                        isDark: isDark,
                      ),
                      const SizedBox(height: 20),
                      _buildField(
                        label: _isLogin ? "Parol" : "Parol o'rnating",
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        validator: (val) =>
                            val!.length < 6 ? "Minimal 6 belgi" : null,
                        isDark: isDark,
                        suffix: IconButton(
                          icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                              size: 20),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      if (!_isLogin) ...[
                        const SizedBox(height: 20),
                        _buildField(
                          label: "Parolni tasdiqlash",
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          validator: (val) {
                            if (val!.isEmpty) return "Parolni tasdiqlang";
                            if (val != _passwordController.text)
                              return "Parollar mos emas";
                            return null;
                          },
                          isDark: isDark,
                          suffix: IconButton(
                            icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                                size: 20),
                            onPressed: () => setState(() =>
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword),
                          ),
                        ),
                      ],
                      const SizedBox(height: 48),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  _isLogin ? "KIRISH" : "DAVOM ETISH",
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() {
                      _isLogin = !_isLogin;
                      _formKey.currentState?.reset();
                    }),
                    child: RichText(
                      text: TextSpan(
                        text: _isLogin
                            ? "Hisobingiz yo'qmi? "
                            : "Hisobingiz bormi? ",
                        style: GoogleFonts.outfit(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: _isLogin ? "Ro'yxatdan o'ting" : "Kiring",
                            style: const TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    String? hint,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    required bool isDark,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          cursorColor: Colors.blueAccent,
          style: GoogleFonts.outfit(
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(
                color: isDark ? Colors.white10 : Colors.black12),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
            suffixIcon: suffix,
            enabledBorder: UnderlineInputBorder(
              borderSide:
                  BorderSide(color: isDark ? Colors.white10 : Colors.black12),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blueAccent),
            ),
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }
}
