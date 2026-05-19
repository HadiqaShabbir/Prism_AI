// ============================================================
// models/provider_model.dart
// PRISM AI — Provider Data Model
// Added: city, serviceCategory, distanceKm, cancellationRate,
//        reliabilityScore — all used by the AI ranking engine.
// ============================================================

import 'package:flutter/material.dart';

class ProviderModel {
  // ── Identity ──────────────────────────────────────────────
  final String name;
  final String city; // e.g. "Karachi", "Islamabad", "Lahore"
  final String serviceCategory; // e.g. "AC Repair", "Electrician"

  // ── Display / UX ─────────────────────────────────────────
  final double rating;
  final int reviews;
  final String distance; // Human-readable "2.1 km"
  final double distanceKm; // Raw float for scoring
  final int onTime; // On-time % (0–100)
  final int price; // Price in PKR
  final String available; // Earliest available slot
  final String badge;
  final Color badgeColor;
  final List<String> reasons; // Dynamic recommendation reasons

  // ── Scoring inputs ────────────────────────────────────────
  final int cancellationRate; // % cancellations (lower = better)
  final int reliabilityScore; // Composite reliability (0–100)

  const ProviderModel({
    required this.name,
    required this.city,
    required this.serviceCategory,
    required this.rating,
    required this.reviews,
    required this.distance,
    required this.distanceKm,
    required this.onTime,
    required this.price,
    required this.available,
    required this.cancellationRate,
    required this.reliabilityScore,
    required this.badge,
    required this.badgeColor,
    required this.reasons,
  });

  /// Convert to Map so screens can pass it via Navigator without
  /// forcing every screen to import ProviderModel directly.
  Map<String, dynamic> toMap() => {
    'name': name,
    'city': city,
    'serviceCategory': serviceCategory,
    'rating': rating,
    'reviews': reviews,
    'distance': distance,
    'distanceKm': distanceKm,
    'onTime': onTime,
    'price': price,
    'available': available,
    'cancellationRate': cancellationRate,
    'reliabilityScore': reliabilityScore,
    'badge': badge,
    'badgeColor': badgeColor,
    'reasons': reasons,
  };
}
