// ============================================================
// lib/screens/home_screen.dart
// PRISM AI — Home Screen  v4 (clean single-flow architecture)
//
// Changes from v3:
//  • Removed all fake/hardcoded "Find Service" booking logic
//  • Home tab now shows a clean launcher card → Advanced Search
//  • Real bookings from BookingManager shown in Bookings tab
//  • Welcome card stats pulled from BookingManager live
//  • No duplicate flows — ONE booking path only (Advanced Search)
//  • All animations/theme/design preserved
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'splash_screen.dart';
import '../services/gemini_service.dart';
import 'service_request_screen.dart';
import '../services/booking_manager.dart';

class PrismHomeScreen extends StatefulWidget {
  final String userName;
  final String userCity;
  const PrismHomeScreen({
    super.key,
    this.userName = 'Hadiqa',
    this.userCity = 'Karachi',
  });

  @override
  State<PrismHomeScreen> createState() => _PrismHomeScreenState();
}

class _PrismHomeScreenState extends State<PrismHomeScreen>
    with TickerProviderStateMixin {
  // ── Palette ──────────────────────────────────────────────────
  static const kNavy = Color(0xFF0A1628);
  static const kBlue = Color(0xFF185FA5);
  static const kCyan = Color(0xFF00C2D4);
  static const kPurple = Color(0xFF6C4FD6);
  static const kCard = Color(0xFFF5F9FF);
  static const kBorder = Color(0xFFD8E6F5);
  static const kText = Color(0xFF1A1A2E);
  static const kMuted = Color(0xFF6B7A8D);
  static const kGreen = Color(0xFF4CAF50);

  // ── State ────────────────────────────────────────────────────
  int _navIndex = 0;

  // ── Animations ───────────────────────────────────────────────
  late AnimationController _pulseCtrl;

  // ── Category quick-launch data ────────────────────────────────
  final List<Map<String, dynamic>> _categories = [
    {
      'icon': Icons.ac_unit_rounded,
      'label': 'AC Repair',
      'color': Color(0xFF00C2D4),
    },
    {
      'icon': Icons.electrical_services_rounded,
      'label': 'Electrician',
      'color': Color(0xFFFFB347),
    },
    {
      'icon': Icons.plumbing_rounded,
      'label': 'Plumbing',
      'color': Color(0xFF4FC3F7),
    },
    {
      'icon': Icons.face_retouching_natural_rounded,
      'label': 'Beautician',
      'color': Color(0xFFFF80AB),
    },
    {
      'icon': Icons.menu_book_rounded,
      'label': 'Tutor',
      'color': Color(0xFF6C4FD6),
    },
    {
      'icon': Icons.cleaning_services_rounded,
      'label': 'Cleaning',
      'color': Color(0xFF66BB6A),
    },
    {
      'icon': Icons.build_rounded,
      'label': 'Mechanic',
      'color': Color(0xFFFF7043),
    },
    {
      'icon': Icons.local_shipping_rounded,
      'label': 'Shifting',
      'color': Color(0xFF185FA5),
    },
  ];

  // ── AI Trace logs (static showcase) ──────────────────────────
  final List<_TraceLog> _traceLogs = const [
    _TraceLog(
      agent: 'Gemini Orchestrator',
      icon: Icons.hub_rounded,
      color: Color(0xFF6C4FD6),
      action: 'Request Received',
      detail:
          '[Gemini Orchestrator] Request received\n[Gemini Orchestrator] Analyzing intent via gemini-2.5-flash\n[Gemini Orchestrator] Routing to Language Parser Agent',
      timestamp: '—',
      success: true,
    ),
    _TraceLog(
      agent: 'Language Parser Agent',
      icon: Icons.translate_rounded,
      color: Color(0xFF00C2D4),
      action: 'Intent Extraction',
      detail:
          '[Language Parser] Input classified: Roman Urdu + English mix\n[Language Parser] Confidence: 94%\n[Gemini Orchestrator] Routing to Entity Extractor Agent',
      timestamp: '—',
      success: true,
    ),
    _TraceLog(
      agent: 'Entity Extractor Agent',
      icon: Icons.data_object_rounded,
      color: Color(0xFF185FA5),
      action: 'Field Extraction',
      detail:
          '[Entity Extractor] service=AC Repair\n[Entity Extractor] location=DHA → city=Karachi\n[Entity Extractor] urgency=HIGH  time=Tomorrow Morning\n[Gemini Orchestrator] Routing to Provider Discovery Agent',
      timestamp: '—',
      success: true,
    ),
    _TraceLog(
      agent: 'Provider Discovery Agent',
      icon: Icons.search_rounded,
      color: Color(0xFF185FA5),
      action: 'Dataset Query',
      detail:
          '[Provider Discovery] Querying mock dataset\n[Provider Discovery] City filter: Karachi\n[Provider Discovery] Service filter: AC Repair\n[Provider Discovery] 3 providers found\n[Gemini Orchestrator] Routing to Ranking Engine Agent',
      timestamp: '—',
      success: true,
    ),
    _TraceLog(
      agent: 'Ranking Engine Agent',
      icon: Icons.leaderboard_rounded,
      color: Color(0xFFFF7043),
      action: 'Multi-Factor Ranking',
      detail:
          '[Ranking Engine] Rating(25%) + Reliability(20%) + Distance(20%) + OnTime(15%) + Price(10%) + CancelRate(10%)\n[Ranking Engine] Top pick: Ali AC Services — Score: 94%\n[Ranking Engine] Reason: Highest reliability + AC specialist\n[Gemini Orchestrator] Routing to Pricing Agent',
      timestamp: '—',
      success: true,
    ),
    _TraceLog(
      agent: 'Pricing Engine Agent',
      icon: Icons.price_change_rounded,
      color: Color(0xFF66BB6A),
      action: 'Dynamic Quote',
      detail:
          '[Pricing Engine] Base: Rs 1800\n[Pricing Engine] Distance(2.1km): +Rs 300\n[Pricing Engine] Urgency(High): +Rs 200\n[Pricing Engine] Loyalty: -Rs 100\n[Pricing Engine] Final: Rs 2,200\n[Gemini Orchestrator] Routing to Booking Agent',
      timestamp: '—',
      success: true,
    ),
    _TraceLog(
      agent: 'Booking Agent',
      icon: Icons.receipt_rounded,
      color: Color(0xFF185FA5),
      action: 'Confirmation Dispatch',
      detail:
          '[Booking Agent] Slot confirmed: Tomorrow 10:00 AM\n[Booking Agent] Booking ID: #PRZ-2024-001\n[Booking Agent] Provider notified (simulated)\n[Booking Agent] Reminder scheduled: T-60min\n[Gemini Orchestrator] Workflow complete',
      timestamp: '—',
      success: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Navigate to Advanced Search (the ONE booking flow) ────────
  void _goToAdvancedSearch({String prefill = ''}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceRequestScreen(
          userName: widget.userName,
          userCity: widget.userCity,
        ),
      ),
    ).then((_) {
      // Refresh UI when returning so booking counts update
      if (mounted) setState(() {});
    });
  }

  void _categoryTap(String label) => _goToAdvancedSearch(
    prefill: 'I need a $label service in ${widget.userCity}',
  );

  String _formatDate(DateTime dt) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}';
  }

  String _currentTime() {
    final n = DateTime.now();
    return '${n.hour.toString().padLeft(2, '0')}:${n.minute.toString().padLeft(2, '0')}:${n.second.toString().padLeft(2, '0')}';
  }

  // ═══════════════ BUILD ═══════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: IndexedStack(
        index: _navIndex,
        children: [
          _buildHomeTab(),
          _buildBookingsTab(),
          _buildAiTraceTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────────

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.calendar_today_rounded, 'label': 'Bookings'},
      {'icon': Icons.psychology_rounded, 'label': 'AI Trace'},
      {'icon': Icons.person_rounded, 'label': 'Profile'},
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: kBlue.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final active = _navIndex == i;
              // Show live booking badge on Bookings tab
              final bookingCount = BookingManager().allBookings.length;
              return GestureDetector(
                onTap: () => setState(() => _navIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: active ? kBlue.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            items[i]['icon'] as IconData,
                            color: active ? kBlue : kMuted,
                            size: 22,
                          ),
                          if (i == 1 && bookingCount > 0)
                            Positioned(
                              top: -4,
                              right: -6,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF4444),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '$bookingCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: active
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: active ? kBlue : kMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // HOME TAB
  // ══════════════════════════════════════════════════════════════

  Widget _buildHomeTab() {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreetingCard(),
              _buildAiLaunchCard(),
              _buildCategorySection(),
              _buildHowItWorksCard(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  // ── App Bar ───────────────────────────────────────────────────

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 64,
      title: Row(
        children: [
          SizedBox(
            width: 28,
            height: 34,
            child: CustomPaint(painter: PrismLogoPainter()),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PRISM AI',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: kText,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                'Smart Service Orchestrator',
                style: TextStyle(
                  fontSize: 10,
                  color: kMuted,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: kText,
                size: 24,
              ),
              onPressed: () {},
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF4444),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _navIndex = 3;
              });
            },
            child: CircleAvatar(
              radius: 17,
              backgroundColor: kBlue.withOpacity(0.12),
              child: Text(
                widget.userName.isNotEmpty
                    ? widget.userName[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  color: kBlue,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: kBorder),
      ),
    );
  }

  // ── Greeting Card ─────────────────────────────────────────────

  Widget _buildGreetingCard() {
    final bookings = BookingManager().allBookings;
    final bookingCount = bookings.length;
    final latestBooking = bookings.isNotEmpty ? bookings.first : null;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kNavy, Color(0xFF1A2E50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: kNavy.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(DateTime.now()),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.userCity,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseCtrl,
                      builder: (context, child) => Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: kGreen.withOpacity(
                            0.5 + 0.5 * _pulseCtrl.value,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'AI Active',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(height: 1, color: Colors.white.withOpacity(0.08)),
          const SizedBox(height: 16),

          // ── Live stats row ──────────────────────────────────
          Row(
            children: [
              _statPill(
                Icons.check_circle_outline_rounded,
                '$bookingCount',
                'Bookings',
              ),
              const SizedBox(width: 10),
              _statPill(
                Icons.location_on_outlined,
                widget.userCity.length > 8
                    ? '${widget.userCity.substring(0, 7)}..'
                    : widget.userCity,
                'Location',
              ),
              const SizedBox(width: 10),
              _statPill(Icons.auto_awesome_rounded, 'ON', 'AI Engine'),
            ],
          ),

          // ── Latest booking preview ──────────────────────────
          if (latestBooking != null) ...[
            const SizedBox(height: 14),
            Container(height: 1, color: Colors.white.withOpacity(0.08)),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => setState(() => _navIndex = 1),
              child: Row(
                children: [
                  const Icon(Icons.history_rounded, color: kCyan, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Last: ${latestBooking.service} · ${latestBooking.providerName}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white30,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statPill(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: kCyan, size: 16),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── AI Launch Card (replaces broken Find Service box) ─────────

  Widget _buildAiLaunchCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header badge
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [kBlue, kPurple]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'AI-Powered Search',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Urdu · Roman Urdu · English',
                style: TextStyle(fontSize: 11, color: kMuted.withOpacity(0.7)),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Description
          const Text(
            'Describe what service you need in your own words — our AI understands Urdu, Roman Urdu, and English.',
            style: TextStyle(fontSize: 13, color: kMuted, height: 1.55),
          ),
          const SizedBox(height: 6),

          // Example chips
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children:
                [
                      '"AC repair kal subah"',
                      '"Urgent electrician"',
                      '"Plumber today"',
                    ]
                    .map(
                      (e) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: kCard,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: kBorder),
                        ),
                        child: Text(
                          e,
                          style: const TextStyle(fontSize: 11, color: kMuted),
                        ),
                      ),
                    )
                    .toList(),
          ),

          const SizedBox(height: 16),

          // Single CTA button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _goToAdvancedSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: kBlue,
                foregroundColor: Colors.white,
                elevation: 6,
                shadowColor: kBlue.withOpacity(0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.psychology_rounded, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Find a Service with AI',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Category Section ──────────────────────────────────────────

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 22, 16, 12),
          child: Text(
            'Quick Services',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: kText,
            ),
          ),
        ),
        SizedBox(
          height: 108,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _categories.length,
            itemBuilder: (_, i) {
              final cat = _categories[i];
              return GestureDetector(
                onTap: () => _categoryTap(cat['label'] as String),
                child: Container(
                  width: 82,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: kBorder),
                    boxShadow: [
                      BoxShadow(
                        color: (cat['color'] as Color).withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: (cat['color'] as Color).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          cat['icon'] as IconData,
                          color: cat['color'] as Color,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat['label'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: kText,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── How It Works Card ─────────────────────────────────────────

  Widget _buildHowItWorksCard() {
    final steps = [
      {
        'icon': Icons.mic_rounded,
        'color': kCyan,
        'title': 'Describe',
        'sub': 'Type or say what you need in any language',
      },
      {
        'icon': Icons.psychology_rounded,
        'color': kPurple,
        'title': 'AI Parses',
        'sub': 'Gemini extracts service, location & urgency',
      },
      {
        'icon': Icons.leaderboard_rounded,
        'color': kBlue,
        'title': 'Ranked',
        'sub': '6-factor AI ranks the best providers',
      },
      {
        'icon': Icons.flash_on_rounded,
        'color': const Color(0xFF4CAF50),
        'title': 'Booked',
        'sub': 'Confirm and track your appointment',
      },
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: kPurple, size: 16),
              SizedBox(width: 7),
              Text(
                'How PRISM AI Works',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: kText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: steps.asMap().entries.map((e) {
              final s = e.value;
              final isLast = e.key == steps.length - 1;
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: (s['color'] as Color).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              s['icon'] as IconData,
                              color: s['color'] as Color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            s['title'] as String,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: kText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s['sub'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: kMuted,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: kBorder,
                        size: 18,
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // BOOKINGS TAB  — real data from BookingManager
  // ══════════════════════════════════════════════════════════════

  Widget _buildBookingsTab() {
    final bookings = BookingManager().allBookings;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tabHeader('My Bookings', Icons.calendar_today_rounded),
          Expanded(
            child: bookings.isEmpty
                ? _emptyState(
                    Icons.calendar_today_rounded,
                    'No bookings yet',
                    'Use "Find a Service with AI" on the Home tab to make your first booking.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: bookings.length,
                    itemBuilder: (_, i) =>
                        _buildBookingCard(bookings[i], isFirst: i == 0),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BookingModel b, {required bool isFirst}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isFirst ? kNavy : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isFirst ? Colors.transparent : kBorder),
        boxShadow: [
          BoxShadow(
            color: (isFirst ? kNavy : kBlue).withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: kGreen.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: kGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      b.status,
                      style: const TextStyle(
                        color: kGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                b.bookingId,
                style: TextStyle(
                  color: isFirst ? const Color(0xFF8BAACC) : kMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Service & provider
          Text(
            b.service,
            style: TextStyle(
              color: isFirst ? Colors.white : kText,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            b.providerName,
            style: TextStyle(
              color: isFirst ? const Color(0xFF8BAACC) : kMuted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),

          // Slot & city
          Row(
            children: [
              Icon(Icons.access_time_rounded, color: kCyan, size: 14),
              const SizedBox(width: 5),
              Text(
                b.slot,
                style: TextStyle(
                  color: isFirst ? Colors.white : kText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 14),
              Icon(Icons.location_on_rounded, color: kCyan, size: 14),
              const SizedBox(width: 5),
              Text(
                b.city,
                style: TextStyle(
                  color: isFirst ? Colors.white : kText,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Price & payment
          Text(
            'Rs ${_formatPrice(b.price)} · ${b.paymentMethod}',
            style: TextStyle(
              color: isFirst ? const Color(0xFF8BAACC) : kMuted,
              fontSize: 12,
            ),
          ),

          // Action buttons for most recent booking
          if (isFirst) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF8BAACC)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Track', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Contact',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatPrice(int price) => price.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );

  // ══════════════════════════════════════════════════════════════
  // AI TRACE TAB
  // ══════════════════════════════════════════════════════════════

  Widget _buildAiTraceTab() {
    final hasBookings = BookingManager().allBookings.isNotEmpty;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tabHeader('AI Reasoning Trace', Icons.psychology_rounded),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kNavy, Color(0xFF1A2E50)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.hub_rounded, color: kCyan, size: 16),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Gemini Orchestrator — Multi-agent pipeline',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (context, child) => Icon(
                      Icons.circle,
                      color: kGreen.withOpacity(0.4 + 0.6 * _pulseCtrl.value),
                      size: 8,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Active',
                    style: TextStyle(color: kGreen, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: hasBookings
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _traceLogs.length,
                    itemBuilder: (_, i) => _TraceLogCard(log: _traceLogs[i]),
                  )
                : _emptyState(
                    Icons.psychology_outlined,
                    'No trace yet',
                    'Make a booking via AI search to see the reasoning pipeline.',
                  ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // PROFILE TAB
  // ══════════════════════════════════════════════════════════════

  Widget _buildProfileTab() {
    final bookings = BookingManager().allBookings;
    final bookCount = bookings.length;

    return SafeArea(
      child: ListView(
        children: [
          _tabHeader('Profile', Icons.person_rounded),
          const SizedBox(height: 8),
          // Avatar card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [kNavy, Color(0xFF1A2E50)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: kBlue,
                  child: Text(
                    widget.userName.isNotEmpty
                        ? widget.userName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: kCyan,
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.userCity,
                            style: const TextStyle(
                              color: Color(0xFF8BAACC),
                              fontSize: 13,
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
          const SizedBox(height: 20),
          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _statCard(
                  'Bookings',
                  '$bookCount',
                  Icons.calendar_today_rounded,
                  kBlue,
                ),
                const SizedBox(width: 10),
                _statCard(
                  'AI Searches',
                  '$bookCount',
                  Icons.search_rounded,
                  kPurple,
                ),
                const SizedBox(width: 10),
                _statCard(
                  'Saved',
                  '0',
                  Icons.favorite_rounded,
                  const Color(0xFFFF4081),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Menu
          ...[
            ('My Addresses', Icons.home_rounded, kBlue),
            ('Payment Methods', Icons.credit_card_rounded, kPurple),
            ('Notifications', Icons.notifications_rounded, kCyan),
            (
              'Language Settings',
              Icons.language_rounded,
              const Color(0xFF66BB6A),
            ),
            (
              'Help & Support',
              Icons.help_outline_rounded,
              const Color(0xFFFFB347),
            ),
            ('About PRISM AI', Icons.info_outline_rounded, kMuted),
          ].map((item) => _profileMenuItem(item.$1, item.$2, item.$3)),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: kText,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, color: kMuted)),
          ],
        ),
      ),
    );
  }

  Widget _profileMenuItem(String label, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: kText,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: kMuted,
          size: 20,
        ),
        onTap: () {},
      ),
    );
  }

  // ── Shared helpers ────────────────────────────────────────────

  Widget _tabHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Row(
        children: [
          Icon(icon, color: kBlue, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: kText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(IconData icon, String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: kBorder),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: kMuted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: kMuted, height: 1.5),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => setState(() => _navIndex = 0),
              icon: const Icon(Icons.home_rounded, size: 16),
              label: const Text(
                'Go to Home',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// AI TRACE LOG
// ═══════════════════════════════════════════════════════════════

class _TraceLog {
  final String agent;
  final IconData icon;
  final Color color;
  final String action;
  final String detail;
  final String timestamp;
  final bool success;

  const _TraceLog({
    required this.agent,
    required this.icon,
    required this.color,
    required this.action,
    required this.detail,
    required this.timestamp,
    required this.success,
  });
}

class _TraceLogCard extends StatefulWidget {
  final _TraceLog log;
  const _TraceLogCard({required this.log});

  @override
  State<_TraceLogCard> createState() => _TraceLogCardState();
}

class _TraceLogCardState extends State<_TraceLogCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final log = widget.log;
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD8E6F5)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: log.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(log.icon, color: log.color, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.agent,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      Text(
                        log.action,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7A8D),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        log.success ? '✓ Done' : '● Running',
                        style: const TextStyle(
                          color: Color(0xFF4CAF50),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      log.timestamp,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF6B7A8D),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A1628),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  log.detail,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: Color(0xFF8BAACC),
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// HomeScreen wrapper (keeps existing navigation working)
// ═══════════════════════════════════════════════════════════════

class HomeScreen extends StatelessWidget {
  final String userName;
  final String userCity;

  const HomeScreen({
    super.key,
    this.userName = 'User',
    this.userCity = 'Karachi',
  });

  @override
  Widget build(BuildContext context) {
    return PrismHomeScreen(userName: userName, userCity: userCity);
  }
}
