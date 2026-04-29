import 'package:flutter/material.dart';

/// Paleta de colores de la app — inspirada en Martos
class AppColors {
  // Colores principales
  static const Color primary = Color(0xFF2C5F7C);       // Azul petróleo
  static const Color primaryLight = Color(0xFF4A8BAD);   // Azul más claro
  static const Color primaryDark = Color(0xFF1A3D52);    // Azul oscuro

  // Acento cálido
  static const Color accent = Color(0xFFC4704B);         // Terracota
  static const Color accentLight = Color(0xFFE8A383);    // Terracota suave

  // Fondos — Light
  static const Color background = Color(0xFFFAF7F2);    // Crema suave
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF0EDE6); // Gris cálido

  // Fondos — Dark
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceVariantDark = Color(0xFF2C2C2C);

  // Texto — Light
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textLight = Color(0xFF9E9E9E);

  // Texto — Dark
  static const Color textPrimaryDark = Color(0xFFE8E8E8);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textLightDark = Color(0xFF787878);

  // Estados de incidencia (alineados con los pines reales de Google Maps)
  static const Color statusPending = Color(0xFFEA9133);    // Naranja
  static const Color statusInProgress = Color(0xFF3535EA); // Azul
  static const Color statusResolved = Color(0xFF32EA33);   // Verde
  static const Color statusRejected = Color(0xFFE53935);   // Rojo

  // Prioridades
  static const Color priorityLow = Color(0xFF4CAF50);
  static const Color priorityMedium = Color(0xFFFFA726);
  static const Color priorityHigh = Color(0xFFFF7043);
  static const Color priorityCritical = Color(0xFFE53935);
}
