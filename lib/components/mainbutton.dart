import 'package:flutter/material.dart';

class MainButton extends StatefulWidget {
  const MainButton(
      {super.key,
      required this.btnText,
      required this.onClickEvent,
      required this.icon});
  final String btnText;
  final VoidCallback onClickEvent;
  final IconData icon;

  @override
  _MainButtonState createState() => _MainButtonState();
}

class _MainButtonState extends State<MainButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
    // Perform your button click action here
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () {
        _animationController.reverse();
      },
      onTap: widget.onClickEvent,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: double.infinity,
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              decoration: ShapeDecoration(
                color: const Color(0xFF06DF5D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(60),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.btnText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF161616),
                      fontSize: 20,
                      fontFamily: 'CruyffSans',
                      fontWeight: FontWeight.w400,
                      height: 0,
                    ),
                  ),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Icon(widget.icon),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
