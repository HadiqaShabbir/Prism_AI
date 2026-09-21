// ============================================================
// lib/services/ai_engine.dart
// PRISM AI — Core Intelligence Engine  v2
//
// Features:
//  • Edge case handling (empty input, unsupported city/service)
//  • Emergency fast-track algorithm (urgency = High)
//  • Confidence scoring with ConfidenceLevel enum
//  • Fallback provider recommendations (nearby city)
//  • AI retry suggestions when no match is found
//  • Richer agent observation log
//  • MatchResult orchestrator
//
// Drop-in compatible — no existing screen imports change.
// ============================================================

import '../models/provider_model.dart';
import 'mock_data.dart';

// ─────────────────────────────────────────────────────────────
// ENUMS
// ─────────────────────────────────────────────────────────────

enum ConfidenceLevel {
  high, // >= 85
  medium, // 70–84
  low, //  < 70
}

enum MatchFailureReason {
  none,
  emptyRequest,
  unsupportedCity,
  unsupportedService,
  noProvidersInCity,
  generalNoMatch,
}

// ─────────────────────────────────────────────────────────────
// DATA CLASSES
// ─────────────────────────────────────────────────────────────

class ParsedRequest {
  final String service;
  final String city;
  final String rawLocation;
  final String urgency;
  final String preferredTime;
  final String budget;
  final int confidenceScore;
  final ConfidenceLevel confidenceLevel;
  final List<String> agentLog;

  // Edge-case metadata
  final bool isEmptyRequest;
  final bool isCitySupported;
  final bool isServiceRecognised;
  final MatchFailureReason failureReason;
  final String? confidenceWarning;
  final List<String> retrySuggestions;

  const ParsedRequest({
    required this.service,
    required this.city,
    required this.rawLocation,
    required this.urgency,
    required this.preferredTime,
    required this.budget,
    required this.confidenceScore,
    required this.confidenceLevel,
    required this.agentLog,
    required this.isEmptyRequest,
    required this.isCitySupported,
    required this.isServiceRecognised,
    required this.failureReason,
    this.confidenceWarning,
    this.retrySuggestions = const [],
  });

  Map<String, dynamic> toExtractedMap() => {
    'service': service,
    'location': rawLocation.isNotEmpty ? rawLocation : city,
    'time': preferredTime,
    'urgency': urgency,
    'budget': _budgetLabel(),
    'confidence': confidenceScore,
    'city': city,
  };

  String _budgetLabel() {
    switch (budget) {
      case 'Low':
        return 'Low (Budget Sensitive)';
      case 'High':
        return 'High (Quality First)';
      default:
        return 'Medium Sensitivity';
    }
  }

  bool get hasWarning => confidenceLevel != ConfidenceLevel.high;
  bool get isValid => !isEmptyRequest && isCitySupported && isServiceRecognised;
}

// ─────────────────────────────────────────────────────────────

class RankedProvider {
  final ProviderModel provider;
  final int matchScore;
  final List<String> reasons;
  final bool isEmergencyPick;

  const RankedProvider({
    required this.provider,
    required this.matchScore,
    required this.reasons,
    this.isEmergencyPick = false,
  });
}

// ─────────────────────────────────────────────────────────────

class MatchResult {
  final List<RankedProvider> providers;
  final List<RankedProvider> fallbacks;
  final bool hasFallback;
  final String? fallbackCity;
  final MatchFailureReason failureReason;
  final String? failureMessage;
  final List<String> retrySuggestions;

  const MatchResult({
    required this.providers,
    this.fallbacks = const [],
    this.hasFallback = false,
    this.fallbackCity,
    required this.failureReason,
    this.failureMessage,
    this.retrySuggestions = const [],
  });

  bool get hasProviders => providers.isNotEmpty;
}

// ─────────────────────────────────────────────────────────────
// AI ENGINE
// ─────────────────────────────────────────────────────────────

