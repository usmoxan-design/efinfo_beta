import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/pes_models.dart';
import '../services/pes_service.dart';

class PesPlayerCardWidget extends StatefulWidget {
  final PesPlayer player;
  final PesPlayerDetail? detail;
  final VoidCallback? onFlip;
  final bool? isFlipped;
  final bool isMaxLevel;

  const PesPlayerCardWidget({
    super.key,
    required this.player,
    this.detail,
    this.onFlip,
    this.isFlipped,
    this.isMaxLevel = false,
  });

  @override
  State<PesPlayerCardWidget> createState() => _PesPlayerCardWidgetState();
}

class _PesPlayerCardWidgetState extends State<PesPlayerCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _internalShowFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(PesPlayerCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped != null && widget.isFlipped != oldWidget.isFlipped) {
      if (widget.isFlipped!) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (widget.onFlip != null) {
      widget.onFlip!();
    } else {
      if (_internalShowFront) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      setState(() {
        _internalShowFront = !_internalShowFront;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.detail != null ? _flipCard : null,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * pi;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: angle >= pi / 2
                ? Transform(
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: _buildBackCard(),
                  )
                : _buildFrontCard(),
          );
        },
      ),
    );
  }

  Widget _buildFrontCard() {
    final rawUrl =
        widget.isMaxLevel ? widget.player.imageMaxUrl : widget.player.imageUrl;
    final imageUrl = kIsWeb
        ? 'https://corsproxy.io/?${Uri.encodeComponent(rawUrl)}'
        : rawUrl;

    return Container(
      width: 220,
      height: 320,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.contain,
          httpHeaders: PesService.headers,
          progressIndicatorBuilder: (context, url, downloadProgress) {
            return Center(
              child: CircularProgressIndicator(
                value: downloadProgress.progress,
                color: Colors.white,
              ),
            );
          },
          errorWidget: (context, url, error) {
            return Container(
              color: Colors.grey[900],
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, color: Colors.white54, size: 40),
                    SizedBox(height: 8),
                    Text(
                      "Image Not Found",
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBackCard() {
    final detail = widget.detail;
    if (detail == null) {
      return Container(
        width: 220,
        height: 320,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white24, width: 2),
        ),
        child: const Center(
          child: Text('No Details', style: TextStyle(color: Colors.white54)),
        ),
      );
    }

    final rawUrl = widget.isMaxLevel
        ? widget.player.imageMaxFlipUrl
        : widget.player.imageFlipUrl;
    final imageUrl = kIsWeb
        ? 'https://corsproxy.io/?${Uri.encodeComponent(rawUrl)}'
        : rawUrl;

    return Container(
      width: 220,
      height: 320,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.contain,
          httpHeaders: PesService.headers,
          progressIndicatorBuilder: (context, url, downloadProgress) {
            return Center(
              child: CircularProgressIndicator(
                value: downloadProgress.progress,
                color: Colors.white,
              ),
            );
          },
          errorWidget: (context, url, error) {
            return Container(
              color: Colors.grey[900],
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, color: Colors.white54, size: 40),
                    SizedBox(height: 8),
                    Text(
                      "Image Not Found",
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
