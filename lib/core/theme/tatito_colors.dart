import 'package:flutter/material.dart';

/// Tatito Foods Color Palette
/// Derived directly from the Laravel website brand tokens (Design.md)
class TatitoColors {
  // Brand Colors
  static const Color brandGreen = Color(0xFF1B7F2A); // Primary CTA buttons, links, active states
  static const Color brandGreenDark = Color(0xFF0B4F1A); // Headers, app bar, deep accents
  static const Color brandGreenLight = Color(0xFFE8F5E9); // Category card backgrounds, active chips
  static const Color brandGold = Color(0xFFC9A227); // Badges, promo cards, rating stars, discounts
  static const Color brandBlack = Color(0xFF111111); // Typography headings

  // Neutral & Surfaces
  static const Color surface = Color(0xFFFFFFFF); // Background of cards, sheets
  static const Color surfaceAlt = Color(0xFFF8FAF7); // Page scaffold background
  static const Color textBody = Color(0xFF374151); // Secondary text
  static const Color textMuted = Color(0xFF9CA3AF); // Subtitles, MRP strikethrough
  static const Color borderSubtle = Color(0xFFE5E7EB); // Dividers, outline borders
  static const Color divider = Color(0xFFF3F4F6);

  // Semantic & Indian Dietary Indicators
  static const Color vegGreen = Color(0xFF2E9E3E); // Standard Indian veg square & dot
  static const Color nonVegRed = Color(0xFFC62828); // Standard Indian non-veg square & dot
  static const Color warningOrange = Color(0xFFF59E0B); // Low stock, alerts, mixed cart notice
  static const Color dangerRed = Color(0xFFD32F2F); // Errors, payment failed, cancel order
}