class AiEngine {
  // ── 1. REQUEST PARSER ────────────────────────────────────
  static ParsedRequest parseRequest(String rawText, String userCity) {
    final log = <String>[];

    // Guard: empty input
    if (rawText.trim().isEmpty) {
      log.add('[Guard] Empty request detected — aborting parse');
      return _emptyRequestResult(userCity, log);
    }

    final lower = rawText.toLowerCase().trim();

    // Language detection
    final isUrdu = _containsAny(lower, [
      'mujhe',
      'chahiye',
      'kal',
      'aaj',
      'subah',
      'sham',
      'raat',
      'pani',
      'bijli',
      'gaari',
      'padhai',
      'safai',
      'jaldi',
      'sasta',
      'theek',
      'wala',
      'wali',
      'karo',
      'karwa',
      'chahta',
      'chahti',
    ]);
    log.add(
      '[Language Parser] Detected: ${isUrdu ? "Roman Urdu / mixed" : "English"}',
    );

    // Service
    final service = _extractService(lower);
    final isServiceRecognised = service != 'General Service';
    if (!isServiceRecognised) {
      log.add('[Intent Extractor] WARNING — service not recognised from input');
    } else {
      log.add('[Intent Extractor] Service identified: $service');
    }

    // Location / city
    final locationResult = _extractLocation(lower, userCity);
    final city = locationResult['city'] as String;
    final rawLocation = locationResult['raw'] as String;
    final isCitySupported = MockData.supportedCities.contains(city);
    if (!isCitySupported) {
      log.add(
        '[Entity Recogniser] WARNING — city "$city" not in supported list',
      );
    } else {
      log.add('[Entity Recogniser] Location: $rawLocation → City: $city');
    }

    // Time
    final timeResult = _extractTime(lower);
    log.add('[Time Parser] Preferred slot: ${timeResult["time"]}');

    // Urgency
    final urgency = _extractUrgency(lower, timeResult['time'] as String);
    log.add('[Urgency Classifier] Urgency level: $urgency');
    if (urgency == 'High') {
      log.add(
        '[Emergency Trigger] HIGH urgency — fast-track algorithm will activate',
      );
    }

    // Budget
    final budget = _extractBudget(lower);
    log.add('[Budget Analyser] Budget sensitivity: $budget');

    // Confidence
    final confidence = _computeConfidence(
      service,
      city,
      rawLocation,
      urgency,
      isServiceRecognised,
      isCitySupported,
    );
    final confidenceLevel = _classifyConfidence(confidence);
    log.add(
      '[Confidence Scorer] Score: $confidence% — Level: ${confidenceLevel.name.toUpperCase()}',
    );

    final warning = _buildConfidenceWarning(
      confidenceLevel,
      isServiceRecognised,
      isCitySupported,
      service,
      city,
    );
    final suggestions = _buildRetrySuggestions(
      isServiceRecognised,
      isCitySupported,
      service,
      city,
    );

    if (warning != null) log.add('[Warning Generator] $warning');
    log.add('[Parser] Complete — passing to Provider Discovery Agent...');

    return ParsedRequest(
      service: service,
      city: city,
      rawLocation: rawLocation,
      urgency: urgency,
      preferredTime: timeResult['time'] as String,
      budget: budget,
      confidenceScore: confidence,
      confidenceLevel: confidenceLevel,
      agentLog: log,
      isEmptyRequest: false,
      isCitySupported: isCitySupported,
      isServiceRecognised: isServiceRecognised,
      failureReason: _determineFailureReason(
        isServiceRecognised,
        isCitySupported,
      ),
      confidenceWarning: warning,
      retrySuggestions: suggestions,
    );
  }

  // ── 2. PROVIDER FILTER ────────────────────────────────────
  static List<ProviderModel> filterProviders(ParsedRequest req) {
    if (!req.isCitySupported || !req.isServiceRecognised) return [];
    return MockData.providers.where((p) {
      return p.city.toLowerCase() == req.city.toLowerCase() &&
          _serviceMatches(p.serviceCategory, req.service);
    }).toList();
  }

