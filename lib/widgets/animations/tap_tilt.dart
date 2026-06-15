import 'package:flutter/material.dart';

/// Enveloppe une Card/ListTile pour un retour visuel 3D subtil :
/// - tap (mobile/tactile) : scale ~0.97 + tilt vers le point touché ;
/// - hover souris (web/desktop) : tilt continu qui suit le curseur + léger
///   effet de "lift" (scale > 1), avec un temps de retard (`TweenAnimationBuilder`)
///   pour un mouvement fluide plutôt qu'instantané.
/// L'intensité du tilt s'adapte à la largeur d'écran (plus discret sur mobile,
/// plus marqué sur tablette/desktop). Utilise [Listener]/[MouseRegion] (pas
/// GestureDetector) pour ne RIEN intercepter : l'InkWell/onTap de l'enfant
/// continue de fonctionner normalement.
class TapTilt extends StatefulWidget {
  final Widget child;
  final double pressedScale;
  final double maxTilt;
  final double hoverScale;

  const TapTilt({
    super.key,
    required this.child,
    this.pressedScale = 0.97,
    this.maxTilt = 0.015,
    this.hoverScale = 1.015,
  });

  @override
  State<TapTilt> createState() => _TapTiltState();
}

class _TapTiltState extends State<TapTilt> with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  Offset? _pressPosition;
  Offset _hoverPosition = const Offset(0.5, 0.5);

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 180),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  // Tilt plus discret sur mobile (écran étroit), plus marqué sur tablette/desktop
  // où le hover souris met l'effet en valeur.
  double _responsiveTilt(double screenWidth) {
    if (screenWidth < 600) return widget.maxTilt * 0.7;
    if (screenWidth < 1024) return widget.maxTilt;
    return widget.maxTilt * 1.35;
  }

  @override
  Widget build(BuildContext context) {
    final maxTilt = _responsiveTilt(MediaQuery.sizeOf(context).width);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final hasValidSize = size.width.isFinite && size.height.isFinite && size.width > 0 && size.height > 0;

        void updateHover(Offset localPosition) {
          if (!hasValidSize) return;
          setState(() {
            _hoverPosition = Offset(
              (localPosition.dx / size.width).clamp(0.0, 1.0),
              (localPosition.dy / size.height).clamp(0.0, 1.0),
            );
          });
        }

        return MouseRegion(
          onHover: (event) => updateHover(event.localPosition),
          onExit: (_) => setState(() => _hoverPosition = const Offset(0.5, 0.5)),
          child: Listener(
            onPointerDown: (event) {
              _pressPosition = event.localPosition;
              _pressController.forward();
            },
            onPointerUp: (_) => _pressController.reverse(),
            onPointerCancel: (_) => _pressController.reverse(),
            child: TweenAnimationBuilder<Offset>(
              tween: Tween<Offset>(begin: const Offset(0.5, 0.5), end: _hoverPosition),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              builder: (context, hoverPos, child) {
                return AnimatedBuilder(
                  animation: _pressController,
                  builder: (context, child) {
                    final t = Curves.easeOut.transform(_pressController.value);

                    final hx = hoverPos.dx - 0.5;
                    final hy = hoverPos.dy - 0.5;
                    double rotX = -hy * maxTilt * 2;
                    double rotY = hx * maxTilt * 2;
                    double scale = (hx == 0 && hy == 0) ? 1.0 : widget.hoverScale;

                    if (_pressPosition != null && hasValidSize && t > 0) {
                      final dx = (_pressPosition!.dx / size.width) - 0.5;
                      final dy = (_pressPosition!.dy / size.height) - 0.5;
                      final pressScale = 1.0 - (1.0 - widget.pressedScale) * t;
                      rotY = rotY * (1 - t) + (dx * maxTilt * 2) * t;
                      rotX = rotX * (1 - t) + (-dy * maxTilt * 2) * t;
                      scale = scale * (1 - t) + pressScale * t;
                    }

                    final matrix = Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateX(rotX)
                      ..rotateY(rotY)
                      ..scaleByDouble(scale, scale, scale, 1.0);

                    return Transform(alignment: Alignment.center, transform: matrix, child: child);
                  },
                  child: child,
                );
              },
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
