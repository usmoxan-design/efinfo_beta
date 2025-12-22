import 'package:efinfo_beta/additional/colors.dart';
import 'package:efinfo_beta/mainpage.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainPage()),
      );
    });
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            SizedBox(
              height: 60,
              child: Image.asset(
                'assets/images/mainLogo.png',
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              ' v1.0.8',
              style: TextStyle(fontSize: 20, color: mainColor),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
