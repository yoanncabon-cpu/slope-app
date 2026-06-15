import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Fond global de l'application : dégradé doux + halos lumineux flous,
/// pour donner de la profondeur ("3D subtil") derrière tout le contenu.
/// Statique (aucune animation continue) pour rester performant sur mobile
/// bas de gamme. La taille des halos s'adapte à la taille d'écran.
class DepthBackground extends StatelessWidget {
  final Widget child;

  const DepthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.sizeOf(context);
    final haloSize = screenSize.shortestSide * 0.9;

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [AppColors.darkBackground, AppColors.darkBgGradientMid, AppColors.darkBackground]
                    : [AppColors.lightBackground, AppColors.lightBgGradientMid, AppColors.lightBackground],
              ),
            ),
          ),
        ),
        Positioned(
          top: -haloSize * 0.35,
          right: -haloSize * 0.35,
          child: _Halo(size: haloSize, color: AppColors.secondary, opacity: isDark ? 0.20 : 0.10),
        ),
        Positioned(
          bottom: -haloSize * 0.4,
          left: -haloSize * 0.3,
          child: _Halo(size: haloSize * 0.9, color: AppColors.primary, opacity: isDark ? 0.22 : 0.08),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _Halo extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _Halo({required this.size, required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color.withValues(alpha: opacity), color.withValues(alpha: 0)],
            ),
          ),
        ),
      ),
    );
  }
}
