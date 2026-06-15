import 'package:flutter/material.dart';

/// Palette de couleurs sémantiques de l'application Slope.
class AppColors {
  AppColors._();

  // Couleurs de marque
  static const Color primary = Color(0xFF4338CA); // Indigo profond - apprentissage
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color secondary = Color(0xFF06B6D4); // Cyan électrique - tech/finance
  static const Color secondaryLight = Color(0xFF67E8F9);
  static const Color accent = Color(0xFFF59E0B); // Amber - idées business

  // États
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Neutres - thème clair
  static const Color lightBackground = Color(0xFFF7F8FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFF1F2F8);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF6B7280);

  // Neutres - thème sombre
  static const Color darkBackground = Color(0xFF0B0E14);
  static const Color darkSurface = Color(0xFF151A23);
  static const Color darkSurfaceAlt = Color(0xFF1E2530);
  static const Color darkBorder = Color(0xFF2A313D);
  static const Color darkTextPrimary = Color(0xFFF3F4F6);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);

  // Fond "profondeur" (dégradé + halos) derrière le contenu
  static const Color darkBgGradientMid = Color(0xFF1B1340);
  static const Color lightBgGradientMid = Color(0xFFEDEFFB);

  // Couleurs des catégories d'investissement
  static const Map<String, Color> categoryColors = {
    'actions': Color(0xFF4338CA),
    'etf': Color(0xFF3B82F6),
    'obligations': Color(0xFF06B6D4),
    'immobilier': Color(0xFFF59E0B),
    'crypto': Color(0xFFEC4899),
    'epargne': Color(0xFF10B981),
    'or': Color(0xFFEAB308),
    'fiscalite': Color(0xFF8B5CF6),
    'idee': Color(0xFF14B8A6),
    'plan': Color(0xFF6366F1),
    'juridique': Color(0xFF0EA5E9),
    'financement': Color(0xFFF97316),
    'marketing': Color(0xFFEC4899),
    'gestion': Color(0xFF22C55E),
  };

  static Color categoryColor(String key) =>
      categoryColors[key] ?? primary;
}
