import 'dart:math';
import 'package:flutter/material.dart';
import 'package:efinfo_beta/theme/app_colors.dart';
import 'package:icons_plus/icons_plus.dart';

enum ErrorType { noInternet, serverBusy, other }

class ErrorDisplayWidget extends StatelessWidget {
  final ErrorType errorType;
  final String? errorMessage;
  final VoidCallback onRetry;

  const ErrorDisplayWidget({
    super.key,
    required this.errorType,
    this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIcon(),
          const SizedBox(height: 24),
          _buildTitle(),
          const SizedBox(height: 12),
          _buildMessage(),
          const SizedBox(height: 32),
          if (errorType == ErrorType.serverBusy) ...[
            const InteractiveMiniGame(),
            const SizedBox(height: 32),
          ],
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: Icon(errorType == ErrorType.serverBusy
                ? Icons.refresh_rounded
                : Icons.replay_rounded),
            label: Text(errorType == ErrorType.serverBusy
                ? 'Yangilash (Refresh)'
                : 'Qaytadan urunish (Retry)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    IconData iconData;
    Color iconColor;

    switch (errorType) {
      case ErrorType.noInternet:
        iconData = Icons.wifi_off_rounded;
        iconColor = Colors.orangeAccent;
        break;
      case ErrorType.serverBusy:
        iconData = Icons.dns_rounded;
        iconColor = Colors.redAccent;
        break;
      default:
        iconData = Icons.error_outline_rounded;
        iconColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, size: 80, color: iconColor),
    );
  }

  Widget _buildTitle() {
    String title;
    switch (errorType) {
      case ErrorType.noInternet:
        title = 'Internet aloqasi yo\'q';
        break;
      case ErrorType.serverBusy:
        title = 'Server vaqtincha ishlamayapti';
        break;
      default:
        title = 'Server vaqtincha ishlamayapti, keyinroq urining!';
    }

    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildMessage() {
    String message;
    switch (errorType) {
      case ErrorType.noInternet:
        message =
            'Iltimos, internet aloqasini tekshiring va qaytadan urunib ko\'ring.';
        break;
      case ErrorType.serverBusy:
        message =
            'Server vaqtincha javob bermayapti (429 Error). Ungacha kichik o\'yin bilan vaqtni o\'tkazishingiz mumkin.';
        break;
      default:
        message = errorMessage ??
            'Kutilmagan xatolik yuz berdi. Iltimos, keyinroq qayta urunib ko\'ring.';
    }

    return Text(
      message,
      style: TextStyle(
        color: Colors.white.withOpacity(0.7),
        fontSize: 16,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class InteractiveMiniGame extends StatefulWidget {
  const InteractiveMiniGame({super.key});

  @override
  State<InteractiveMiniGame> createState() => _InteractiveMiniGameState();
}

class _InteractiveMiniGameState extends State<InteractiveMiniGame>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _ballX = 0;
  double _ballY = 0;
  double _velX = 2;
  double _velY = 3;
  int _score = 0;
  final double _ballSize = 40;
  final double _gameWidth = 250;
  final double _gameHeight = 150;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 16))
      ..addListener(_updateGame)
      ..repeat();

    // Random initial position
    _ballX = Random().nextDouble() * (_gameWidth - _ballSize);
    _ballY = Random().nextDouble() * (_gameHeight - _ballSize);
  }

  void _updateGame() {
    setState(() {
      _ballX += _velX;
      _ballY += _velY;

      if (_ballX <= 0 || _ballX >= _gameWidth - _ballSize) {
        _velX = -_velX;
        _ballX = _ballX.clamp(0, _gameWidth - _ballSize);
      }
      if (_ballY <= 0 || _ballY >= _gameHeight - _ballSize) {
        _velY = -_velY;
        _ballY = _ballY.clamp(0, _gameHeight - _ballSize);
      }
    });
  }

  void _onBallTap() {
    setState(() {
      _score++;
      // Increase speed slightly
      _velX *= 1.1;
      _velY *= 1.1;
      // Change direction
      _velX = (Random().nextBool() ? 1 : -1) * _velX.abs();
      _velY = (Random().nextBool() ? 1 : -1) * _velY.abs();

      // Cap max speed
      if (_velX.abs() > 10) _velX = (_velX > 0 ? 10 : -10);
      if (_velY.abs() > 10) _velY = (_velY > 0 ? 10 : -10);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "To'pchani ustiga bosing va achko yeg'ing! Hisob: ${_score}",
          style: const TextStyle(
              color: Colors.greenAccent, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          width: _gameWidth,
          height: _gameHeight,
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.accent.withOpacity(0.3)),
          ),
          child: Stack(
            children: [
              Positioned(
                left: _ballX,
                top: _ballY,
                child: GestureDetector(
                  onTap: _onBallTap,
                  child: Container(
                    width: _ballSize,
                    height: _ballSize,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.white54, blurRadius: 10)
                      ],
                    ),
                    child: Center(
                      child: Icon(BoxIcons.bx_football,
                          size: 30, color: AppColors.background),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
