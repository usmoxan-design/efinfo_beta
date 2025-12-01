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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            SizedBox(
              height: 40,
              child: Image.asset(
                'assets/images/efootball-logo.png',
                color: const Color(0xFF117340),
              ),
            ),
            const Text(
              ' Info beta',
              style: TextStyle(
                fontSize: 20,
                color: Color(0xFF117340),
              ),
            ),
            const Spacer(),
            const Text(
              ' v1.0.2',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