  // ── 3. RANKING ALGORITHM ──────────────────────────────────
  // Emergency mode: distance + onTime weights boosted
  static List<RankedProvider> rankProviders(
    List<ProviderModel> providers,
    ParsedRequest req,
  ) {
    if (providers.isEmpty) return [];

    final isEmergency = req.urgency == 'High';

    final prices = providers.map((p) => p.price).toList();
    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final maxPrice = prices.reduce((a, b) => a > b ? a : b);
    final priceRange = (maxPrice - minPrice).toDouble();

    final ranked = providers.map((p) {
      // Weight distribution changes under emergency
      final ratingW = isEmergency ? 20.0 : 25.0;
      final reliabilityW = isEmergency ? 15.0 : 20.0;
      final distanceW = isEmergency ? 30.0 : 20.0;
      final onTimeW = isEmergency ? 20.0 : 15.0;
      final priceW = isEmergency ? 5.0 : 10.0;
      const cancelW = 10.0;

      final ratingScore = (p.rating / 5.0) * ratingW;
      final reliabilityScore = (p.reliabilityScore / 100.0) * reliabilityW;
      final distScore =
          ((10.0 - p.distanceKm.clamp(0, 10.0)) / 10.0) * distanceW;
      final onTimeScore = (p.onTime / 100.0) * onTimeW;
      final cancelScore = ((100 - p.cancellationRate) / 100.0) * cancelW;

      double priceScore;
      if (priceRange == 0) {
        priceScore = priceW * 0.7;
      } else {
        final normalised = (p.price - minPrice) / priceRange;
        if (req.budget == 'Low') {
          priceScore = (1 - normalised) * priceW;
        } else if (req.budget == 'High') {
          priceScore = normalised * priceW;
        } else {
          priceScore = (1 - (normalised - 0.5).abs() * 2) * priceW;
        }
      }

      // Emergency proximity bonus (up to +5 pts)
      double emergencyBonus = 0;
      if (isEmergency) {
        if (p.distanceKm < 1.5) {
          emergencyBonus = 5;
        } else if (p.distanceKm < 2.5) {
          emergencyBonus = 3;
        } else if (p.distanceKm < 3.5) {
          emergencyBonus = 1;
        }
      }

      final total =
          (ratingScore +
                  reliabilityScore +
                  distScore +
                  onTimeScore +
                  priceScore +
                  cancelScore +
                  emergencyBonus)
              .clamp(0, 100)
              .round();

      return RankedProvider(
        provider: p,
        matchScore: total,
        reasons: _buildReasons(p, req, total),
        isEmergencyPick: isEmergency && p.distanceKm < 2.5,
      );
    }).toList();

    ranked.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    return ranked;
  }

  // ── 4. FULL MATCH ORCHESTRATOR ────────────────────────────
  static MatchResult match(ParsedRequest req) {
    if (req.isEmptyRequest) {
      return MatchResult(
        providers: [],
        failureReason: MatchFailureReason.emptyRequest,
        failureMessage:
            'Your request was empty. Please describe what service you need.',
        retrySuggestions: _defaultSuggestions(),
      );
    }
    if (!req.isCitySupported) {
      return MatchResult(
        providers: [],
        failureReason: MatchFailureReason.unsupportedCity,
        failureMessage:
            '"${req.city}" is not covered yet.\n'
            'Supported cities: ${MockData.supportedCities.join(", ")}.',
        retrySuggestions: [
          'Try: "AC repair in Karachi"',
          'Try: "Electrician in Lahore"',
          'Try: "Plumber in Islamabad"',
        ],
      );
    }
    if (!req.isServiceRecognised) {
      return MatchResult(
        providers: [],
        failureReason: MatchFailureReason.unsupportedService,
        failureMessage:
            'Could not identify the service type.\n'
            'Try: "AC repair", "electrician", "plumber", "tutor"…',
        retrySuggestions: req.retrySuggestions,
      );
    }

    final filtered = filterProviders(req);

    if (filtered.isEmpty) {
      final fallbackResult = _findFallbacks(req);
      return MatchResult(
        providers: [],
        fallbacks: fallbackResult.$1,
        hasFallback: fallbackResult.$1.isNotEmpty,
        fallbackCity: fallbackResult.$2,
        failureReason: MatchFailureReason.noProvidersInCity,
        failureMessage:
            'No ${req.service} providers found in ${req.city} right now.',
        retrySuggestions: [
          'Try a different service category',
          'Broaden your time preference',
          'Check back later — providers rotate availability',
        ],
      );
    }

    return MatchResult(
      providers: rankProviders(filtered, req),
      failureReason: MatchFailureReason.none,
    );
  }

  // ─────────────────────────────────────────────────────────
  // PRIVATE HELPERS
  // ─────────────────────────────────────────────────────────

