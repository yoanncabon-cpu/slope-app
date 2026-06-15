import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Anime l'entrée d'un item de liste : fade + léger slide vers le haut,
/// décalé selon [index] pour un effet de stagger sobre. L'index est
/// plafonné pour que les listes longues ne traînent pas.
class StaggerFadeSlide extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration stagger;
  final Duration duration;

  const StaggerFadeSlide({
    super.key,
    required this.index,
    required this.child,
    this.stagger = const Duration(milliseconds: 40),
    this.duration = const Duration(milliseconds: 320),
  });

  @override
  Widget build(BuildContext context) {
    final delay = stagger * index.clamp(0, 12);
    return child
        .animate(delay: delay)
        .fadeIn(duration: duration, curve: Curves.easeOut)
        .slide(begin: const Offset(0, 0.08), end: Offset.zero, curve: Curves.easeOutCubic);
  }
}
