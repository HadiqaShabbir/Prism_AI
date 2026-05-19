// ============================================================
// screens/agent_dashboard_screen.dart
// PRISM AI — Agent Dashboard (Showcase Screen)
// Shows all AI agents, their status, activity, confidence
// ============================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'splash_screen.dart';
import '../utils/colors.dart';

class AgentDashboardScreen extends StatefulWidget {
  const AgentDashboardScreen({super.key});

  @override
  State<AgentDashboardScreen> createState() => _AgentDashboardScreenState();
}

class _AgentDashboardScreenState extends State<AgentDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _flowCtrl;
  late AnimationController _rotateCtrl;

  // Simulated live activity ticker
  int _tickCount = 0;
  final List<String> _liveLogs = [];

  final List<Map<String, dynamic>> _agents = [
    {
      'id': 'lang_agent',
      'name': 'Language Parser',
      'subtitle': 'Urdu · Roman Urdu · English · Mixed',
      'icon': Icons.translate_rounded,
      'color': Color(0xFF6C4FD6),
      'status': 'Active',
      'confidence': 94,
      'tasksToday': 12,
      'lastAction': 'Parsed Roman Urdu request',
      'description':
          'Detects script, identifies language mix, normalises text before passing to intent extractor.',
      'capabilities': [
        'Script detection (Arabic/Latin)',
        'Code-switch handling',
        'Noise & typo tolerance',
        'Confidence scoring',
      ],
    },
    {
      'id': 'intent_agent',
      'name': 'Intent Extractor',
      'subtitle': 'Service · Location · Time · Urgency',
      'icon': Icons.psychology_rounded,
      'color': Color(0xFF185FA5),
      'status': 'Active',
      'confidence': 91,
      'tasksToday': 12,
      'lastAction': 'Extracted AC Repair + G-13',
      'description':
          'Extracts structured entities from free-form requests: service type, location, time preference, urgency and budget.',
      'capabilities': [
        'Service type classification',
        'Location & area extraction',
        'Time preference parsing',
        'Urgency & budget detection',
      ],
    },
    {
      'id': 'discovery_agent',
      'name': 'Provider Discovery',
      'subtitle': 'City-filtered · Real-time availability',
      'icon': Icons.search_rounded,
      'color': Color(0xFF00C2D4),
      'status': 'Active',
      'confidence': 100,
      'tasksToday': 12,
      'lastAction': 'Found 3 providers in Karachi',
      'description':
          'Queries provider dataset filtered strictly by city and service category. Returns only relevant candidates.',
      'capabilities': [
        'City-level filtering',
        'Service category match',
        'Availability check',
        'Dataset fallback handling',
      ],
    },
    {
      'id': 'ranking_agent',
      'name': 'Ranking Engine',
      'subtitle': '6-factor weighted scoring',
      'icon': Icons.leaderboard_rounded,
      'color': Color(0xFFFF7043),
      'status': 'Active',
      'confidence': 96,
      'tasksToday': 12,
      'lastAction': 'Ranked 3 providers — Score: 94%',
      'description':
          'Ranks candidates using a weighted multi-factor algorithm: rating, reliability, distance, on-time score, price, and cancellation rate.',
      'capabilities': [
        'Rating (25%) + Reliability (20%)',
        'Distance (20%) + On-time (15%)',
        'Price (10%) + Cancel Rate (10%)',
        'Urgency & budget modifiers',
      ],
    },
    {
      'id': 'pricing_agent',
      'name': 'Pricing Engine',
      'subtitle': 'Dynamic · Transparent · Fair',
      'icon': Icons.price_change_rounded,
      'color': Color(0xFF66BB6A),
      'status': 'Active',
      'confidence': 98,
      'tasksToday': 12,
      'lastAction': 'Quote generated: Rs 2,200',
      'description':
          'Calculates dynamic price using base rate, distance cost, urgency charge, loyalty discount and surge conditions.',
      'capabilities': [
        'Base fee + distance surcharge',
        'Urgency pricing modifier',
        'Loyalty discount engine',
        'Fairness transparency check',
      ],
    },
    {
      'id': 'scheduling_agent',
      'name': 'Scheduling Agent',
      'subtitle': 'Conflict-free · Buffer-aware',
      'icon': Icons.calendar_month_rounded,
      'color': Color(0xFFFFB347),
      'status': 'Active',
      'confidence': 100,
      'tasksToday': 12,
      'lastAction': 'Slot reserved: 10:00 AM tomorrow',
      'description':
          'Prevents double-booking, adds travel buffers, manages waitlists, and auto-reschedules on cancellation.',
      'capabilities': [
        'Double-booking prevention',
        'Travel time buffer (20 min)',
        'Waitlist management',
        'Auto-reschedule on cancel',
      ],
    },
    {
      'id': 'booking_agent',
      'name': 'Booking Agent',
      'subtitle': 'Confirmation · Receipt · Notification',
      'icon': Icons.receipt_rounded,
      'color': Color(0xFF185FA5),
      'status': 'Active',
      'confidence': 100,
      'tasksToday': 8,
      'lastAction': 'Booking #PRZ-2026-001 confirmed',
      'description':
          'Simulates full booking lifecycle: slot reservation, ID generation, confirmation dispatch, reminder scheduling.',
      'capabilities': [
        'Booking ID generation',
        'SMS/WhatsApp simulation',
        'Receipt generation',
        'Reminder scheduling (T-60min)',
      ],
    },
    {
      'id': 'tracking_agent',
      'name': 'Workflow Tracker',
      'subtitle': 'Live status · En-route · Completion',
      'icon': Icons.track_changes_rounded,
      'color': Color(0xFF9C27B0),
      'status': 'Active',
      'confidence': 100,
      'tasksToday': 6,
      'lastAction': 'Provider en-route update sent',
      'description':
          'Drives the 9-step service lifecycle from request received to feedback collection. Updates in real time.',
      'capabilities': [
        '9-step workflow execution',
        'En-route live tracking',
        'Service completion checklist',
        'Feedback trigger automation',
      ],
    },
    {
      'id': 'dispute_agent',
      'name': 'Dispute Agent',
      'subtitle': 'Auto-resolve · Escalate · Refund',
      'icon': Icons.support_agent_rounded,
      'color': Color(0xFFD32F2F),
      'status': 'Standby',
      'confidence': 88,
      'tasksToday': 1,
      'lastAction': 'Pricing dispute resolved — Rs 800 refund',
      'description':
          'Handles 6 dispute types: late provider, wrong pricing, poor service, cancellation, wrong service, safety. Auto-resolves or escalates.',
      'capabilities': [
        '6-issue type classification',
        'Auto-refund calculation',
        'Provider score penalisation',
        'Human escalation trigger',
      ],
    },
  ];

  final List<Map<String, dynamic>> _pipelineSteps = [
    {
      'label': 'User Request',
      'icon': Icons.person_rounded,
      'color': Color(0xFF6C4FD6),
    },
    {
      'label': 'Parse',
      'icon': Icons.translate_rounded,
      'color': Color(0xFF6C4FD6),
    },
    {
      'label': 'Extract',
      'icon': Icons.psychology_rounded,
      'color': Color(0xFF185FA5),
    },
    {
      'label': 'Discover',
      'icon': Icons.search_rounded,
      'color': Color(0xFF00C2D4),
    },
    {
      'label': 'Rank',
      'icon': Icons.leaderboard_rounded,
      'color': Color(0xFFFF7043),
    },
    {
      'label': 'Price',
      'icon': Icons.price_change_rounded,
      'color': Color(0xFF66BB6A),
    },
    {
      'label': 'Book',
      'icon': Icons.receipt_rounded,
      'color': Color(0xFF185FA5),
    },
    {
      'label': 'Track',
      'icon': Icons.track_changes_rounded,
      'color': Color(0xFF9C27B0),
    },
  ];

  final _initialLogs = [
    '[Orchestrator] PRISM AI system initialised',
    '[Orchestrator] 9 agents loaded and active',
    '[Lang Agent] Ready — multilingual mode ON',
    '[Intent Agent] Entity extractor loaded',
    '[Discovery Agent] Provider dataset: 28 providers, 3 cities',
    '[Ranking Engine] 6-factor model ready',
    '[Pricing Engine] Dynamic pricing rules loaded',
    '[Scheduling Agent] Calendar cleared — no conflicts',
    '[Booking Agent] Simulation mode active',
    '[Dispute Agent] 6 issue handlers registered',
    '[Orchestrator] All agents nominal. Awaiting request...',
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _flowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _liveLogs.addAll(_initialLogs);
    // Add periodic log ticks to simulate live activity
    Future.delayed(const Duration(seconds: 1), _startLiveTicks);
  }

  void _startLiveTicks() {
    if (!mounted) return;
    final tickMessages = [
      '[Ranking Engine] Re-scoring providers for city: Karachi',
      '[Scheduling Agent] Slot availability refreshed',
      '[Discovery Agent] Dataset queried — 28 providers active',
      '[Pricing Engine] Surge check: Normal demand',
      '[Lang Agent] Idle — awaiting next request',
      '[Booking Agent] Heartbeat OK',
      '[Orchestrator] System health: All agents nominal',
      '[Dispute Agent] Standby — no active disputes',
      '[Tracking Agent] Workflow state machine idle',
    ];
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _tickCount++;
        _liveLogs.add(tickMessages[_tickCount % tickMessages.length]);
        if (_liveLogs.length > 30) _liveLogs.removeAt(0);
      });
      _startLiveTicks();
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _flowCtrl.dispose();
    _rotateCtrl.dispose();
    super.dispose();
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
                _buildSystemStatusCard(),
                _buildPipelineFlow(),
                _buildAgentGrid(),
                _buildLiveLogTerminal(),
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
      backgroundColor: AppColors.navy,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, _) => Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cyan.withOpacity(0.5 + 0.5 * _pulseCtrl.value),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Agent Dashboard',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'PRISM AI — Multi-Agent Orchestration',
                style: TextStyle(fontSize: 10, color: Color(0xFF8BAACC)),
              ),
            ],
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: Colors.white.withOpacity(0.08)),
      ),
    );
  }

  // ── System Status Card ───────────────────────────────────────

  Widget _buildSystemStatusCard() {
    final activeCount = _agents.where((a) => a['status'] == 'Active').length;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.navy, Color(0xFF1A2E50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Spinning prism logo
              AnimatedBuilder(
                animation: _rotateCtrl,
                builder: (_, _) => Transform.rotate(
                  angle: _rotateCtrl.value * 2 * math.pi,
                  child: SizedBox(
                    width: 44,
                    height: 50,
                    child: CustomPaint(painter: PrismLogoPainter()),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PRISM AI Orchestrator',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Google Antigravity Powered',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, _) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(
                      0.1 + 0.1 * _pulseCtrl.value,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.success.withOpacity(
                            0.6 + 0.4 * _pulseCtrl.value,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'All Systems Go',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(height: 1, color: Colors.white.withOpacity(0.08)),
          const SizedBox(height: 16),
          Row(
            children: [
              _statBox('$activeCount', 'Active Agents', AppColors.success),
              const SizedBox(width: 10),
              _statBox('28', 'Providers', AppColors.cyan),
              const SizedBox(width: 10),
              _statBox('3', 'Cities', AppColors.purple),
              const SizedBox(width: 10),
              _statBox('6', 'Dispute Types', const Color(0xFFFF7043)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBox(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Pipeline Flow ────────────────────────────────────────────

  Widget _buildPipelineFlow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Text(
            'Agentic Pipeline',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _pipelineSteps.length,
            itemBuilder: (_, i) {
              final step = _pipelineSteps[i];
              final isLast = i == _pipelineSteps.length - 1;
              return Row(
                children: [
                  AnimatedBuilder(
                    animation: _flowCtrl,
                    builder: (_, _) {
                      // Travelling pulse effect
                      final progress = _flowCtrl.value * _pipelineSteps.length;
                      final isActive = (progress - i).abs() < 1.0;
                      final color = step['color'] as Color;
                      return Container(
                        width: 68,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive
                              ? color.withOpacity(0.12)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isActive
                                ? color.withOpacity(0.5)
                                : AppColors.border,
                            width: isActive ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              step['icon'] as IconData,
                              color: isActive ? color : AppColors.textMuted,
                              size: 20,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              step['label'] as String,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: isActive
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isActive ? color : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  if (!isLast)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: AnimatedBuilder(
                        animation: _flowCtrl,
                        builder: (_, _) {
                          final progress =
                              _flowCtrl.value * _pipelineSteps.length;
                          final isFlowing = progress > i && progress < i + 1.5;
                          return Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: isFlowing
                                ? AppColors.cyan
                                : AppColors.border,
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Agent Grid ───────────────────────────────────────────────

  Widget _buildAgentGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Text(
            'Agent Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ),
        ..._agents.map(
          (agent) => _AgentCard(agent: agent, pulseCtrl: _pulseCtrl),
        ),
      ],
    );
  }

  // ── Live Log Terminal ─────────────────────────────────────────

  Widget _buildLiveLogTerminal() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, _) => Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.success.withOpacity(
                        0.5 + 0.5 * _pulseCtrl.value,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Live Orchestration Log',
                  style: TextStyle(
                    color: AppColors.cyan,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_liveLogs.length} entries',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: Colors.white.withOpacity(0.06)),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _liveLogs.reversed.take(12).map((log) {
                // Colour code different agents
                Color logColor = const Color(0xFF8BAACC);
                if (log.contains('[Orchestrator]')) {
                  logColor = AppColors.cyan;
                } else if (log.contains('[Ranking')) {
                  logColor = const Color(0xFFFF7043);
                } else if (log.contains('[Pricing')) {
                  logColor = const Color(0xFF66BB6A);
                } else if (log.contains('[Dispute')) {
                  logColor = const Color(0xFFFF4444);
                } else if (log.contains('[Lang')) {
                  logColor = AppColors.purple;
                } else if (log.contains('[Intent')) {
                  logColor = const Color(0xFF5BA3D9);
                } else if (log.contains('[Scheduling')) {
                  logColor = const Color(0xFFFFB347);
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    log,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      color: logColor,
                      height: 1.5,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  AGENT CARD WIDGET
// ═══════════════════════════════════════════════════════════════

class _AgentCard extends StatefulWidget {
  final Map<String, dynamic> agent;
  final AnimationController pulseCtrl;

  const _AgentCard({required this.agent, required this.pulseCtrl});

  @override
  State<_AgentCard> createState() => _AgentCardState();
}

class _AgentCardState extends State<_AgentCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.agent;
    final color = a['color'] as Color;
    final isActive = a['status'] == 'Active';
    final confidence = a['confidence'] as int;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive ? color.withOpacity(0.3) : AppColors.border,
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(isActive ? 0.08 : 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(a['icon'] as IconData, color: color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a['name'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          a['subtitle'] as String,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Status badge
                      AnimatedBuilder(
                        animation: widget.pulseCtrl,
                        builder: (_, _) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (isActive
                                        ? AppColors.success
                                        : AppColors.warning)
                                    .withOpacity(
                                      isActive
                                          ? 0.08 + 0.06 * widget.pulseCtrl.value
                                          : 0.08,
                                    ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color:
                                  (isActive
                                          ? AppColors.success
                                          : AppColors.warning)
                                      .withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isActive
                                      ? AppColors.success
                                      : AppColors.warning,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                a['status'] as String,
                                style: TextStyle(
                                  color: isActive
                                      ? AppColors.success
                                      : AppColors.warning,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Today: ${a['tasksToday']}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Confidence bar
              Row(
                children: [
                  const Text(
                    'Confidence',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: confidence / 100,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          confidence >= 90 ? color : AppColors.warning,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$confidence%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Last action
              Row(
                children: [
                  const Icon(
                    Icons.arrow_right_rounded,
                    color: AppColors.textMuted,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      a['lastAction'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: AppColors.textMuted,
                    size: 16,
                  ),
                ],
              ),

              // Expanded details
              if (_expanded) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a['description'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Capabilities:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...(a['capabilities'] as List<String>).map(
                        (cap) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Icon(Icons.check_rounded, color: color, size: 12),
                              const SizedBox(width: 6),
                              Text(
                                cap,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textDark,
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
            ],
          ),
        ),
      ),
    );
  }
}