  static List<String> _buildReasons(
    ProviderModel p,
    ParsedRequest req,
    int score,
  ) {
    final reasons = <String>[];

    if (p.distanceKm < 1.5) {
      reasons.add('Extremely close — only ${p.distance} away');
    } else if (p.distanceKm < 2.5) {
      reasons.add('Closest available provider (${p.distance})');
    } else if (p.distanceKm < 4.0) {
      reasons.add('Conveniently nearby (${p.distance})');
    } else {
      reasons.add('Wider coverage — ${p.distance} away');
    }

    if (p.rating >= 4.8) {
      reasons.add('Exceptional rating: ${p.rating}★ from ${p.reviews} reviews');
    } else if (p.rating >= 4.5) {
      reasons.add('Highly rated: ${p.rating}★ (${p.reviews} reviews)');
    } else {
      reasons.add(
        'Good standing: ${p.rating}★ — ${p.reviews} verified reviews',
      );
    }

    if (p.onTime >= 95) {
      reasons.add('Near-perfect on-time record (${p.onTime}%)');
    } else if (p.onTime >= 90) {
      reasons.add('Strong punctuality (${p.onTime}% on-time)');
    } else {
      reasons.add('Decent punctuality (${p.onTime}% on-time)');
    }

    if (req.budget == 'Low') {
      reasons.add('Within your budget at Rs ${p.price}');
    } else if (req.budget == 'High') {
      reasons.add('Premium-tier service at Rs ${p.price}');
    } else {
      reasons.add('Fair pricing: Rs ${p.price}');
    }

    if (req.urgency == 'High' && p.distanceKm < 2.5) {
      reasons.add('Best emergency response time for your area');
    }
    if (p.cancellationRate <= 4) {
      reasons.add('Very low cancellation risk (${p.cancellationRate}%)');
    }
    if (p.reasons.isNotEmpty) {
      final spec = p.reasons.first;
      if (!reasons.any(
        (r) => r.toLowerCase().contains(spec.split(' ').first.toLowerCase()),
      )) {
        reasons.add(spec);
      }
    }

    return reasons.take(4).toList();
  }

  static (List<RankedProvider>, String?) _findFallbacks(ParsedRequest req) {
    final otherCities = MockData.supportedCities
        .where((c) => c.toLowerCase() != req.city.toLowerCase())
        .toList();

    for (final fallbackCity in otherCities) {
      final filtered = MockData.providers.where((p) {
        return p.city.toLowerCase() == fallbackCity.toLowerCase() &&
            _serviceMatches(p.serviceCategory, req.service);
      }).toList();

      if (filtered.isNotEmpty) {
        final fallbackReq = ParsedRequest(
          service: req.service,
          city: fallbackCity,
          rawLocation: fallbackCity,
          urgency: req.urgency,
          preferredTime: req.preferredTime,
          budget: req.budget,
          confidenceScore: req.confidenceScore,
          confidenceLevel: req.confidenceLevel,
          agentLog: req.agentLog,
          isEmptyRequest: false,
          isCitySupported: true,
          isServiceRecognised: true,
          failureReason: MatchFailureReason.none,
        );
        final ranked = rankProviders(filtered, fallbackReq);
        return (ranked.take(2).toList(), fallbackCity);
      }
    }
    return ([], null);
  }

  static ParsedRequest _emptyRequestResult(String userCity, List<String> log) {
    return ParsedRequest(
      service: 'General Service',
      city: userCity,
      rawLocation: '',
      urgency: 'Low',
      preferredTime: 'Flexible',
      budget: 'Medium',
      confidenceScore: 0,
      confidenceLevel: ConfidenceLevel.low,
      agentLog: log,
      isEmptyRequest: true,
      isCitySupported: MockData.supportedCities.contains(userCity),
      isServiceRecognised: false,
      failureReason: MatchFailureReason.emptyRequest,
      confidenceWarning:
          'Your request was empty. Please describe what service you need.',
      retrySuggestions: _defaultSuggestions(),
    );
  }

  static ConfidenceLevel _classifyConfidence(int score) {
    if (score >= 85) return ConfidenceLevel.high;
    if (score >= 70) return ConfidenceLevel.medium;
    return ConfidenceLevel.low;
  }

