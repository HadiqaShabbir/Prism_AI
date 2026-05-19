// ============================================================
// screens/dispute_screen.dart
// PRISM AI — Dispute & Edge Case Handler
// Simulates: late provider, wrong price, cancellation, poor service
// Shows: AI auto-resolution with fallback logic
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'splash_screen.dart';
import '../utils/colors.dart';

class DisputeScreen extends StatefulWidget {
  final Map<String, dynamic>? provider;
  final String bookingId;

  const DisputeScreen({
    super.key,
    this.provider,
    this.bookingId = '#PRZ-2026-001', required String service,
  });

  @override
  State<DisputeScreen> createState() => _DisputeScreenState();
}

class _DisputeScreenState extends State<DisputeScreen>
    with TickerProviderStateMixin {
  String? _selectedIssue;
  bool _isResolving = false;
  bool _isResolved = false;
  Map<String, dynamic>? _resolution;

  late AnimationController _pulseCtrl;
  late AnimationController _resolveCtrl;
  late Animation<double> _resolveFade;
  late Animation<Offset> _resolveSlide;

  final _descController = TextEditingController();

  final List<Map<String, dynamic>> _issueTypes = [
    {
      'id': 'provider_late',
      'label': 'Provider Late / No Show',
      'icon': Icons.access_time_filled_rounded,
      'color': Color(0xFFFF7043),
      'description': 'Provider did not arrive at scheduled time',
    },
    {
      'id': 'wrong_pricing',
      'label': 'Wrong / Higher Pricing',
      'icon': Icons.price_change_rounded,
      'color': Color(0xFFFFB347),
      'description': 'Charged more than the agreed price',
    },
    {
      'id': 'poor_service',
      'label': 'Poor Service Quality',
      'icon': Icons.thumb_down_rounded,
      'color': Color(0xFFE91E63),
      'description': 'Service did not meet expected quality',
    },
    {
      'id': 'provider_cancelled',
      'label': 'Provider Cancelled',
      'icon': Icons.cancel_rounded,
      'color': Color(0xFF9C27B0),
      'description': 'Provider cancelled after confirmation',
    },
    {
      'id': 'wrong_service',
      'label': 'Wrong Service Done',
      'icon': Icons.build_circle_rounded,
      'color': Color(0xFF185FA5),
      'description': 'Provider performed incorrect work',
    },
    {
      'id': 'safety_concern',
      'label': 'Safety Concern',
      'icon': Icons.shield_rounded,
      'color': Color(0xFFD32F2F),
      'description': 'Behaviour or safety issue reported',
    },
  ];

  // Mock AI resolution logic per issue type
  final Map<String, Map<String, dynamic>> _resolutionMap = {
    'provider_late': {
      'title': 'Alternative Provider Assigned',
      'severity': 'Medium',
      'severityColor': Color(0xFFFFB347),
      'steps': [
        '✓ Late report logged with timestamp',
        '✓ Provider notified and warned',
        '✓ Searching for nearest available provider...',
        '✓ Backup provider found: Fallback Pro',
        '✓ New ETA calculated: 25 minutes',
        '✓ User notified via SMS simulation',
      ],
      'outcome':
          'New provider dispatched. Reliability score of original provider reduced by 3 points.',
      'refund': false,
      'newProvider': 'Fallback Pro Services',
    },
    'wrong_pricing': {
      'title': 'Pricing Dispute Resolved',
      'severity': 'High',
      'severityColor': Color(0xFFFF7043),
      'steps': [
        '✓ Booking price verified: Rs 2,200',
        '✓ Reported charge logged: Rs 3,000',
        '✓ Discrepancy detected: Rs 800 overcharge',
        '✓ Refund of Rs 800 initiated',
        '✓ Provider flagged for review',
        '✓ Price transparency reminder sent to provider',
      ],
      'outcome':
          'Partial refund of Rs 800 processed. Provider pricing compliance score updated.',
      'refund': true,
      'refundAmount': 'Rs 800',
    },
    'poor_service': {
      'title': 'Quality Complaint Accepted',
      'severity': 'High',
      'severityColor': Color(0xFFE91E63),
      'steps': [
        '✓ Quality complaint recorded',
        '✓ Provider\'s recent reviews cross-checked',
        '✓ 2 similar complaints found in last 30 days',
        '✓ Service re-visit request sent to provider',
        '✓ 20% discount voucher issued to user',
        '✓ Provider quality score reduced',
      ],
      'outcome':
          'Free re-visit scheduled. Provider placed on quality watch. Your rating will impact future recommendations.',
      'refund': false,
      'voucher': '20% discount on next booking',
    },
    'provider_cancelled': {
      'title': 'Auto-Rescheduling Triggered',
      'severity': 'High',
      'severityColor': Color(0xFF9C27B0),
      'steps': [
        '✓ Cancellation logged by system',
        '✓ Provider penalty applied automatically',
        '✓ Priority search: finding replacement...',
        '✓ 2 available providers found',
        '✓ Best match auto-assigned: RapidFix Services',
        '✓ Original slot preserved for new provider',
        '✓ User and new provider notified',
      ],
      'outcome':
          'Booking automatically rescheduled with RapidFix Services. Cancelled provider\'s score penalised.',
      'refund': false,
      'newProvider': 'RapidFix Services',
    },
    'wrong_service': {
      'title': 'Service Correction Initiated',
      'severity': 'Medium',
      'severityColor': Color(0xFF185FA5),
      'steps': [
        '✓ Wrong service report logged',
        '✓ Original booking details verified',
        '✓ Correct service re-ordered',
        '✓ Correct specialist provider matched',
        '✓ No additional charge applied',
        '✓ Provider briefed on correct task',
      ],
      'outcome':
          'Correct specialist re-dispatched. No extra charge for the user. Provider notified of mistake.',
      'refund': false,
    },
    'safety_concern': {
      'title': 'Safety Report Escalated',
      'severity': 'Critical',
      'severityColor': Color(0xFFD32F2F),
      'steps': [
        '✓ Safety report flagged as CRITICAL',
        '✓ Provider account suspended immediately',
        '✓ Booking cancelled — no charge applied',
        '✓ Full refund initiated: Rs 2,200',
        '✓ Case escalated to human support team',
        '✓ Provider under investigation',
      ],
      'outcome':
          'Provider suspended pending investigation. Full refund processed. Human support will contact you within 2 hours.',
      'refund': true,
      'refundAmount': 'Full Refund',
    },
  };

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _resolveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _resolveFade = CurvedAnimation(parent: _resolveCtrl, curve: Curves.easeOut);
    _resolveSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _resolveCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _resolveCtrl.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submitDispute() async {
    if (_selectedIssue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select an issue type.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() => _isResolving = true);
    _resolveCtrl.reset();

    // Simulate AI resolution time
    await Future.delayed(const Duration(milliseconds: 2600));

    setState(() {
      _isResolving = false;
      _isResolved = true;
      _resolution = _resolutionMap[_selectedIssue];
    });
    _resolveCtrl.forward();
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgMain,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBookingBanner(),
                if (!_isResolved) ...[
                  _buildIssueSelector(),
                  _buildDescriptionField(),
                  if (_isResolving) _buildResolvingCard(),
                  if (!_isResolving) _buildSubmitButton(),
                ],
                if (_isResolved && _resolution != null) _buildResolutionCard(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          SizedBox(
            width: 24,
            height: 28,
            child: CustomPaint(painter: PrismLogoPainter()),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dispute & Support',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                'AI Resolution Agent',
                style: TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }

  // ── Booking Banner ───────────────────────────────────────────

  Widget _buildBookingBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.navy, Color(0xFF1A2E50)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.report_problem_rounded,
              color: AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Report an Issue',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Booking: ${widget.bookingId}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.cyan.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.psychology_rounded, color: AppColors.cyan, size: 12),
                SizedBox(width: 4),
                Text(
                  'AI Auto-Resolve',
                  style: TextStyle(
                    color: AppColors.cyan,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Issue Selector ───────────────────────────────────────────

  Widget _buildIssueSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Text(
            'What went wrong?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ),
        ...(_issueTypes.map((issue) {
          final isSelected = _selectedIssue == issue['id'];
          final color = issue['color'] as Color;
          return GestureDetector(
            onTap: () => setState(() => _selectedIssue = issue['id']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.07) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? color.withOpacity(0.5) : AppColors.border,
                  width: isSelected ? 1.8 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      issue['icon'] as IconData,
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          issue['label'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: isSelected ? color : AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          issue['description'] as String,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    color: isSelected ? color : AppColors.border,
                    size: 22,
                  ),
                ],
              ),
            ),
          );
        })),
      ],
    );
  }

  // ── Description Field ────────────────────────────────────────

  Widget _buildDescriptionField() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Additional Details (Optional)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _descController,
            maxLines: 3,
            style: const TextStyle(fontSize: 13, color: AppColors.textDark),
            decoration: InputDecoration(
              hintText: 'Describe what happened...',
              hintStyle: TextStyle(
                color: AppColors.textMuted.withOpacity(0.6),
                fontSize: 13,
              ),
              filled: true,
              fillColor: AppColors.bgCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.blue, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Resolving Card ───────────────────────────────────────────

  Widget _buildResolvingCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, _) => Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.error.withOpacity(
                      0.4 + 0.6 * _pulseCtrl.value,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Dispute Resolution Agent Running...',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...[
            'Verifying booking record...',
            'Analysing issue type...',
            'Checking provider history...',
            'Calculating resolution...',
            'Dispatching automated action...',
          ].map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.error,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    s,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Submit Button ────────────────────────────────────────────

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _submitDispute,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            elevation: 8,
            shadowColor: AppColors.error.withOpacity(0.35),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.support_agent_rounded, size: 20),
              SizedBox(width: 10),
              Text(
                'Submit Dispute — AI Will Resolve',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Resolution Card ──────────────────────────────────────────

  Widget _buildResolutionCard() {
    final r = _resolution!;
    final severity = r['severity'] as String;
    final severityColor = r['severityColor'] as Color;
    final steps = r['steps'] as List<String>;
    final hasRefund = r['refund'] as bool;
    final hasNewProvider = r.containsKey('newProvider');
    final hasVoucher = r.containsKey('voucher');

    return FadeTransition(
      opacity: _resolveFade,
      child: SlideTransition(
        position: _resolveSlide,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Column(
            children: [
              // Status banner
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [severityColor.withOpacity(0.9), severityColor],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r['title'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Severity: $severity',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '✓ Auto-Resolved',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Resolution steps
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.account_tree_rounded,
                          color: AppColors.purple,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Resolution Workflow',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ...steps.asMap().entries.map((e) {
                      final i = e.key;
                      final step = e.value;
                      final isLast = i == steps.length - 1;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 13,
                                ),
                              ),
                              if (!isLast)
                                Container(
                                  width: 2,
                                  height: 24,
                                  color: AppColors.success.withOpacity(0.3),
                                ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              step,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textDark,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Outcome card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.success.withOpacity(0.25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.info_rounded,
                          color: AppColors.success,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Final Outcome',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      r['outcome'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Outcome pills
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (hasRefund)
                          _outcomePill(
                            Icons.currency_rupee_rounded,
                            r.containsKey('refundAmount')
                                ? 'Refund: ${r['refundAmount']}'
                                : 'Refund Initiated',
                            AppColors.success,
                          ),
                        if (hasNewProvider)
                          _outcomePill(
                            Icons.person_pin_rounded,
                            'New: ${r['newProvider']}',
                            AppColors.blue,
                          ),
                        if (hasVoucher)
                          _outcomePill(
                            Icons.local_offer_rounded,
                            r['voucher'] as String,
                            AppColors.purple,
                          ),
                        _outcomePill(
                          Icons.history_rounded,
                          'Provider Score Updated',
                          AppColors.warning,
                        ),
                        _outcomePill(
                          Icons.hub_rounded,
                          'Logged in AI Trace',
                          AppColors.cyan,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Agent log
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dispute Agent Log',
                      style: TextStyle(
                        color: AppColors.cyan,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _logLine('[Dispute Agent] Issue: $_selectedIssue'),
                    _logLine('[Dispute Agent] Booking: ${widget.bookingId}'),
                    _logLine('[Resolution Engine] Severity: $severity'),
                    _logLine('[Action Agent] Auto-resolution triggered'),
                    _logLine('[Action Agent] Provider score updated'),
                    _logLine(
                      '[Orchestrator] Case closed. ID: DSP-${DateTime.now().millisecondsSinceEpoch % 9999}',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Done button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Back to Bookings',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _outcomePill(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _logLine(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 10,
          color: Color(0xFF8BAACC),
          height: 1.6,
        ),
      ),
    );
  }
}
