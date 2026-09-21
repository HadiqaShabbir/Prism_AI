// ============================================================
// lib/screens/provider_screen.dart
// PRISM AI — Provider Discovery Screen
//
// Features:
//  • Emergency Fast-Match mode
//  • Confidence warning for unclear requests
//  • Retry suggestions when no exact match is available
//  • Nearby provider fallback
//  • Provider ranking based on multiple factors
//  • Match score and recommendation badges
//  • Provider details and booking
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'booking_screen.dart';
import '../services/ai_engine.dart';

class ProviderScreen extends StatefulWidget {
  final Map<String, dynamic> extracted;
  final ParsedRequest parsedRequest;
  final String userName;
  final String userCity;

  const ProviderScreen({
    super.key,
    required this.extracted,
    required this.parsedRequest,
    required this.userName,
    required this.userCity,
  });

  @override
  State<ProviderScreen> createState() => _ProviderScreenState();
}

class _ProviderScreenState extends State<ProviderScreen>
    with TickerProviderStateMixin {
  // ── Palette ──────────────────────────────────────────────
  static const kNavy = Color(0xFF0A1628);
  static const kBlue = Color(0xFF185FA5);
  static const kCyan = Color(0xFF00C2D4);
  static const kPurple = Color(0xFF6C4FD6);
  static const kCard = Color(0xFFF5F9FF);
  static const kBorder = Color(0xFFD8E6F5);
  static const kText = Color(0xFF1A1A2E);
  static const kMuted = Color(0xFF6B7A8D);
  static const kGreen = Color(0xFF4CAF50);
  static const kOrange = Color(0xFFFF7043);
  static const kAmber = Color(0xFFFFB347);
  static const kRed = Color(0xFFE53935);

  // ── State ─────────────────────────────────────────────────
  bool _loading = true;
  int _loadingStep = 0; // 0-3 animated steps
  MatchResult? _matchResult;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  // Loading step labels
  static const _steps = [
    'Finding available providers',
    'Checking service and location',
    'Comparing provider details',
    'Checking availability and reliability',
  ];

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _runAiMatching();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── AI Orchestration ──────────────────────────────────────
  Future<void> _runAiMatching() async {
    // Animate loading steps
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 420));
      if (mounted) setState(() => _loadingStep = i + 1);
    }
    await Future.delayed(const Duration(milliseconds: 300));

    final result = AiEngine.match(widget.parsedRequest);

    if (mounted) {
      setState(() {
        _matchResult = result;
        _loading = false;
      });
      _fadeCtrl.forward();
    }
  }

  void _bookProvider(RankedProvider rp) {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingScreen(
          provider: rp.provider.toMap(),
          extracted: widget.extracted,
          userName: widget.userName,
          userCity: widget.userCity,
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: _buildAppBar(),
      body: _loading ? _buildLoadingState() : _buildContent(),
    );
  }

  // ── App Bar ───────────────────────────────────────────────
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: kText),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          SizedBox(
            width: 24,
            height: 28,
            child: CustomPaint(painter: PrismLogoPainter()),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Provider Match',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: kText,
                ),
              ),
              Text(
                widget.parsedRequest.service,
                style: const TextStyle(fontSize: 10, color: kMuted),
              ),
            ],
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: kBorder),
      ),
    );
  }

  // ── Loading State ─────────────────────────────────────────
  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildRequestSummary(),
          const SizedBox(height: 20),

          // Emergency banner during load
          if (widget.parsedRequest.urgency == 'High') _buildEmergencyBanner(),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kBorder),
              boxShadow: [
                BoxShadow(
                  color: kBlue.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Animated pulse ring
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, _) => Transform.scale(
                    scale: _pulseAnim.value,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(colors: [kCyan, kBlue]),
                      ),
                      child: const Icon(
                        Icons.psychology_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  widget.parsedRequest.urgency == 'High'
                      ? 'Emergency Fast-Match Activated'
                      : 'Finding the best providers…',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: kText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Checking providers based on your request',
                  style: const TextStyle(fontSize: 12, color: kMuted),
                ),
                const SizedBox(height: 20),
                ..._steps.asMap().entries.map(
                  (e) => _buildLoadingStep(e.key, e.value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingStep(int index, String label) {
    final isDone = _loadingStep > index;
    final isActive = _loadingStep == index;

    Color iconColor;
    IconData icon;
    if (isDone) {
      iconColor = kGreen;
      icon = Icons.check_circle_rounded;
    } else if (isActive) {
      iconColor = kCyan;
      icon = Icons.radio_button_checked_rounded;
    } else {
      iconColor = kBorder;
      icon = Icons.radio_button_unchecked_rounded;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, child) => Opacity(
              opacity: isActive ? _pulseAnim.value : 1.0,
              child: child,
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              color: isDone
                  ? kText
                  : isActive
                  ? kBlue
                  : kMuted,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          if (isActive) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(strokeWidth: 1.5, color: kCyan),
            ),
          ],
        ],
      ),
    );
  }

  // ── Main Content ──────────────────────────────────────────
  Widget _buildContent() {
    final result = _matchResult!;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRequestSummary(),
            const SizedBox(height: 12),

            // ── Emergency Banner ───────────────────────────
            if (widget.parsedRequest.urgency == 'High') _buildEmergencyBanner(),

            // ── Confidence Warning ─────────────────────────
            if (widget.parsedRequest.confidenceScore < 70)
              _buildConfidenceWarningCard(),

            // ── No Match / Empty State ─────────────────────
            if (!result.hasProviders && !result.hasFallback)
              _buildEmptyState(result)
            else ...[
              // ── Ranking Factor Chips ───────────────────────
              _buildRankingFactors(),
              const SizedBox(height: 16),

              // ── Provider List or Fallback ──────────────────
              if (result.hasProviders) ...[
                _buildSectionHeader(
                  Icons.leaderboard_rounded,
                  'Recommended Providers',
                  '${result.providers.length} found',
                ),
                const SizedBox(height: 10),
                ..._buildRankedCards(result.providers),
              ],

              if (result.hasFallback && result.fallbacks.isNotEmpty)
                _buildFallbackSection(result),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }

  // ── Request Summary ───────────────────────────────────────
  Widget _buildRequestSummary() {
    final score = widget.parsedRequest.confidenceScore;
    final scoreColor = score >= 85
        ? kGreen
        : score >= 70
        ? kAmber
        : kOrange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: kNavy,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.hub_rounded, color: kCyan, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.parsedRequest.service} in ${widget.parsedRequest.city}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${widget.parsedRequest.preferredTime} · ${widget.parsedRequest.urgency} urgency',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$score% match',
                  style: TextStyle(
                    color: scoreColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.parsedRequest.confidenceLevel.name.toUpperCase(),
                style: TextStyle(
                  color: scoreColor.withOpacity(0.8),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Emergency Banner ──────────────────────────────────────
  Widget _buildEmergencyBanner() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB71C1C), Color(0xFFE53935)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, child) =>
                Opacity(opacity: _pulseAnim.value, child: child!),
            child: const Icon(
              Icons.emergency_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Emergency Fast-Match Activated',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Prioritising nearest providers & fastest response times',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'URGENT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Confidence Warning Card ───────────────────────────────
  Widget _buildConfidenceWarningCard() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFCC02)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFFF8F00),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Low Confidence Match',
                style: TextStyle(
                  color: Color(0xFF7B4F00),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                '${widget.parsedRequest.confidenceScore}%',
                style: const TextStyle(
                  color: Color(0xFFFF8F00),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.parsedRequest.confidenceWarning ??
                'Your request is not very clear. Results may be less accurate.',
            style: const TextStyle(
              color: Color(0xFF7B4F00),
              fontSize: 12,
              height: 1.5,
            ),
          ),
          if (widget.parsedRequest.retrySuggestions.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text(
              'Try these instead:',
              style: TextStyle(
                color: Color(0xFF7B4F00),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: widget.parsedRequest.retrySuggestions
                  .map(
                    (s) => GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF8F00).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFFF8F00).withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          s,
                          style: const TextStyle(
                            color: Color(0xFF7B4F00),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────
  Widget _buildEmptyState(MatchResult result) {
    final suggestions = result.retrySuggestions.isNotEmpty
        ? result.retrySuggestions
        : [
            'Try a different city',
            'Try a different time',
            'Broaden your service',
          ];

    return Column(
      children: [
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: kBorder),
            boxShadow: [
              BoxShadow(
                color: kBlue.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: kBorder,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  color: kMuted,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No Providers Found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: kText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                result.failureMessage ??
                    'No ${widget.parsedRequest.service} providers are currently available in ${widget.parsedRequest.city}.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: kMuted,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),

              // Retry suggestion chips
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Suggested Actions',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: kText,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ..._buildRetrySuggestionChips(suggestions),

              const SizedBox(height: 20),

              // Quick action buttons
              _buildEmptyStateActionRow(),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildRetrySuggestionChips(List<String> suggestions) {
    final fixedChips = [
      _RetrySuggestion(
        label: 'Try broader location',
        icon: Icons.location_city_rounded,
        color: kBlue,
      ),
      _RetrySuggestion(
        label: 'Try different time',
        icon: Icons.schedule_rounded,
        color: kPurple,
      ),
      _RetrySuggestion(
        label: 'Use emergency mode',
        icon: Icons.emergency_rounded,
        color: kRed,
      ),
    ];

    final items = [
      ...fixedChips,
      ...suggestions
          .take(2)
          .map(
            (s) => _RetrySuggestion(
              label: s,
              icon: Icons.refresh_rounded,
              color: kCyan,
            ),
          ),
    ];

    return items
        .map(
          (chip) => GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: chip.color.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: chip.color.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(chip.icon, color: chip.color, size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      chip.label,
                      style: TextStyle(
                        color: chip.color,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: chip.color.withOpacity(0.5),
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        )
        .toList();
  }

  Widget _buildEmptyStateActionRow() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.refresh_rounded, size: 18),
        label: const Text(
          'Try Again',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: kBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // ── Ranking Factor Chips ──────────────────────────────────
  Widget _buildRankingFactors() {
    final isEmergency = widget.parsedRequest.urgency == 'High';

    final factors = isEmergency
        ? [
            {'label': 'Distance', 'pct': '30%', 'color': kRed},
            {'label': 'On-time', 'pct': '20%', 'color': kOrange},
            {'label': 'Rating', 'pct': '20%', 'color': kBlue},
            {'label': 'Reliability', 'pct': '15%', 'color': kPurple},
            {'label': 'Price', 'pct': '5%', 'color': kGreen},
            {'label': 'Cancel Rate', 'pct': '10%', 'color': kAmber},
          ]
        : [
            {'label': 'Rating', 'pct': '25%', 'color': kBlue},
            {'label': 'Reliability', 'pct': '20%', 'color': kPurple},
            {'label': 'Distance', 'pct': '20%', 'color': kCyan},
            {'label': 'On-time', 'pct': '15%', 'color': kOrange},
            {'label': 'Price', 'pct': '10%', 'color': kGreen},
            {'label': 'Cancel Rate', 'pct': '10%', 'color': kAmber},
          ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, color: kPurple, size: 15),
              const SizedBox(width: 6),
              Text(
                isEmergency
                    ? 'Emergency Matching Priorities'
                    : 'Provider Matching Factors',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: kText,
                ),
              ),
              if (isEmergency) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: kRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '⚡ Modified for urgency',
                    style: TextStyle(
                      color: kRed,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: factors
                .map(
                  (f) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: (f['color'] as Color).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: (f['color'] as Color).withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      '${f['label']} ${f['pct']}',
                      style: TextStyle(
                        fontSize: 11,
                        color: f['color'] as Color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // ── Section Header ────────────────────────────────────────
  Widget _buildSectionHeader(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, color: kBlue, size: 18),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: kText,
          ),
        ),
        const Spacer(),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: kMuted)),
      ],
    );
  }

  // ── Provider Cards ────────────────────────────────────────
  List<Widget> _buildRankedCards(List<RankedProvider> providers) {
    // Determine AI recommendation labels
    final nearest = providers.reduce(
      (a, b) => a.provider.distanceKm < b.provider.distanceKm ? a : b,
    );
    final topRated = providers.reduce(
      (a, b) => a.provider.rating > b.provider.rating ? a : b,
    );
    final mostReliable = providers.reduce(
      (a, b) =>
          a.provider.reliabilityScore > b.provider.reliabilityScore ? a : b,
    );
    final budgetPick = providers.reduce(
      (a, b) => a.provider.price < b.provider.price ? a : b,
    );

    return providers.asMap().entries.map((e) {
      final rp = e.value;
      final rank = e.key + 1;

      final labels = <_AiBadge>[];

      if (rank == 1) {
        labels.add(
          _AiBadge('Top Ranked', kBlue, Icons.workspace_premium_rounded),
        );
      }
      if (rp == nearest) {
        labels.add(_AiBadge('Fastest Arrival', kCyan, Icons.near_me_rounded));
      }
      if (rp == topRated) {
        labels.add(_AiBadge('Top Rated', kAmber, Icons.star_rounded));
      }
      if (rp == mostReliable) {
        labels.add(
          _AiBadge('Highest Reliability', kGreen, Icons.verified_rounded),
        );
      }
      if (rp == budgetPick) {
        labels.add(_AiBadge('Best Budget', kPurple, Icons.savings_rounded));
      }
      if (rp.isEmergencyPick) {
        labels.add(_AiBadge('⚡ Emergency Pick', kRed, Icons.emergency_rounded));
      }

      return _RankedProviderCard(
        rankedProvider: rp,
        rank: rank,
        onBook: () => _bookProvider(rp),
        aiBadges: labels,
        isEmergency: widget.parsedRequest.urgency == 'High',
      );
    }).toList();
  }

  // ── Fallback Section ──────────────────────────────────────
  Widget _buildFallbackSection(MatchResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kPurple.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kPurple.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.travel_explore_rounded,
                color: kPurple,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nearby City Fallback',
                      style: TextStyle(
                        color: kPurple,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'Showing providers from ${result.fallbackCity} — no exact match in ${widget.parsedRequest.city}',
                      style: const TextStyle(
                        color: kMuted,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildSectionHeader(
          Icons.location_city_rounded,
          'Nearby Alternatives',
          result.fallbackCity ?? '',
        ),
        const SizedBox(height: 10),
        ...result.fallbacks.asMap().entries.map(
          (e) => _RankedProviderCard(
            rankedProvider: e.value,
            rank: e.key + 1,
            onBook: () => _bookProvider(e.value),
            aiBadges: [
              _AiBadge('Fallback Pick', kPurple, Icons.travel_explore_rounded),
            ],
            isEmergency: false,
            isFallback: true,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// DATA CLASSES (helpers)
// ─────────────────────────────────────────────────────────────

class _AiBadge {
  final String label;
  final Color color;
  final IconData icon;
  const _AiBadge(this.label, this.color, this.icon);
}

class _RetrySuggestion {
  final String label;
  final IconData icon;
  final Color color;
  const _RetrySuggestion({
    required this.label,
    required this.icon,
    required this.color,
  });
}

// ─────────────────────────────────────────────────────────────
// RANKED PROVIDER CARD
// ─────────────────────────────────────────────────────────────

class _RankedProviderCard extends StatefulWidget {
  final RankedProvider rankedProvider;
  final int rank;
  final VoidCallback onBook;
  final List<_AiBadge> aiBadges;
  final bool isEmergency;
  final bool isFallback;

  const _RankedProviderCard({
    required this.rankedProvider,
    required this.rank,
    required this.onBook,
    this.aiBadges = const [],
    this.isEmergency = false,
    this.isFallback = false,
  });

  @override
  State<_RankedProviderCard> createState() => _RankedProviderCardState();
}

class _RankedProviderCardState extends State<_RankedProviderCard> {
  bool _expanded = false;

  static const kBlue = Color(0xFF185FA5);
  static const kText = Color(0xFF1A1A2E);
  static const kMuted = Color(0xFF6B7A8D);
  static const kCard = Color(0xFFF5F9FF);
  static const kBorder = Color(0xFFD8E6F5);
  static const kGreen = Color(0xFF4CAF50);
  static const kAmber = Color(0xFFFFB347);
  static const kRed = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    final p = widget.rankedProvider.provider;
    final score = widget.rankedProvider.matchScore;
    final reasons = widget.rankedProvider.reasons;
    final isTop = widget.rank == 1 && !widget.isFallback;

    final badgeColor = score >= 90
        ? kBlue
        : score >= 80
        ? const Color(0xFF00C2D4)
        : const Color(0xFF6C4FD6);

    // Emergency highlight — nearest provider
    final isEmergencyHighlight =
        widget.isEmergency && widget.rankedProvider.isEmergencyPick;

    Color borderColor = kBorder;
    if (isTop) borderColor = kBlue.withOpacity(0.4);
    if (isEmergencyHighlight) borderColor = kRed.withOpacity(0.4);
    if (widget.isFallback) {
      borderColor = const Color(0xFF6C4FD6).withOpacity(0.3);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: borderColor,
          width: (isTop || isEmergencyHighlight) ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isEmergencyHighlight ? kRed : kBlue).withOpacity(
              isTop ? 0.1 : 0.04,
            ),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top accent bar ──────────────────────────────
          if (isTop || isEmergencyHighlight)
            Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isEmergencyHighlight
                      ? [kRed, const Color(0xFFFF7043)]
                      : [kBlue, const Color(0xFF00C2D4)],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header row ────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rank badge
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isTop ? kBlue : kCard,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '#${widget.rank}',
                          style: TextStyle(
                            color: isTop ? Colors.white : kMuted,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: kText,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: kAmber,
                                size: 13,
                              ),
                              Text(
                                ' ${p.rating} (${p.reviews} reviews)',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: kMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Provider dynamic badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: p.badgeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: p.badgeColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            p.badge,
                            style: TextStyle(
                              color: p.badgeColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // AI match score
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$score% Match',
                            style: TextStyle(
                              color: badgeColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // ── AI Recommendation Badges ───────────────
                if (widget.aiBadges.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: widget.aiBadges
                        .map(
                          (b) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: b.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: b.color.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(b.icon, color: b.color, size: 11),
                                const SizedBox(width: 4),
                                Text(
                                  b.label,
                                  style: TextStyle(
                                    color: b.color,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],

                const SizedBox(height: 12),

                // ── Info chips ─────────────────────────────
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _chip(Icons.location_on_rounded, p.distance),
                    _chip(Icons.timer_rounded, 'On-time: ${p.onTime}%'),
                    _chip(Icons.access_time_rounded, p.available),
                    _chip(
                      Icons.verified_user_rounded,
                      'Reliability: ${p.reliabilityScore}%',
                    ),
                    if (p.cancellationRate <= 5)
                      _chip(
                        Icons.cancel_outlined,
                        'Cancel: ${p.cancellationRate}%',
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Price + expand ─────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estimated Price',
                          style: TextStyle(fontSize: 11, color: kMuted),
                        ),
                        Text(
                          'Rs ${_formatPrice(p.price)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: kBlue,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _expanded = !_expanded),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: kBlue.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _expanded
                                  ? Icons.expand_less_rounded
                                  : Icons.psychology_alt_rounded,
                              color: kBlue,
                              size: 16,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _expanded ? 'Less' : 'Why Picked?',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: kBlue,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Provider Recommendation Details ──────────────────
                if (_expanded) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: kCard,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: kBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Why this provider?',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: kText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...reasons.map(
                          (r) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 1),
                                  child: Icon(
                                    Icons.check_circle_rounded,
                                    color: kGreen,
                                    size: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    r,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: kText,
                                      height: 1.45,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Score breakdown bar
                        const SizedBox(height: 8),
                        _buildScoreBar(score),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // ── Book Button ────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: widget.onBook,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEmergencyHighlight
                          ? kRed
                          : isTop
                          ? kBlue
                          : Colors.white,
                      foregroundColor: (isTop || isEmergencyHighlight)
                          ? Colors.white
                          : kBlue,
                      elevation: 0,
                      side: (isTop || isEmergencyHighlight)
                          ? null
                          : const BorderSide(color: kBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isEmergencyHighlight
                              ? Icons.emergency_rounded
                              : isTop
                              ? Icons.flash_on_rounded
                              : Icons.check_circle_outline_rounded,
                          size: 16,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          isEmergencyHighlight
                              ? 'Emergency Book'
                              : isTop
                              ? 'Book This Provider'
                              : 'Select Provider',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBar(int score) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Overall Match Score',
              style: TextStyle(fontSize: 11, color: kMuted),
            ),
            Text(
              '$score%',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: kBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score / 100,
            backgroundColor: const Color(0xFFD8E6F5),
            valueColor: AlwaysStoppedAnimation<Color>(
              score >= 90
                  ? kBlue
                  : score >= 80
                  ? const Color(0xFF00C2D4)
                  : const Color(0xFF6C4FD6),
            ),
            minHeight: 7,
          ),
        ),
      ],
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: kMuted),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 10.5, color: kMuted)),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PRISM LOGO PAINTER (preserved from original)
// ─────────────────────────────────────────────────────────────

class PrismLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Triangle 1 — blue
    paint.color = const Color(0xFF185FA5);
    final path1 = Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width, size.height * 0.6)
      ..lineTo(size.width * 0.5, size.height * 0.4)
      ..close();
    canvas.drawPath(path1, paint);

    // Triangle 2 — cyan
    paint.color = const Color(0xFF00C2D4);
    final path2 = Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(0, size.height * 0.6)
      ..lineTo(size.width * 0.5, size.height * 0.4)
      ..close();
    canvas.drawPath(path2, paint);

    // Triangle 3 — purple bottom
    paint.color = const Color(0xFF6C4FD6);
    final path3 = Path()
      ..moveTo(0, size.height * 0.6)
      ..lineTo(size.width, size.height * 0.6)
      ..lineTo(size.width * 0.5, size.height)
      ..close();
    canvas.drawPath(path3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