  static String? _buildConfidenceWarning(
    ConfidenceLevel level,
    bool serviceOk,
    bool cityOk,
    String service,
    String city,
  ) {
    if (level == ConfidenceLevel.high) return null;
    final parts = <String>[];
    if (!serviceOk) parts.add('service type not clearly identified');
    if (!cityOk) parts.add('"$city" is not a supported city');
    if (parts.isNotEmpty) {
      return 'Low confidence — ${parts.join(" & ")}. Results may be inaccurate.';
    }
    if (level == ConfidenceLevel.medium) {
      return 'Moderate confidence — some details unclear. Please review the extracted fields.';
    }
    return 'Low confidence — could not fully understand request. Try rephrasing.';
  }

  static List<String> _buildRetrySuggestions(
    bool serviceOk,
    bool cityOk,
    String service,
    String city,
  ) {
    final s = <String>[];
    if (!serviceOk) {
      s.addAll([
        'Try: "I need an electrician in Karachi"',
        'Try: "AC repair kal subah chahiye"',
        'Try: "Plumber today urgent"',
        'Mention the service name clearly (AC, plumber, tutor, etc.)',
      ]);
    }
    if (!cityOk) {
      s.addAll([
        'Supported cities: ${MockData.supportedCities.join(", ")}',
        'Try: "AC repair in Lahore"',
        'Try: "Tutor in Islamabad"',
      ]);
    }
    if (s.isEmpty) s.addAll(_defaultSuggestions());
    return s.take(4).toList();
  }

  static List<String> _defaultSuggestions() => [
    'Try: "Mujhe kal subah AC service chahiye Karachi mein"',
    'Try: "Electrician needed today in Lahore"',
    'Try: "Urgent plumber in Islamabad"',
    'Mention: service + city + time for best results',
  ];

  static MatchFailureReason _determineFailureReason(
    bool serviceOk,
    bool cityOk,
  ) {
    if (!cityOk) return MatchFailureReason.unsupportedCity;
    if (!serviceOk) return MatchFailureReason.unsupportedService;
    return MatchFailureReason.none;
  }

  static String _extractService(String lower) {
    if (_containsAny(lower, [
      'ac',
      'air condition',
      'cooling',
      'air con',
      'hvac',
      'inverter ac',
      'thanda',
      'gas charging',
      'split ac',
    ])) {
      return 'AC Repair';
    }

    if (_containsAny(lower, [
      'electric',
      'bijli',
      'wiring',
      'switch',
      'board',
      'fuse',
      'light fix',
      'mcb',
      'ups',
      'current',
      'voltage',
      'socket',
    ])) {
      return 'Electrician';
    }

    if (_containsAny(lower, [
      'plumb',
      'pipe',
      'pani',
      'leak',
      'drain',
      'tap',
      'flush',
      'motor',
      'water pump',
      'nala',
      'paani',
    ])) {
      return 'Plumbing';
    }

    if (_containsAny(lower, [
      'beauti',
      'parlour',
      'makeup',
      'facial',
      'hair',
      'waxing',
      'salon',
      'mehndi',
      'bridal',
      'threading',
    ])) {
      return 'Beautician';
    }

    if (_containsAny(lower, [
      'tutor',
      'teacher',
      'padhai',
      'maths',
      'science',
      'english tutor',
      'class',
      'study',
      'homework',
      'o level',
      'a level',
      'matric',
      'fsc',
      'mdcat',
      'ecat',
    ])) {
      return 'Tutor';
    }

    if (_containsAny(lower, [
      'clean',
      'safai',
      'sweep',
      'mop',
      'dust',
      'deep clean',
      'janitor',
      'jharoo',
      'ghar safai',
    ])) {
      return 'Cleaning';
    }

    if (_containsAny(lower, [
      'mechanic',
      'car repair',
      'gaari',
      'bike repair',
      'vehicle',
      'engine',
      'tyre',
      'oil change',
      'puncture',
    ])) {
      return 'Mechanic';
    }

    if (_containsAny(lower, [
      'shift',
      'move house',
      'moving',
      'transport goods',
      'relocation',
      'truck hire',
      'samaan',
      'ghar shift',
    ])) {
      return 'Shifting';
    }

    return 'General Service';
  }

