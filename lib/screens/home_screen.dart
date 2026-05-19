import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'splash_screen.dart';
import 'agent_dashboard_screen.dart';

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
  // ── Colors ──────────────────────────────────────────────────
  static const kNavy = Color(0xFF0A1628);
  static const kBlue = Color(0xFF185FA5);
  static const kCyan = Color(0xFF00C2D4);
  static const kPurple = Color(0xFF6C4FD6);
  static const kCard = Color(0xFFF5F9FF);
  static const kBorder = Color(0xFFD8E6F5);
  static const kText = Color(0xFF1A1A2E);
  static const kMuted = Color(0xFF6B7A8D);

  // ── State ────────────────────────────────────────────────────
  int _navIndex = 0;
  final _requestController = TextEditingController();
  bool _aiThinking = false;
  bool _showAiCard = false;
  bool _showProviders = false;
  bool _showPricing = false;
  bool _bookingDone = false;

  // ── Animation controllers ────────────────────────────────────
  late AnimationController _pulseCtrl;
  late AnimationController _cardCtrl;
  late Animation<double> _cardFade;
  late Animation<Offset> _cardSlide;

  // ── Mock data ────────────────────────────────────────────────
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

  final _aiUnderstanding = {
    'service': 'AC Repair',
    'location': 'G-13, Islamabad',
    'urgency': 'High',
    'time': 'Tomorrow Morning',
    'budget': 'Medium Sensitivity',
    'confidence': 92,
  };

  final List<Map<String, dynamic>> _providers = [
    {
      'name': 'Ali AC Services',
      'rating': 4.8,
      'reviews': 124,
      'distance': '2.1 km',
      'onTime': 96,
      'price': 2500,
      'available': '10:00 AM',
      'badge': 'Top Pick',
      'badgeColor': Color(0xFF185FA5),
      'reasons': [
        'Specialized in AC repair',
        'High reliability score',
        'Low cancellation rate',
        'Fits your budget',
      ],
    },
    {
      'name': 'CoolTech Solutions',
      'rating': 4.6,
      'reviews': 89,
      'distance': '3.4 km',
      'onTime': 91,
      'price': 2200,
      'available': '11:00 AM',
      'badge': 'Budget Friendly',
      'badgeColor': Color(0xFF00C2D4),
      'reasons': [
        'Lower price point',
        'Good recent reviews',
        'Available earlier',
        'Certified technician',
      ],
    },
    {
      'name': 'AirFlow Experts',
      'rating': 4.5,
      'reviews': 67,
      'distance': '1.8 km',
      'onTime': 88,
      'price': 2800,
      'available': '12:00 PM',
      'badge': 'Nearest',
      'badgeColor': Color(0xFF6C4FD6),
      'reasons': [
        'Closest to location',
        'Premium service quality',
        'Senior technician',
        'Same-day availability',
      ],
    },
  ];

  final _bookingTimeline = [
    {'label': 'Request Received', 'done': true},
    {'label': 'AI Analysis Complete', 'done': true},
    {'label': 'Provider Matched', 'done': true},
    {'label': 'Booking Confirmed', 'done': false},
    {'label': 'Technician En Route', 'done': false},
    {'label': 'Service In Progress', 'done': false},
    {'label': 'Feedback Pending', 'done': false},
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _cardFade = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut);
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _cardCtrl.dispose();
    _requestController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (_requestController.text.trim().isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _aiThinking = true;
      _showAiCard = false;
      _showProviders = false;
      _showPricing = false;
      _bookingDone = false;
    });
    _cardCtrl.reset();
    await Future.delayed(const Duration(milliseconds: 2200));
    setState(() {
      _aiThinking = false;
      _showAiCard = true;
    });
    _cardCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => _showProviders = true);
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _showPricing = true);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AgentDashboardScreen()),
    );
  }

  void _bookNow() {
    HapticFeedback.mediumImpact();
    setState(() => _bookingDone = true);
    _bookingTimeline[3]['done'] = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _BookingSuccessDialog(
        onDone: () {
          Navigator.pop(context);
          setState(() => _navIndex = 1);
        },
      ),
    );
  }

  void _categoryTap(String label) {
    _requestController.text = 'I need a $label service';
    _submitRequest();
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

  // ── Bottom Nav ───────────────────────────────────────────────

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
                      Icon(
                        items[i]['icon'] as IconData,
                        color: active ? kBlue : kMuted,
                        size: 22,
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

  // ── HOME TAB ─────────────────────────────────────────────────

  Widget _buildHomeTab() {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreetingCard(),
              _buildRequestBox(),
              if (_aiThinking) _buildThinkingIndicator(),
              if (_showAiCard) _buildAiUnderstandingCard(),
              if (_showProviders) _buildProviderSection(),
              if (_showPricing) _buildPricingCard(),
              if (_showPricing && !_bookingDone) _buildBookButton(),
              if (!_showAiCard) _buildCategorySection(),
              if (_bookingDone) _buildWorkflowTimeline(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  // ── App Bar ──────────────────────────────────────────────────

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
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
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: kBorder),
      ),
    );
  }

  // ── Welcome Card ─────────────────────────────────────────────

  Widget _buildGreetingCard() {
    final now = DateTime.now();
    final dateStr = _formatDate(now);

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
                      dateStr,
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
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
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
          Row(
            children: [
              _statPill(Icons.check_circle_outline_rounded, '0', 'Bookings'),
              const SizedBox(width: 10),
              _statPill(Icons.search_rounded, '0', 'Searches'),
              const SizedBox(width: 10),
              _statPill(
                Icons.location_on_outlined,
                widget.userCity.length > 8
                    ? '${widget.userCity.substring(0, 7)}..'
                    : widget.userCity,
                'Location',
              ),
            ],
          ),
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

  // ── AI Request Box ───────────────────────────────────────────

  Widget _buildRequestBox() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
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
          Row(
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
                      'AI Request',
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
          const SizedBox(height: 12),
          TextField(
            controller: _requestController,
            maxLines: 3,
            minLines: 2,
            style: const TextStyle(fontSize: 15, color: kText, height: 1.5),
            decoration: InputDecoration(
              hintText:
                  '"Mujhe kal morning mein AC technician chahiye G-13 mein..."',
              hintStyle: TextStyle(
                color: kMuted.withOpacity(0.55),
                fontSize: 14,
                height: 1.5,
              ),
              filled: true,
              fillColor: kCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: kBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: kBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: kBlue, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Mic button
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kBorder),
                ),
                child: const Icon(Icons.mic_rounded, color: kBlue, size: 22),
              ),
              const SizedBox(width: 10),
              // Send button
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _aiThinking ? null : _submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBlue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: kBlue.withOpacity(0.5),
                      elevation: 6,
                      shadowColor: kBlue.withOpacity(0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.send_rounded, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Find Service',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Thinking indicator ───────────────────────────────────────

  Widget _buildThinkingIndicator() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, _) => Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kCyan.withOpacity(0.4 + 0.6 * _pulseCtrl.value),
              ),
            ),
          ),
          const SizedBox(width: 6),
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, _) => Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kPurple.withOpacity(0.3 + 0.7 * (1 - _pulseCtrl.value)),
              ),
            ),
          ),
          const SizedBox(width: 6),
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, _) => Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kBlue.withOpacity(0.3 + 0.7 * _pulseCtrl.value),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'AI is analyzing your request...',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: kText,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Parsing language · Extracting intent · Matching providers',
                  style: TextStyle(fontSize: 11, color: kMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── AI Understanding Card ────────────────────────────────────

  Widget _buildAiUnderstandingCard() {
    final confidence = _aiUnderstanding['confidence'] as int;
    return FadeTransition(
      opacity: _cardFade,
      child: SlideTransition(
        position: _cardSlide,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kBorder),
            boxShadow: [
              BoxShadow(
                color: kBlue.withOpacity(0.07),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [kPurple, kCyan]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.psychology_rounded,
                          color: Colors.white,
                          size: 13,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'AI Understanding',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Confidence score
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF4CAF50).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          color: Color(0xFF4CAF50),
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$confidence% Confidence',
                          style: const TextStyle(
                            color: Color(0xFF4CAF50),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Confidence bar
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: confidence / 100,
                  backgroundColor: kBorder,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF4CAF50),
                  ),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 16),
              // Extracted entities grid
              _entityRow(
                Icons.build_circle_rounded,
                'Service',
                _aiUnderstanding['service'] as String,
                kBlue,
              ),
              const SizedBox(height: 10),
              _entityRow(
                Icons.location_on_rounded,
                'Location',
                _aiUnderstanding['location'] as String,
                kPurple,
              ),
              const SizedBox(height: 10),
              _entityRow(
                Icons.warning_amber_rounded,
                'Urgency',
                _aiUnderstanding['urgency'] as String,
                const Color(0xFFFF7043),
              ),
              const SizedBox(height: 10),
              _entityRow(
                Icons.schedule_rounded,
                'Time',
                _aiUnderstanding['time'] as String,
                kCyan,
              ),
              const SizedBox(height: 10),
              _entityRow(
                Icons.account_balance_wallet_rounded,
                'Budget',
                _aiUnderstanding['budget'] as String,
                const Color(0xFF66BB6A),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _entityRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Text('$label: ', style: const TextStyle(fontSize: 13, color: kMuted)),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: kText,
          ),
        ),
        const Spacer(),
        const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF4CAF50),
          size: 16,
        ),
      ],
    );
  }

  // ── Category Section ─────────────────────────────────────────

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

  // ── Provider Section ─────────────────────────────────────────

  Widget _buildProviderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
          child: Row(
            children: const [
              Icon(Icons.leaderboard_rounded, color: kBlue, size: 18),
              SizedBox(width: 7),
              Text(
                'AI-Ranked Providers',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: kText,
                ),
              ),
            ],
          ),
        ),
        ..._providers.asMap().entries.map((e) {
          final idx = e.key;
          final p = e.value;
          return _ProviderCard(
            provider: p,
            rank: idx + 1,
            onBook: idx == 0 ? null : () {},
          );
        }),
      ],
    );
  }

  // ── Pricing Card ─────────────────────────────────────────────

  Widget _buildPricingCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      padding: const EdgeInsets.all(18),
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
          Row(
            children: const [
              Icon(Icons.receipt_long_rounded, color: kBlue, size: 18),
              SizedBox(width: 8),
              Text(
                'Dynamic Price Estimate',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: kText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _priceRow('Base Service Fee', 'Rs 1,800', false),
          _priceRow('Distance Cost (2.1 km)', 'Rs 300', false),
          _priceRow('Urgency Charge (High)', 'Rs 200', false),
          _priceRow('Loyalty Discount', '– Rs 100', false, isDiscount: true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: kBorder, thickness: 1.5),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Final Price',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: kText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [kBlue, kPurple]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Rs 2,200',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF4CAF50).withOpacity(0.2),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFF4CAF50),
                  size: 14,
                ),
                SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Fair pricing based on demand, urgency & distance. Both user & provider rates are transparent.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF4CAF50),
                      height: 1.4,
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

  Widget _priceRow(
    String label,
    String amount,
    bool isTotal, {
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: kMuted)),
          Text(
            amount,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDiscount ? const Color(0xFF4CAF50) : kText,
            ),
          ),
        ],
      ),
    );
  }

  // ── Book Button ──────────────────────────────────────────────

  Widget _buildBookButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed: _bookNow,
          style: ElevatedButton.styleFrom(
            backgroundColor: kBlue,
            foregroundColor: Colors.white,
            elevation: 10,
            shadowColor: kBlue.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.flash_on_rounded, size: 20),
              SizedBox(width: 8),
              Text(
                'Book Appointment — Rs 2,200',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Workflow Timeline ─────────────────────────────────────────

  Widget _buildWorkflowTimeline() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(18),
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
          Row(
            children: const [
              Icon(Icons.account_tree_rounded, color: kPurple, size: 18),
              SizedBox(width: 8),
              Text(
                'Booking Workflow',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: kText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._bookingTimeline.asMap().entries.map((e) {
            final i = e.key;
            final step = e.value;
            final isDone = step['done'] as bool;
            final isLast = i == _bookingTimeline.length - 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: isDone ? const Color(0xFF4CAF50) : kCard,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDone ? const Color(0xFF4CAF50) : kBorder,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        isDone ? Icons.check_rounded : Icons.circle_outlined,
                        size: 14,
                        color: isDone ? Colors.white : kMuted,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 28,
                        color: isDone
                            ? const Color(0xFF4CAF50).withOpacity(0.3)
                            : kBorder,
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    step['label'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isDone ? FontWeight.w600 : FontWeight.w400,
                      color: isDone ? kText : kMuted,
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ═══════════════ BOOKINGS TAB ════════════════════════════════

  Widget _buildBookingsTab() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tabHeader('My Bookings', Icons.calendar_today_rounded),
          Expanded(
            child: _bookingDone
                ? ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _ActiveBookingCard(),
                      const SizedBox(height: 12),
                      _PastBookingCard(
                        service: 'Plumbing Fix',
                        provider: 'Rana Plumbers',
                        date: 'May 10, 2026',
                        status: 'Completed',
                        rating: 4.5,
                      ),
                      _PastBookingCard(
                        service: 'Electrician',
                        provider: 'Waqas Electric',
                        date: 'April 28, 2026',
                        status: 'Completed',
                        rating: 5.0,
                      ),
                    ],
                  )
                : _emptyState(
                    Icons.calendar_today_rounded,
                    'No bookings yet',
                    'Submit a service request on the Home tab to get started.',
                  ),
          ),
        ],
      ),
    );
  }

  // ═══════════════ AI TRACE TAB ════════════════════════════════

  Widget _buildAiTraceTab() {
    final logs = [
      _TraceLog(
        agent: 'Language Parser',
        icon: Icons.translate_rounded,
        color: kPurple,
        action: 'Intent Extraction',
        detail:
            'Input: "Mujhe kal morning mein AC technician chahiye G-13 mein"\nDetected: Roman Urdu + English mix\nConfidence: 92%',
        timestamp: '10:42:01',
        success: true,
      ),
      _TraceLog(
        agent: 'Entity Extractor',
        icon: Icons.data_object_rounded,
        color: kCyan,
        action: 'Field Extraction',
        detail:
            'service=AC Repair · location=G-13 · time=tomorrow morning · urgency=HIGH · budget_sensitivity=MEDIUM',
        timestamp: '10:42:02',
        success: true,
      ),
      _TraceLog(
        agent: 'Provider Discovery',
        icon: Icons.search_rounded,
        color: kBlue,
        action: 'Mock Dataset Query',
        detail:
            'Query: AC technicians near G-13, Islamabad\nResult: 3 providers found\nFilters applied: availability=true, rating≥4.0',
        timestamp: '10:42:03',
        success: true,
      ),
      _TraceLog(
        agent: 'Ranking Engine',
        icon: Icons.leaderboard_rounded,
        color: const Color(0xFFFF7043),
        action: 'Multi-Factor Ranking',
        detail:
            'Factors: distance(20%) + rating(25%) + on-time(20%) + specialization(20%) + price(15%)\nWinner: Ali AC Services\nReason: Higher reliability despite not being nearest',
        timestamp: '10:42:04',
        success: true,
      ),
      _TraceLog(
        agent: 'Pricing Engine',
        icon: Icons.price_change_rounded,
        color: const Color(0xFF66BB6A),
        action: 'Dynamic Quote',
        detail:
            'Base: 1800 + Distance(300) + Urgency(200) – Loyalty(100) = Rs 2,200\nFairness check: ✓ Provider rate within market bounds',
        timestamp: '10:42:05',
        success: true,
      ),
      _TraceLog(
        agent: 'Scheduling Agent',
        icon: Icons.event_available_rounded,
        color: kPurple,
        action: 'Slot Reservation',
        detail:
            'Slot: Tomorrow 10:00 AM\nDouble-booking check: ✓ Clear\nTravel buffer: 20 min added\nCalendar updated: ✓',
        timestamp: '10:42:06',
        success: true,
      ),
      _TraceLog(
        agent: 'Booking Simulator',
        icon: Icons.receipt_rounded,
        color: kBlue,
        action: 'Confirmation Dispatch',
        detail:
            'SMS/WhatsApp: Simulated ✓\nBooking ID: #PRZ-2024-001\nProvider notified: ✓\nReminder scheduled: T-60min ✓',
        timestamp: '10:42:07',
        success: true,
      ),
    ];

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
              child: const Row(
                children: [
                  Icon(Icons.hub_rounded, color: kCyan, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Antigravity Orchestrator — Live agent reasoning pipeline',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(Icons.circle, color: Color(0xFF4CAF50), size: 8),
                  SizedBox(width: 4),
                  Text(
                    'Active',
                    style: TextStyle(color: Color(0xFF4CAF50), fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _showAiCard
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: logs.length,
                    itemBuilder: (_, i) => _TraceLogCard(log: logs[i]),
                  )
                : _emptyState(
                    Icons.psychology_outlined,
                    'No trace yet',
                    'Submit a service request to see AI reasoning logs.',
                  ),
          ),
        ],
      ),
    );
  }

  // ═══════════════ PROFILE TAB ══════════════════════════════════

  Widget _buildProfileTab() {
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
          // Stats row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _statCard(
                  'Bookings',
                  _bookingDone ? '1' : '0',
                  Icons.calendar_today_rounded,
                  kBlue,
                ),
                const SizedBox(width: 10),
                _statCard(
                  'AI Searches',
                  _showAiCard ? '1' : '0',
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
          // Menu items
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
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  PROVIDER CARD WIDGET
// ═══════════════════════════════════════════════════════════════

class _ProviderCard extends StatefulWidget {
  final Map<String, dynamic> provider;
  final int rank;
  final VoidCallback? onBook;

  const _ProviderCard({
    required this.provider,
    required this.rank,
    this.onBook,
  });

  @override
  State<_ProviderCard> createState() => _ProviderCardState();
}

class _ProviderCardState extends State<_ProviderCard> {
  bool _expanded = false;

  static const kBlue = Color(0xFF185FA5);
  static const kText = Color(0xFF1A1A2E);
  static const kMuted = Color(0xFF6B7A8D);
  static const kCard = Color(0xFFF5F9FF);
  static const kBorder = Color(0xFFD8E6F5);

  @override
  Widget build(BuildContext context) {
    final p = widget.provider;
    final isTop = widget.rank == 1;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isTop ? kBlue.withOpacity(0.4) : kBorder,
            width: isTop ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (isTop ? kBlue : Colors.black).withOpacity(
                isTop ? 0.1 : 0.04,
              ),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    children: [
                      // Rank circle
                      Container(
                        width: 32,
                        height: 32,
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
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p['name'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: kText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFFFFB347),
                                  size: 13,
                                ),
                                Text(
                                  ' ${p['rating']}  (${p['reviews']} reviews)',
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
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: (p['badgeColor'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: (p['badgeColor'] as Color).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          p['badge'] as String,
                          style: TextStyle(
                            color: p['badgeColor'] as Color,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Info chips
                  Row(
                    children: [
                      _chip(Icons.location_on_rounded, p['distance'] as String),
                      const SizedBox(width: 6),
                      _chip(Icons.timer_rounded, 'On-time: ${p['onTime']}%'),
                      const SizedBox(width: 6),
                      _chip(
                        Icons.access_time_rounded,
                        p['available'] as String,
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Price + expand
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
                            'Rs ${(p['price'] as int).toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: kBlue,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            _expanded
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                            color: kMuted,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _expanded ? 'Less' : 'Why Recommended?',
                            style: const TextStyle(
                              fontSize: 11,
                              color: kBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Expandable reasons
                  if (_expanded) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Why Recommended?',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: kText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...(p['reasons'] as List<String>).map(
                            (r) => Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: Color(0xFF4CAF50),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 7),
                                  Text(
                                    r,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: kText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isTop) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Select This Provider',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(8),
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
}

// ═══════════════════════════════════════════════════════════════
//  BOOKING SUCCESS DIALOG
// ═══════════════════════════════════════════════════════════════

class _BookingSuccessDialog extends StatelessWidget {
  final VoidCallback onDone;
  const _BookingSuccessDialog({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 38,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Booking Confirmed!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Ali AC Services\nSlot: Tomorrow 10:00 AM\nBooking ID: #PRZ-2024-001',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7A8D),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_active_rounded,
                    color: Color(0xFF4CAF50),
                    size: 14,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Reminder set for 9:00 AM',
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF185FA5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'View My Bookings',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
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
//  BOOKING TAB CARDS
// ═══════════════════════════════════════════════════════════════

class _ActiveBookingCard extends StatelessWidget {
  static const kBlue = Color(0xFF185FA5);
  static const kText = Color(0xFF1A1A2E);
  static const kMuted = Color(0xFF6B7A8D);
  static const kBorder = Color(0xFFD8E6F5);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A1628), Color(0xFF1A2E50)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.circle, color: Color(0xFF4CAF50), size: 7),
                    SizedBox(width: 5),
                    Text(
                      'Active',
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                '#PRZ-2024-001',
                style: TextStyle(color: Color(0xFF8BAACC), fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'AC Repair Service',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ali AC Services',
            style: TextStyle(color: Color(0xFF8BAACC), fontSize: 13),
          ),
          const SizedBox(height: 14),
          Row(
            children: const [
              Icon(
                Icons.access_time_rounded,
                color: Color(0xFF00C2D4),
                size: 14,
              ),
              SizedBox(width: 5),
              Text(
                'Tomorrow — 10:00 AM',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 14),
              Icon(
                Icons.location_on_rounded,
                color: Color(0xFF00C2D4),
                size: 14,
              ),
              SizedBox(width: 5),
              Text(
                'G-13, Islamabad',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
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
                  child: const Text('Contact', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PastBookingCard extends StatelessWidget {
  final String service;
  final String provider;
  final String date;
  final String status;
  final double rating;

  const _PastBookingCard({
    required this.service,
    required this.provider,
    required this.date,
    required this.status,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8E6F5)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F9FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF4CAF50),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$provider · $date',
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
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFFB347),
                    size: 13,
                  ),
                  Text(
                    ' $rating',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  AI TRACE LOG CARD
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
