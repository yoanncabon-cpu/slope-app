import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/images/logo_slope.svg',
              width: 88,
              height: 88,
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1, 1),
                  curve: Curves.easeOutBack,
                  duration: 500.ms,
                ),
            const SizedBox(height: 24),
            Text(
              'Slope',
              style: Theme.of(context).textTheme.headlineMedium,
            )
                .animate(delay: 150.ms)
                .fadeIn(duration: 350.ms)
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 8),
            Text(
              'Investissement & Entrepreneuriat',
              style: Theme.of(context).textTheme.bodyMedium,
            )
                .animate(delay: 220.ms)
                .fadeIn(duration: 350.ms)
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 32),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            ).animate(delay: 300.ms).fadeIn(duration: 300.ms),
          ],
        ),
      ),
    );
  }
}