  static Map<String, String> _extractLocation(String lower, String userCity) {
    // Sort longer aliases first — "dha lahore" before "dha"
    final sortedEntries = MockData.cityAliases.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));

    for (final entry in sortedEntries) {
      if (lower.contains(entry.key)) {
        final raw = entry.key
            .split(' ')
            .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : w)
            .join(' ');
        return {'city': entry.value, 'raw': raw};
      }
    }
    return {'city': userCity, 'raw': userCity};
  }

  static Map<String, String> _extractTime(String lower) {
    String day = 'Flexible';
    String period = '';

    if (_containsAny(lower, [
      'aaj',
      'today',
      'abhi',
      'now',
      'right now',
      'isi waqt',
    ])) {
      day = 'Today';
    } else if (_containsAny(lower, [
      'kal',
      'tomorrow',
      'next day',
      'agle din',
    ])) {
      day = 'Tomorrow';
    } else if (_containsAny(lower, [
      'sunday',
      'saturday',
      'weekend',
      'sunday ko',
      'saturday ko',
    ])) {
      day = 'This Weekend';
    } else {
      for (final d in [
        'monday',
        'tuesday',
        'wednesday',
        'thursday',
        'friday',
      ]) {
        if (lower.contains(d)) {
          day = d[0].toUpperCase() + d.substring(1);
          break;
        }
      }
    }

    if (_containsAny(lower, ['subah', 'morning', 'savere'])) {
      period = 'Morning';
    } else if (_containsAny(lower, [
      'dopahar',
      'afternoon',
      'noon',
      'lunch time',
    ])) {
      period = 'Afternoon';
    } else if (_containsAny(lower, ['sham', 'evening', 'shaam'])) {
      period = 'Evening';
    } else if (_containsAny(lower, ['raat', 'night', 'late'])) {
      period = 'Night';
    }

    return {'time': period.isNotEmpty ? '$day $period'.trim() : day};
  }

  static String _extractUrgency(String lower, String time) {
    if (_containsAny(lower, [
      'urgent',
      'jaldi',
      'emergency',
      'abhi',
      'right now',
      'asap',
      'help',
      'sos',
      'immediately',
      'foran',
      'isi waqt',
    ])) {
      return 'High';
    }
    if (time.contains('Today') || time.contains('Night')) return 'High';
    if (time.contains('Tomorrow')) return 'Medium';
    return 'Low';
  }

  static String _extractBudget(String lower) {
    if (_containsAny(lower, [
      'budget',
      'kam paise',
      'cheap',
      'sasta',
      'affordable',
      'low cost',
      'thora',
      'kam kharch',
      'reasonable',
    ])) {
      return 'Low';
    }
    if (_containsAny(lower, [
      'best',
      'premium',
      'acha',
      'quality',
      'top',
      'expert',
      'professional',
      'trusted',
      'reliable wala',
    ])) {
      return 'High';
    }
    return 'Medium';
  }

  static int _computeConfidence(
    String service,
    String city,
    String rawLocation,
    String urgency,
    bool serviceOk,
    bool cityOk,
  ) {
    int base = 70;
    if (serviceOk) base += 12;
    if (cityOk) base += 8;
    if (rawLocation.isNotEmpty && rawLocation != city) base += 4;
    if (urgency == 'High') base += 2;
    return base.clamp(0, 99);
  }

  static bool _containsAny(String text, List<String> keywords) =>
      keywords.any((k) => text.contains(k));

  static bool _serviceMatches(
    String providerCategory,
    String requestedService,
  ) {
    final pc = providerCategory.toLowerCase();
    final rs = requestedService.toLowerCase();
    if (pc == rs) return true;
    if (rs.contains(pc) || pc.contains(rs)) return true;
    const aliases = {
      'tutor': ['home tutor', 'teacher', 'tutoring'],
      'beautician': ['beauty', 'parlour', 'salon'],
      'mechanic': ['car mechanic', 'auto mechanic', 'car repair'],
      'shifting': ['movers', 'relocation'],
    };
    for (final entry in aliases.entries) {
      if (pc.contains(entry.key) || entry.key.contains(pc)) {
        if (entry.value.any((a) => rs.contains(a) || a.contains(rs))) {
          return true;
        }
      }
    }
    return false;
  }
}
