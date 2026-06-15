import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Bannière illustrée (SVG isométrique) affichée en haut d'un écran,
/// avec une apparition en fondu + léger glissement vers le haut.
class IllustrationBanner extends StatelessWidget {
  final String asset;
  final double height;
  final double horizontalPadding;

  const IllustrationBanner({
    super.key,
    required this.asset,
    this.height = 140,
    this.horizontalPadding = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 4),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: SvgPicture.asset(asset, fit: BoxFit.contain),
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 400), curve: Curves.easeOut)
        .slide(begin: const Offset(0, 0.08), end: Offset.zero, curve: Curves.easeOutCubic);
  }
}
