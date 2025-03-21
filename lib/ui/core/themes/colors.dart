// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

abstract final class AppColors {
  // Base colors
  static const black = Color(0xFF101010);
  static const white = Color(0xFFFFF7FA);
  static const grey100 = Color(0xFFF2F2F2);
  static const grey300 = Color(0xFFE0E0E0);
  static const grey500 = Color(0xFFA4A4A4);
  static const grey800 = Color(0xFF4D4D4D);

  // Accent colors
  static const orange = Color(0xFFF8A156); // TollGate "Paste" button color
  static const green = Color(0xFF2ECC71);
  static const blue = Color(0xFF3498DB);
  static const purple = Color(0xFF9B59B6);
  static const red = Color(0xFFE74C3C);

  // Theme backgrounds
  static const darkBackground = Color(0xFF1E2131); // TollGate dark background
  static const darkCardBackground =
      Color(0xFF2A2D40); // Dark background for cards in dark mode
  static const disabledButtonBackground =
      Color(0xFFD5D5D5); // Disabled button background
  static const darkSurface =
      Color(0xFF232639); // Slightly lighter than background

  // Transparent colors
  static const whiteTransparent = Color(0x4DFFFFFF);
  static const blackTransparent = Color(0x4D000000);

  // Light theme
  static final lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: darkBackground,
    onPrimary: white,
    secondary: orange,
    onSecondary: black,
    tertiary: purple,
    onTertiary: white,
    error: red,
    onError: white,
    surface: white,
    onSurface: black,
    surfaceContainerHighest: grey100,
    onSurfaceVariant: grey800,
    outline: grey500,
    outlineVariant: grey100,
    shadow: blackTransparent,
    scrim: blackTransparent,
    inverseSurface: darkBackground,
    onInverseSurface: white,
    inversePrimary: white,
    surfaceContainerLow: grey300,
  );

  // Dark theme
  static final darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: white,
    onPrimary: darkBackground,
    secondary: orange,
    onSecondary: white,
    tertiary: purple.withAlpha(204),
    onTertiary: white,
    error: red,
    onError: white,
    surface: darkSurface,
    onSurface: white,
    surfaceContainerHighest: darkCardBackground,
    onSurfaceVariant: grey100,
    outline: grey500,
    outlineVariant: grey800,
    shadow: blackTransparent,
    scrim: blackTransparent,
    inverseSurface: white,
    onInverseSurface: darkBackground,
    inversePrimary: black,
    surfaceContainerLow:
        Color(0xFF3A3F51), // Slightly lighter than surface for containers
  );
}
